# Pixelita — Default Instructions

## Commits

### Single-commit tasks

- When your task can fit in one commit, don't commit
- Instead, you must suggest a commit message like this :

```
<type>(<scope>): the commit message
```

This respects the conventional commit from [conventionalcommits.org](https://conventionalcommits.org)

### Multi-commit tasks

- If your task must be split in several commits, you can commit, but adding `@` before `<type>` :

```
@<type>(<scope>): the commit message
```

