---
name: upgrade-touchstone
description: Upgrade this app to the latest Pixelita touchstone version — bumps `Touchstone version` in the app's CLAUDE.md, refreshes the `.blueprint/` and `.ai/` caches, and brings the code in line with the new standards. Use this whenever the user wants to move the app to a newer blueprint or touchstone version, mentions a new touchstone version, asks to "update the blueprint", "refresh .blueprint", or wonders whether the app is still on the current version — even if they don't say the word "upgrade".
---

# Upgrading an app to a new touchstone version

This skill runs **inside a crafted app**, and upgrades that app. Touchstone itself is
never modified — releasing a new touchstone version is the touchstone `upgrade` skill's
job, and this skill only adopts what that one released.

Touchstone lives at `../..`, the same path the app's `CLAUDE.md` already uses.

## Steps

### 1. Resolve both versions

The current version is the `### Touchstone version : X.Y` line in this app's `CLAUDE.md`.

The latest is the version number declared on touchstone's `main`. Fetch first, so the
answer isn't stale, then read the version file by its real name — it lives at the
touchstone root and the family is part of the file name, so never hardcode it:

```bash
git -C ../.. fetch --tags
git -C ../.. show main:$(git -C ../.. ls-tree --name-only main | grep '\.version$')
```

If the two versions match, tell the user the app is already on X.Y and stop. There is
nothing to upgrade.

### 2. Check both versions are tagged

`.blueprint/` is built with `git archive <version>`, so a version is only usable if
touchstone has a tag for it. Both tags matter: the new one to fetch the cache, the old
one to diff against.

```bash
git -C ../.. tag -l <old> <new>
```

If either tag is missing, **stop and change nothing**. Say which version is untagged —
for the new one, that it is declared on `main` but not released yet, and that it must be
tagged in touchstone first. Do not fall back to `main`, do not offer an older version,
and do not touch `CLAUDE.md` or `.blueprint/`. A half-upgraded app is worse than one
that never started.

### 3. Ask the user

Only once both tags are confirmed:

> Current version is 1.0, latest is 1.1. Upgrade?

If the user declines, stop. Nothing has been modified yet.

### 4. Read what changed

```bash
git -C ../.. diff <old> <new> -- blueprint/ ai/
```

This is the authoritative account of how the blueprint and the default AI instructions,
skills and settings moved between the two versions. Read it before touching the caches —
once `.blueprint/` and `.ai/` are replaced, the old reference is gone.

### 5. Replace the vendored copies

Two folders are vendored from touchstone at the pinned version: the `.blueprint/` cache
and the `.ai/` folder — the full snapshot of touchstone's `ai/` (default instructions,
skills in `.ai/.claude/skills/`, settings in `.ai/.claude/settings.json`). Refresh both
from `<new>` so they stay in lockstep with the version being adopted. Extract each
archive to a fresh directory before removing the old one, so a failed fetch never
destroys the copy the app currently relies on:

```bash
mkdir .blueprint.new && git -C ../.. archive <new> blueprint > .blueprint.new/a.tar && tar -x --strip-components=1 -C .blueprint.new -f .blueprint.new/a.tar && rm .blueprint.new/a.tar && rm -rf .blueprint.new/.claude && rm -rf .blueprint && mv .blueprint.new .blueprint
mkdir .ai.new && git -C ../.. archive <new> ai > .ai.new/a.tar && tar -x --strip-components=1 -C .ai.new -f .ai.new/a.tar && rm .ai.new/a.tar && rm -rf .ai && mv .ai.new .ai
```

Both are gitignored, regenerable caches vendored from touchstone. Keeping `.ai/` as a
local copy is what lets `@.ai/CLAUDE.md` resolve with a repo-relative path (a
`../../ai/CLAUDE.md` path points outside the tree and breaks inside git worktrees), and
refreshing the whole folder — not just `CLAUDE.md` — is what keeps the skills and
settings from drifting away from touchstone.

If either fetch fails, the `&&` chain leaves the existing folder untouched — remove the
leftover `.new` directory, say so plainly and stop: with no valid `.blueprint/`, no code
may be written in this app at all, and stale `.ai/` skills would contradict the version
being pinned. After the refresh, check the `.claude/` symlinks still resolve (`ls -L
.claude/skills`); if touchstone reorganized `ai/.claude/`, fix the symlinks to match.

### 6. Pin the new version

In this app's `CLAUDE.md`, set `### Touchstone version : <new>`.

### 7. Bring the app in line with the new standards

Read the diff from step 4 as evidence of how the conventions changed — architecture,
folder structure, naming, dependencies, theming, wiring — and apply those conventions to
this app's own code wherever it has a counterpart.

The goal is that the app looks like it was crafted from the new blueprint, not that it
contains the same features. A blueprint change to something this app doesn't have is not
a reason to build it: there is simply nothing to translate.

When a change is ambiguous — the blueprint moved in a direction this app has no clear
equivalent for — stop and ask the user rather than inventing a mapping.

### 8. Verify

Run `flutter analyze` and `flutter test`. Both must pass. If they don't, fix the
migration rather than reporting a broken upgrade.

### 9. Suggest a commit

`.blueprint/` and `.ai/` are gitignored, so the commit is `CLAUDE.md` plus the code
changes. Don't commit — suggest the message:

```
chore(touchstone): upgrade to version 1.1
```

Report to the user: old version → new version, and what changed in the app's code.
