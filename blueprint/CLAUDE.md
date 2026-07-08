# Title of the app

## Global instructions

### Root file CLAUDE.md

@../../ai/CLAUDE.md : This file contains your default instructions. Read it and apply it all the time.

### Blueprint conformance

Every time you write code, always make sure the app uses the same practices, architecture, folder structure, naming conventions, dependencies and theming as the reference @../../blueprint.

#### Blueprint version : 1.0

The blueprint is versioned through the touchstone repository's git tags. Before conforming to @../../blueprint, check out the touchstone project (the repository at `../..`, which contains the blueprint) to the git tag matching the version above:

```
git -C ../.. checkout <version>
```

This ensures the app always conforms to a stable, pinned version of the blueprint rather than in-progress changes.

## Custom instructions

Write here your custom instructions, concerning this project only.

