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

Never improvise to fill a gap: whenever something is unclear, missing from
the design, or an edge case the design doesn't cover, ask the developer and
write down the answer.

## 4. Write ARCHITECTURE.md

**Required sub-skill:** `superpowers:brainstorming`.

Use it to challenge the developer about the features they want to implement:
question the ticket's assumptions, surface hidden requirements and edge
cases, and confirm the intended scope before anything is written down.

Two things must come out of the brainstorm, decided **with the developer**,
never assumed:

- **All the models.** Every domain entity and DTO the feature needs, with
their fields, types, nullability and the relations between them. Walk the
developer through each one and get it validated.
- **The global architecture.** Which layers and components the feature adds
or touches (data sources, repositories, providers, controllers, widgets),
how data flows between them, and what state lives where.

Write the result as `tickets/<N>_<feature>/ARCHITECTURE.md`, with the
diagrams in **Mermaid** blocks. The file must show two architectures:

- **Remote SQL tables** — the tables the feature reads or writes.
- **Front app models** — the entities and DTOs the feature adds or changes.

Both with the **full list of parameters** (every column / field with its type and nullability), and **only for the tables and models concerned by this feature**. Tag each class/table as new or edited.

In the end, this file must contain the new directory tree, limited to the files the plan touches.

Developer must agree with the file `ARCHITECTURE.md` then you commit and move on to the next step.

## 5. Write the plan

**Required sub-skill:** `superpowers:writing-plans`.

Write the plan as `tickets/<N>_<feature>/PLAN.md`.

- Be concise: the plan must be easy to read.
- Reference files `SPECS.md` and `ARCHITECTURE.md` in the plan.
- Don't write code in the plan.
- Every UI task must name the baseline PNG(s) it must match as acceptance
criteria.

Ask user if he wants to go with : 

- VIBE-CODING
  - Use `superpowers:subagent-driven-development` 
  - Commit without developer's approval (with prefix '@' so that I know it's not me)
  - Make PR in the end and give me link so that I can check it
- BREAKPOINTS
  - Insert a breakpoint after each task: suggest a conventional commit message  
  (no `@` prefix). If the user confirms, commit it yourself with the `@`  
  prefix; the user may also commit it themselves and reply something like  
  "next" — then move on to the next task.
  - Don't mention the skill `superpowers:subagent-driven-development` in the  
  plan: the breakpoints replace it.

## No spec/task references in code

The spec, baselines and `DESIGN.html` exist only at planning and verification  
time. Code and comments never mention them: no `// for next Task` `// Task 8` `// per spec`,
`// Specs: ...`, `// matches 03_voice_chip.png`, no spec-section  or task-section names in identifiers. A comment must state a constraint the code can't show — never where a value came from.