---
name: ticket-to-plan
description: Use when starting work on a feature ticket in tickets/, before writing any plan or code — especially when the feature has UI states (panels, chips, dialogs, selections) defined by DESIGN.html snapshots.
---

# Planning a feature from the design

Turn a feature ticket into an implementation plan grounded in the design:
capture what the design says the feature looks like in every state, write it
down as a spec, then plan against that spec.

## 1. Read the ticket

Work inside `tickets/<N>_<feature>/`. Read `SCOPE.md` — it defines which
screens and states the feature covers.

## 2. Explore the design and the app

Run `DESIGN.html` in the browser and build/run the current app. Navigate both
to the screens covered by `SCOPE.md`.

Take a PNG screenshot of **every state and edge case** the design defines
(selected vs resting, empty, error, overflow, ...). Save them in the ticket
folder, e.g. `tickets/<N>_<feature>/specs/03_voice_chip.png`. These are the
baselines the implementation must match. Screenshotting the current app too
shows where it stands and what the feature actually changes.

## 3. Write SPECS.md

Write `tickets/<N>_<feature>/SPECS.md`, referencing the PNG screenshots.
For each state, write down the details visible in the image:

- selected vs resting styles
- icons
- elements that exist only in that state
- exact colors and fills

Be thorough — anything not written down here will be improvised later.

## 4. Write the plan

**Required sub-skill:** `superpowers:writing-plans`.

Write the plan as `tickets/<N>_<feature>/PLAN.md`.

- Every UI task must name the baseline PNG(s) it must match as acceptance
  criteria.
- Insert a breakpoint after each task: suggest a conventional commit message
  (no `@` prefix). If the user confirms, commit it yourself with the `@`
  prefix; the user may also commit it themselves and reply something like
  "next" — then move on to the next task.

## 5. Close the loop

The plan must end with a visual verification task: build the app on web,
screenshot it in the same states, and compare against the baseline PNGs by
inspection — same layout, colors, icons and states. A UI task is not done
until its screenshots match.

## No spec references in code

The spec, baselines and `DESIGN.html` exist only at planning and verification
time. Code and comments never mention them: no `// per spec`,
`// Specs: ...`, `// matches 03_voice_chip.png`, no spec-section names in
identifiers. A comment must state a constraint the code can't show — never
where a value came from.
