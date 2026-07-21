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

The answers shape the cutting (a synced, authenticated app orders and sizes
tickets differently than a purely local one), so don't move on until they're
settled.

## Step 4 — Propose the cutting, wait for confirmation

Present a numbered table: feature name, what it contains, one line on why it
sits at that position. Order by dependency, not by prominence:

0. The app shell first — navigation, theming, global feedback (toasts etc.).
   Everything else plugs into it.
1. The core entity's basic lifecycle next (create/view/edit/delete) — most
   later features decorate it.
2. Then features layered so each ticket only depends on lower numbers.
3. Cross-cutting polish last — settings assembly, premium locks, first-run
   empty states — because they touch every earlier feature.

Aim for tickets of comparable, shippable size: each one should leave the app
runnable and demonstrably better. Too coarse and a ticket becomes a project;
too fine and specs repeat each other's context.

**Do not create anything yet.** The user will rename, merge, split and reorder.
Iterate on the table until they explicitly confirm the cutting and the order.

## Step 5 — Materialize `tickets/`

After confirmation only, create at the app root:

```
tickets/
├── README.md
├── 0_<feature_name>/
│   └── SCOPE.md
├── 1_<other_feature>/
│   └── scope.md
└── ...
```

Folder names are `<N>_<snake_case_feature>`; each contains a single `scope.md`.
`README.md` holds the confirmed order table plus anything true of the whole
prototype rather than one feature (vocabulary, frozen-time note, where the
design tokens live).

## Scope contents

`scope.md` is **not a specification** — the spec is written later, by a
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
