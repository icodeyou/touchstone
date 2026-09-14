---
name: crazy-paywall
description: Use when a mobile app must show a dismissible (soft) paywall to free users on cold start, every time the app returns to the foreground, and right after sign-in or account creation. Also use when such a paywall loops, reappearing immediately after being dismissed or after switching apps and coming back.
---

# Crazy paywall

## Overview

A soft upsell that is aggressive but never blocking: every time a free user
brings the app to the foreground, and right after they sign in, the store's
modal paywall opens with a close button. Dismissing it costs nothing, it
simply comes back next time.

**Core principle:** presenting a native paywall sheet changes the app
lifecycle by itself. If the trigger is "the app resumed", the paywall
retriggers itself forever. The trigger must be "the app resumed after a real
stay in the background that was observed while no paywall was open".

Everything else is plumbing. Get the trigger right and the feature ships in
one shot.

## When to use

- The product asks for "show the paywall after login or signup" together
  with "show it every time the app is opened, even when it was not killed".
- A soft paywall already exists but loops after dismissal.

Do not use it for a hard paywall (blocking gate, no close button). That is a
different gate. If both exist, this trigger must stay silent when the hard
gate is active.

## The concept

### Three moments, one entry point

There are three moments where the paywall may appear. All three go through a
single `present(placement)` method so the guards live in one place:

| Moment | How it is detected | Placement name |
|---|---|---|
| Cold start | The controller is created with a signed-in session | `resume` |
| Foregrounding | Lifecycle went to background, then resumed | `resume` |
| Sign-in or signup | Auth state went from signed out to signed in | `sign_in` |

The cold start shares the `resume` placement on purpose: for the product it
is the same thing, the user opened the app.

### The gate chain inside `present`

In this order, each one returns early when it fails:

1. **Already presenting.** One paywall at a time, never stack two sheets.
2. **No store.** A build without a store backend (simulator, web, tests
   without a fake) never presents.
3. **Not signed in.** A signed-out user must not see it.
4. **App is locked** (PIN, biometrics). Do not present over the lock; remember
   the placement and present it once the app unlocks.
5. **Eligibility, asynchronous.** Wait until the entitlement is actually
   known, then present only when the user is free. Also honor any experiment
   arm here: if the paywall model is A/B tested, only the soft arm presents.

Then track the analytics view event, present the sheet with the close button,
and log the outcome.

### The lifecycle trap, in full

Three separate loops were found on a real iPhone. All three guards are
needed, together, from day one.

**Loop 1: it reappears right after dismissal.** Opening and closing a native
sheet takes the app through `resumed -> inactive -> resumed`. A trigger on
every `resumed` fires again the instant the sheet closes.
Guard: arm a flag on `paused` or `hidden`, fire only on the `resumed` that
follows an armed flag, and clear the flag when firing.

**Loop 2: it reappears after switching apps and back.** Returning to the app
legitimately opens the sheet. On iOS a full-screen sheet covering the app can
itself report `hidden` and `paused`. With guard 1 alone, those states re-arm
the flag while the sheet is up, so the `resumed` after dismissal fires again.
Guard: ignore every lifecycle transition while a paywall is presenting, and
clear the background flag when the presentation ends, whatever the outcome.

**Loop 3 (not a loop, but a wrong show): a subscriber gets upsold at cold
start.** The controller runs before the store has answered, so the
"is premium" value is still its default (false).
Guard: await the first store status before deciding eligibility.

The state machine is small:

```
                 paused | hidden (no sheet open)
   idle  ───────────────────────────────────────►  armed
    ▲                                                │
    │  presentation ends (clears the flag)           │ resumed
    └──────────────────  presenting  ◄───────────────┘
                (all lifecycle events ignored)
```

Do not add a debounce or a cooldown "to be safe". On iOS a system dialog
or the purchase sheet does not pass through `paused`, so they do not fire
the trigger; some Android permission dialogs may, and that was accepted. If
the product decision is "every resume", ship every resume.

### Where the controller lives

The controller must be created **above the auth gate**, for the whole app,
signed in or not. If it lives inside the signed-in subtree it is created only
after sign-in and never sees the signed-out to signed-in transition. A tiny
wrapper widget that just watches the controller's provider and returns its
child is enough. Put it inside the lock gate wrapper if there is one, so it
shares the same tree position in the app and in the widget-test shell.

### Sign-in detection

Listen to the auth user stream, but remember the sign-in state at creation
time. The stream's first emission replays the session you started from, so
only a change from signed out to signed in counts. A change to signed out
just updates the remembered state.

### Analytics

Reuse the existing paywall view event and add the two placements, `resume`
and `sign_in`, to its documented values. Update the analytics source of truth
file at the same time.

## Dependency contract

Before writing code, locate the project's equivalents of these and note
their names. They exist in one form or another in any app that already
sells a subscription:

| Need | What it must provide |
|---|---|
| Lifecycle | A provider exposing the current `AppLifecycleState`, updated through `AppLifecycleListener` or `WidgetsBindingObserver` |
| Auth | Synchronous "current user or null", plus a stream or async provider of the user |
| Purchases | `storeAvailable` flag, `presentPaywall({displayCloseButton})` returning an outcome, and a status stream whose first value means "entitlement known" |
| Premium state | A synchronous "is entitled" boolean derived from the store status |
| Lock (optional) | A boolean "is locked" provider; skip step 4 if the app has none |
| Experiment (optional) | The paywall arm, async; skip the arm check if the paywall is not A/B tested |
| Analytics | A capture method taking an event name and properties |

If a piece is missing, add it in the project's own style rather than working
around it inside the controller.

### Assumptions to check before coding

- **The session is restored synchronously.** The reference reads "current
  user" once at creation and treats the first stream emission as a replay.
  If the target app restores its session asynchronously (null at creation,
  then the stream emits the restored user), that emission would be misread
  as a sign-in. In that case, take the initial value from the first stream
  emission instead and only compare from the second one on.
- **The store status emits at least once, even on failure.** The
  eligibility step awaits the first status. If the store can stay silent
  when unreachable, the controller would wait forever with the presenting
  flag set and block every later paywall. Make the status stream emit a
  "not entitled" value on failure, or wrap the wait in a timeout that
  returns "not eligible".
- **The hard gate, if any, is identifiable.** The reference keeps silent on
  the hard arm through the experiment. If the hard gate is driven by
  something else (trial expiry, a remote flag), check that condition at the
  top of the eligibility step instead.

## Reference implementation

Riverpod `Notifier`, Flutter. Adapt imports and provider names to the
project; the structure stays.

```dart
class SoftPaywallController extends Notifier<void> {
  static final provider = NotifierProvider<SoftPaywallController, void>(
    SoftPaywallController.new,
  );

  static const resumePlacement = 'resume';
  static const signInPlacement = 'sign_in';

  bool _wasSignedIn = false;
  bool _presenting = false;
  bool _backgrounded = false;
  String? _deferredPlacement;

  bool _signedIn() => ref.read(authRepositoryProvider).currentUser != null;

  @override
  void build() {
    _wasSignedIn = _signedIn();

    // Guards 1 and 2: only a resume after a real background stay counts,
    // and nothing seen while the sheet is up does.
    ref.listen(appLifecycleProvider, (previous, next) {
      if (_presenting) return;
      if (next == AppLifecycleState.paused ||
          next == AppLifecycleState.hidden) {
        _backgrounded = true;
      } else if (next == AppLifecycleState.resumed && _backgrounded) {
        _backgrounded = false;
        unawaited(present(resumePlacement));
      }
    });

    // The first emission replays the current session; only a real
    // signed-out to signed-in transition counts.
    ref.listen(authUserStreamProvider, (previous, next) {
      if (next.isLoading) return;
      final signedIn = next.value != null;
      if (signedIn == _wasSignedIn) return;
      _wasSignedIn = signedIn;
      if (signedIn) unawaited(present(signInPlacement));
    });

    // Optional: a presentation deferred by the lock fires on unlock.
    ref.listen(lockedProvider, (previous, next) {
      final deferred = _deferredPlacement;
      if ((previous ?? false) && !next && deferred != null) {
        _deferredPlacement = null;
        unawaited(present(deferred));
      }
    });

    // Cold start with a restored session.
    if (_wasSignedIn) unawaited(present(resumePlacement));
  }

  Future<void> present(String placement) async {
    if (_presenting) return;
    if (!ref.read(purchaseServiceProvider).storeAvailable || !_signedIn()) {
      return;
    }
    if (ref.read(lockedProvider)) {
      _deferredPlacement = placement;
      return;
    }
    _presenting = true;
    try {
      if (!await _eligible()) return;
      unawaited(
        ref.read(analyticsProvider).capture(
          'premium:paywall=view',
          properties: {'placement': placement},
        ),
      );
      final outcome = await ref
          .read(purchaseServiceProvider)
          .presentPaywall(displayCloseButton: true);
      'Soft paywall ($placement) ended: ${outcome.name}'.logInfo;
    } finally {
      // Guard 2, second half: a background stay seen while the sheet was
      // up must not arm the next resume.
      _presenting = false;
      _backgrounded = false;
    }
  }

  // Guard 3: decide only once the entitlement is known.
  Future<bool> _eligible() async {
    // Optional: await the experiment arm here and return false unless it
    // is the soft arm.
    await ref.read(purchaseStatusStreamProvider.future);
    return _signedIn() && !ref.read(isPremiumProvider);
  }
}
```

Notes on the reference:

- The `finally` block resets both flags even when `_eligible` returned false
  or the sheet failed to present. That is intentional.
- The lock listener uses `previous ?? false`, so the first emission never
  counts as an unlock. A presentation deferred at cold start is released by
  the real unlock, whose `previous` is `true`.
- If two presentations are deferred behind the lock, the last placement
  wins. That is fine, one paywall after unlock is the goal.
- The A/B arm check, when present, goes at the top of `_eligible` so a
  hard-arm user never reaches the store status wait.

## Tests

Widget tests with a fake purchase service. The fake needs three things
beyond what a purchase fake usually has:

- a record of `presentPaywall` calls and the `displayCloseButton` value of
  the last one,
- a settable outcome (`dismissed` for the loop tests),
- a way to keep the sheet open: an optional `Completer` the fake awaits
  inside `presentPaywall` before returning, so a test can feed lifecycle
  events while the sheet is up.

```dart
// In the purchase fake.
final calls = <String>[];
bool? lastCloseButton;
PaywallOutcome paywallOutcome = PaywallOutcome.failed;
Completer<void>? paywallOpen;

@override
Future<PaywallOutcome> presentPaywall({bool displayCloseButton = true}) async {
  calls.add('presentPaywall');
  lastCloseButton = displayCloseButton;
  final open = paywallOpen;
  if (open != null) {
    paywallOpen = null;
    await open.future;
  }
  return paywallOutcome;
}
```

Drive the lifecycle by overriding the lifecycle provider with a subclass
whose initial state is `resumed` and that exposes a setter. This requires
the app's lifecycle provider to be a plain `Notifier`, which is the usual
shape:

```dart
class _TestLifecycle extends AppLifecycle {
  @override
  AppLifecycleState build() => AppLifecycleState.resumed;
  void go(AppLifecycleState next) => state = next;
}

// override: appLifecycleProvider.overrideWith(_TestLifecycle.new)
// read back:
final lifecycle = ProviderScope.containerOf(
  tester.element(find.byType(SoftPaywallTriggerView)),
).read(appLifecycleProvider.notifier) as _TestLifecycle;
```

Timing rules in the scenarios below: `present` runs asynchronously, so
call `pumpAndSettle` after each `resumed` before asserting or before the
next background pass. Otherwise a `paused` can land while the previous
presentation is still in flight and be ignored, which makes the count come
out one short. In the loop 2 scenario, `pump()` once after the `resumed`
that opens the held sheet, feed the covering states, complete the holder,
then `pumpAndSettle` so the `finally` block runs before the last `resumed`.

Wire the trigger wrapper in the test shell helper exactly where it sits in
the app, or every test passes vacuously.

Scenarios to cover, with the expected number of `presentPaywall` calls. A
signed-in free user starts each one unless stated, so the cold start counts
as one call:

| Scenario | Sequence | Calls |
|---|---|---|
| Cold start | pump | 1, close button true, placement `resume` |
| Every resume | `paused, resumed`, then `inactive, hidden, paused, resumed` | 3 |
| Sheet closing is not a resume (loop 1) | `inactive, resumed` with no pause | 1 |
| Sheet covering does not re-arm (loop 2) | hold the sheet open; `paused, resumed` opens it (2); while open, `inactive, hidden, paused`; release the sheet; settle; `resumed` | still 2 |
| Sign-in | start signed out (0 calls), then set a user | 1, placement `sign_in` |
| Premium user | `paused, resumed` | 0 |
| Store-less build | `storeAvailable = false` | 0 |
| Hard arm (if A/B tested) | pump | only the hard gate's call, close button false |
| Locked at cold start (if a lock exists) | pump: 0 while the lock screen shows; unlock | 1 |

Pin the clock in every test if the shell has time-dependent screens, so
night-time runs do not fail on unrelated logic.

## Verification before claiming done

- The paywall suite, plus the lock and onboarding suites when they exist,
  pass.
- Analyzer and formatter clean on the touched files only.
- On a real device: dismiss the paywall, no re-show. Switch to another app
  and back, one show, dismiss, no re-show. Sign out and sign in, one show.
  Do this on iOS at least, it is where loop 2 appears.

## Common mistakes

- Triggering on `resumed` alone. Loop 1.
- Guarding the resume but still reading lifecycle events while presenting.
  Loop 2, iOS only, only after a real app switch.
- Forgetting to clear the background flag when the presentation ends.
  Loop 2 again.
- Creating the controller below the auth gate. Sign-in never fires.
- Reading "is premium" before the first store status. Subscribers see one
  paywall per cold start.
- Wiring the wrapper in the app but not in the test shell. Tests pass and
  prove nothing.
- Adding a cooldown. It hides loops in tests and breaks the product
  decision on device.
