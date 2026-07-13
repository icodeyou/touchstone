# Pixelita — Default Instructions

Always start your response with "Yo.".

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

```
<type>(<scope>): the commit message
```

This respects the conventional commit from [conventionalcommits.org](https://conventionalcommits.org)

### Multi-commit tasks

- If your task must be split in several commits, you can commit, but adding `@` before `<type>` :

```
@<type>(<scope>): the commit message
```

