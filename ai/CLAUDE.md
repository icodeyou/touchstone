# Pixelita — Default Instructions

Always start your response with "Yo.".

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

## Commits

### Single-commit tasks

- When your task can fit in one commit, don't commit
- Instead, you must suggest a commit message like this :

```txt
<type>(<scope>): the commit message
```

This respects the conventional commit from [conventionalcommits.org](https://conventionalcommits.org)

### Multi-commit tasks

- If your task must be split in several commits, you can commit, but adding `@` before `<type>` :

```txt
@<type>(<scope>): the commit message
```

## Comments

Don't comment code unless it's make it easier for the developer to understand (e.g. cases that are not explicitly detailed by reading the code).

## UI

Only use the predefined scale values from the `snowflake_flutter_theme` lib:
`AppText.xs`, `AppText.s`, ... for texts, `ThemeSizes.xs`, `ThemeSizes.s`, ...
for sizes, paddings and margins, etc. Never hardcode font sizes or dimensions.

If a value you need doesn't exist in the scale, ask me to update the
snowflake lib instead of hardcoding it.

