# Pixelita — Default Instructions

Always start your response with "Yop.".

## Plans and specs

Don't write plans or spec files, unless I specifically ask you to do so, or unless you're in plan mode.

## Logging

Never use `print`.

Write info, warning and error logs as much as necessary, using the string
extensions from `core/log/log.dart` (`'message'.logInfo`,
`'message'.logWarning(...)`, `'message'.logError(...)`).

- **Info** — a meaningful operation succeeded: startup completed, an entity
was created or updated, a user-triggered action went through. Include
identifiers in the message (`'Todo ${todo.id} updated to ${status.name}'`).
- **Warning** — something failed but the app recovers: an optimistic update
is rolled back, a retry is triggered, a fallback is used. Pass the caught
`error` and `stackTrace`.
- **Error** — an operation failed with user-visible impact: startup failure,
a request that ends in an error view. Pass the caught `error` and
`stackTrace`.

Don't log happy-path UI noise (taps, rebuilds, navigation).

## Analytics

`ANALYTICS.md` at the app root is the single source of truth for analytics.
Whenever you work on analytics (events, user properties, super properties,
feature flags, experiments), always base your work on this file: implement
exactly what it describes, and update it whenever the tracking changes.

## Colors

Always use `AppColors` for colors. Never declare two different variables for
the same color value: when two names would share a value, replace them with a
single generic name that covers both uses (e.g. `lightBackground`).

## Commits

### Single-commit tasks

- When your task can fit in one commit, don't commit
- Instead, you must suggest a commit message like this :

```txt
gca "@<type>(<scope>): <the commit message>"
```

This respects the conventional commit from [conventionalcommits.org](https://conventionalcommits.org)

### Multi-commit tasks

- If your task must be split in several commits, you can commit, but adding `@` before `<type>` :

```txt
@<type>(<scope>): the commit message
```

## Shortcuts

`prm` — ship the current work and end the session: commit, push, open the
pull request, merge it, then say the conversation can be closed. Defined by
the `prm` skill.

## Comments

Don't comment code unless it's make it easier for the developer to understand (e.g. cases that are not explicitly detailed by reading the code).

## Wording

In user-facing texts, never use a dash (` - ` or ` — `) as a comma-like
separator between clauses; it is a typical AI writing tic. Use a period, a
comma or a rewrite instead.

## Naming

Prefer the singular over the plural as much as possible for class names, file
names and folder names (`todo/todo_list.dart`, not `todos/todo_lists.dart`).
Only use the plural when the name would be wrong in the singular.

SQL tables are the exception: always name them in the plural (`todos`, not
`todo`).
