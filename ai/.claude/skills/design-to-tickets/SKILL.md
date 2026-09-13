---
name: design-to-tickets
description: Use when a new app has a DESIGN.html prototype and no tickets/ folder yet — cuts the design into an ordered list of feature tickets. Trigger whenever the user asks to split, cut, slice or break the design into features/tickets, to plan the implementation order of an app, or to "create the tickets", even if they don't mention DESIGN.html by name.
---

# Cutting a design into feature tickets

`DESIGN.html` is the only design input: a self-contained interactive prototype of
the whole app. This skill reads it **statically** — never open or run it — to
understand every feature, proposes a cutting and an implementation order, and
once the user confirms, materializes it as a `tickets/` tree of spec files.

This skill produces **scopes, not specs**: each ticket gets a `SCOPE.md` that  
delimits what the feature covers. The detailed specification of each ticket is  
written later, by a separate step, from that scope.

## Step 1 — Extract the source (never run the page)

`DESIGN.html` is a self-unpacking bundle. The app's real source (HTML + JSX) is
stored as a JSON string in `<script type="__bundler/template">`; binary assets
live in `<script type="__bundler/manifest">`. Decode the template to a
scratchpad file and work from that:

```bash
python3 - <<'EOF'
import re, json
src = open('DESIGN.html').read()
tpl = json.loads(re.search(r'<script type="__bundler/template">(.*?)</script>', src, re.S).group(1))
open('<scratchpad>/design_source.html', 'w').write(tpl)
EOF
```

If the file doesn't match this bundle format, it's plain HTML — read it directly.

## Step 2 — Understand the whole app

Read `design_source.html` in full (it's large — read it in chunks, don't skim).
You are building the complete feature inventory; anything you miss here becomes
a hole in a spec later. Hunt specifically for what a quick read misses:

- **Screens and navigation** — tabs, sheets, dialogs, overlays, full-screen
  modes (`data-screen-label` attributes often name them).
- **State machines** — component state variables reveal states the resting UI
  hides: selected/editing/empty/error variants, drafts, toasts, celebrations.
- **Data model** — the entities, their fields, what persists.
- **Cross-cutting systems** — theming, design tokens, plan/premium gating,
  empty states, time-dependent behavior.
- **Prototype quirks** — frozen dates, hardcoded sample data, simulated
  behavior. Note the global ones (like a frozen clock) for `README.md`.

## Step 3 — Brainstorm what the prototype can't answer

Use the superpowers:brainstorming skill to ask the user the questions the
prototype leaves open before cutting anything. Make sure the questions cover
at least:

- **Storage / database** — where the data lives and what backend (if any)
  sits behind it.
- **Authentication** — whether there are user accounts, and how users sign in.
- **Local / offline** — whether the app is local-first, must work offline, and
  how data syncs if it does.
- **Analytics** — whether the app gets PostHog from the first ticket. This
  one has a cost the user must know before answering, so state it in the
  question itself (see below).

The answers shape the cutting (a synced, authenticated app orders and sizes
tickets differently than a purely local one), so don't move on until they're
settled.

### Asking about analytics

The PostHog plan caps the organization at **6 projects**, and each app that
gets analytics spends one of them permanently. Never ask "do you want
analytics?" on its own: the honest question is whether this app is worth one
of the remaining slots.

So before asking, list the projects already taken. The PostHog personal API
key is in the environment as `POSTHOG_PERSONAL_API_KEY`; never print it and
never write it into a file:

```bash
curl -s -H "Authorization: Bearer $POSTHOG_PERSONAL_API_KEY" \
  https://eu.posthog.com/api/organizations/@current/projects/ \
  | python3 -c 'import json,sys; print([p["name"] for p in json.load(sys.stdin)["results"]])'
```

The organization is on the EU cloud, so the host is always `eu.posthog.com`.
If the key is missing or the call fails, ask the user which projects are
already used rather than guessing.

Put the real count in the question:

> Analytics for this app? We can have 6 PostHog projects in total.
> `<n>` are already used (`<project>`, ...), so `<6 - n>` slots are left.
> Adding analytics here spends one of them.

If no slot is left, say so and don't offer the choice. The answer decides
whether ticket 0 carries analytics; record it, because nothing later in this
skill re-asks.

## Step 4 — Propose the cutting, wait for confirmation

Present a numbered table: feature name, what it contains, one line on why it
sits at that position. Order by dependency, not by prominence:

0. The app shell first — navigation, theming, global feedback (toasts etc.),
   plus analytics when Step 3 asked for them (see below). Everything else
   plugs into it.
1. The core entity's basic lifecycle next (create/view/edit/delete) — most
   later features decorate it.
2. Then features layered so each ticket only depends on lower numbers.
3. Cross-cutting polish next — settings assembly, premium locks, first-run
   empty states — because they touch every earlier feature.
4. Error reporting closes the list, always (see below).

Aim for tickets of comparable, shippable size: each one should leave the app
runnable and demonstrably better. Too coarse and a ticket becomes a project;
too fine and specs repeat each other's context.

**Do not create anything yet.** The user will rename, merge, split and reorder.
Iterate on the table until they explicitly confirm the cutting and the order.

### Analytics belong to ticket 0, when the user said yes

If Step 3 settled on analytics, the shell ticket owns the setup, so add to
its `SCOPE.md`:

- **PostHog configured at startup**, and disabled in debug mode
  (`kDebugMode`): no event, user property, super property or feature flag
  evaluation leaves a debug build.
- **`identify` wired to the app's user**, as soon as the session starts and
  again on sign-in and sign-up.
- **`ANALYTICS.md` written at the app root**, seeded from
  `.blueprint/ANALYTICS.md`: same sections (debug mode, feature flags,
  identify and user properties, super properties, events), with the
  blueprint's todo content replaced by this app's. It is the single source of
  truth for analytics, so every later ticket updates it instead of inventing
  its own events.

Ticket 0 sets up the pipe and the document, nothing more. The events
themselves belong to the tickets that own the screens firing them, so don't
list them here.

If the user said no, none of this appears in any ticket and `ANALYTICS.md` is
never created.

### The last ticket is always Sentry

Whatever the design contains, the final ticket wires the app to Sentry. It is
the only ticket not cut from `DESIGN.html`, and the only one built
differently: it holds a `README.md` instead of a `SCOPE.md`, because there is
nothing to scope. The `sentry` skill already defines the whole job.

Create it as `<N>_sentry/README.md`, `<N>` being the last number, containing:

```markdown
# Sentry

This ticket wires the app to its own Sentry project. Nothing here comes from
`DESIGN.html`: it touches no screen, adds no model and has no UI state.

**For `ticket-to-plan`:** skip the design exploration, the screenshots,
`SPECS.md` and `ARCHITECTURE.md`. Run the `sentry` skill and write `PLAN.md`
straight from it. That skill is the entire specification.
```

List it in the confirmed order table and in `tickets/README.md` like any
other ticket.

## Step 5 — Materialize `tickets/`

After confirmation only, create at the app root:

```
tickets/
├── README.md
├── 0_<feature_name>/
│   └── SCOPE.md
├── 1_<other_feature>/
│   └── SCOPE.md
├── ...
└── <N>_sentry/
    └── README.md
```

Folder names are `<N>_<snake_case_feature>`; each contains a single
`SCOPE.md`, except the last one, which holds the `README.md` described above.
`README.md` holds the confirmed order table plus anything true of the whole
prototype rather than one feature (vocabulary, frozen-time note, where the
design tokens live).

## Scope contents

`SCOPE.md` is **not a specification** — the spec is written later, by a
separate step, from this scope. Its job is to delimit the feature so the
spec writer knows exactly what territory to cover and nothing gets specced
twice or not at all. Keep it short:

- **What it is** — the feature in two or three sentences.
- **Included** — the screens, flows and UI surfaces this ticket owns, as
  observed in the source. Name them; don't describe their behavior in detail.
- **Excluded** — adjacent things a reader might assume are here but belong to
  another ticket, with the ticket number (e.g. "voice notes → ticket 3").
- **Depends on** — which lower-numbered tickets it builds on, one line each.

Draw the boundaries from what the source actually does, not from what a
typical app would do — the prototype is the source of truth.
