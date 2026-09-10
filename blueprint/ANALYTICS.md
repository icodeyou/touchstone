# ANALYTICS

We use Posthog to manage analytics and experiments.

Legend: ✅ answered · ⏳ pending · 🔥 priority

## Basic instructions

### Debug mode
PostHog must be disabled when the app runs in debug mode (`kDebugMode`).
No event, user property, super property or feature flag evaluation is sent
from a debug build.

## Feature flags

`create_flow` : `inline` / `fullscreen` — 50/50 split, on iOS and Android.
Once the winner is chosen, the flag is removed and both apps keep the winning
flow.

The variant is evaluated on the **anonymous device** at first launch and
stored locally; it belongs to the install and survives sign-out. Resolution
order at every start: device value → fresh PostHog evaluation, stored right
away.

- `inline` (A): the todo composer opens as a bottom sheet on top of the list.
- `fullscreen` (B): the todo composer opens as a dedicated screen.

🔥 -> Which flow yields more **created todos per install**?
⏳ -> In `fullscreen`, what percentage abandons the composer without saving?

## Identify the user

The user is associated with the remote database user as soon as the session
starts, and when they sign in/up, via `Posthog().identify(userId, userProperties)`.

### User properties

#### From model

`id`, `email`, `created_at`, `updated_at`

#### Extra properties

`device_first_launch_at` : Date of the first app launch (String ISO 8601)
`create_flow` : The device's experiment arm, when one is assigned (String)

## Events

### Super properties

Super properties are set with `Posthog().register(key, value)` and are sent
with every event.

`$_created_todos` : Total number of todos created — THE MAIN METRIC.
Updated on every todo creation/deletion.

`$_completed_todos` : Total number of todos completed — the habit metric,
complementing the content metric above.

`$feature/create_flow` : `inline` / `fullscreen` — the resolved variant,
so every event is sliceable by experiment arm.

`$_notifications` : enabled/disabled
`$_logged_in` : true/false

### Events with properties

#### Todo saved

`todo:composer=save`

```json
    {
        "has_due_date": bool,
        "has_description": bool,
        "word_count": int,
    }
```

⏳ -> Which fields do people actually fill in a todo?

#### Variant assigned

`create_flow_variant_assigned`

```json
    {
        "variant": "inline" | "fullscreen",
    }
```

Sent once per device, at the moment PostHog resolves the arm on the anonymous
distinct id.

⏳ -> Denominator for per-arm funnels: every assigned install.

#### Todo status changed

`todo:status=change`

```json
    {
        "status": "todo" | "done",
    }
```

🔥 -> Funnel: percentage of created todos that reach `done`, per arm

### Events without properties

#### One Time events

Sent once per user (guarded with SharedPreferences).

`todo:swipe_delete=discover`
⏳ -> Percentage of users who have discovered swipe-to-delete

#### Regular events

`settings:debug_tools=unlock`
⏳ -> Has anyone besides us found the hidden debug tools (7 taps on the version footer)?

---

`home:tab=select`
`settings:tab=select`
⏳ -> Which tab retains users the most?
