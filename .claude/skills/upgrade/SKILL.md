---
name: upgrade
description: Upgrade the Pixelita touchstone to a new version — bumps the version number in `_<FAMILY>.version` at the touchstone root, `blueprint/pubspec.yaml` and `blueprint/CLAUDE.md`, renaming the version file when a new major starts a new version family. Use this whenever the user wants to bump, release, or upgrade the touchstone (or blueprint) version, mentions a new touchstone version number like "2.0", asks to "pass the touchstone to the next version", or wants to start a new version family — even if they don't say the word "upgrade".
---

Upgrade the touchstone to a new version.

Only the root version file and `blueprint/` are ever touched. The `.blueprint` folders
inside `stones/` are frozen snapshots recording which touchstone version each stone was
crafted from — rewriting them would destroy that history. Leave them alone.

## Versioning model

Three files carry the version, and they must always agree:

- `_<FAMILY>.version` at the touchstone root — the source of truth. Holds the version
  family and the `X.Y` number.
- `blueprint/pubspec.yaml` — line `version: X.Y.0+<build>`. The patch is always `0`
  (the blueprint is a template, never patched), the build number counts up on every
  upgrade so it never repeats.
- `blueprint/CLAUDE.md` — line `### Touchstone version : X.Y`. This is the version
  crafted stones pin their `.blueprint/` cache to.

Each major version has a **version family** named after a music artist, and families run
in alphabetical order: major 1 is `ARCTIC MONKEYS` (A). A new major means a new family
whose first letter comes strictly after the current one — that's what makes the family
name alone tell you which major you're on. A minor bump stays in the same family.

The file name encodes the family: family `BLEACHERS` lives in `_BLEACHERS.version`. The name
is uppercased and any spaces become underscores — `ARCTIC MONKEYS` lives in
`_ARCTIC_MONKEYS.version`. So a new family means renaming the file, not just editing it.

## Steps

### 1. Read the current version

```bash
cat _*.version
```

It looks like this — keep the ` : ` spacing exactly when you rewrite it:

```
Version family : ARCTIC MONKEYS
Version number : 1.0
```

### 2. Ask for the new version

Ask the user for the new version, and tell them where they're starting from:
`Current version is 1.0`.

Validate the answer before going further — a bad version silently written to disk is worse
than one more question:

- Shape must be `X.Y` (two numbers). `2`, `2.0.0` or `v2.0` are not valid.
- It must be strictly higher than the current one. If they answer `1.0` or `0.9` against a
  current `1.0`, say so plainly (`0.9 is not higher than 1.0.`) and ask again.

### 3. Ask for the version family — only if the major changed

If the major is unchanged (`1.0` → `1.1`), the family is unchanged. Skip this step, and
don't ask a question whose answer is already known.

If the major changed (`1.0` → `2.0`), ask for the new version family, telling them the
constraint that applies right now — compute the required letter from the *current* family's
first letter, don't hardcode it:

> Current family is ARCTIC MONKEYS. Version family? Must start with B or any letter after.

Validate: the first letter must come strictly after the current family's first letter in the
alphabet. `AIR` after `ARCTIC MONKEYS` is a rejection.

### 4. Write the version file

Uppercase the family. If it changed, rename the file with `git mv` so the history follows
the file instead of showing a delete plus an add:

```bash
git mv _ARCTIC_MONKEYS.version _BLEACHERS.version
```

Then write both lines — family and number — with the new values.

### 5. Write pubspec.yaml

Bump `version:` to `Y.Y.0+<build+1>`, reading the old build number rather than assuming it:
`version: 1.0.0+1` → `version: 2.0.0+2`.

### 6. Write CLAUDE.md

Update the `### Touchstone version : X.Y` line in `blueprint/CLAUDE.md` to the new
version: `### Touchstone version : 1.0` → `### Touchstone version : 2.0`. Keep the
` : ` spacing exactly.

### 7. Commit

Stage only the three version files by path — never `git add blueprint/` or `-A`. The working
tree often carries unrelated in-progress changes (including other edits to `pubspec.yaml`
itself), and this commit must contain the version bump and nothing else:

```bash
git add _BLEACHERS.version blueprint/pubspec.yaml blueprint/CLAUDE.md
git commit -m "chore(touchstone): upgrade to version 2.0 (BLEACHERS)"
```

If `git add` also picks up unrelated edits to `pubspec.yaml` or `CLAUDE.md`, stop and tell
the user rather than committing them by accident — they may want to stash or split first.

For a minor bump within the same family, drop the family from the message:
`chore(touchstone): upgrade to version 1.1`.

### 8. Tag the commit

Tag the commit you just made. The tag is the bare version number — no `v` prefix, matching
the existing tags:

```bash
git tag -a 2.0 -m "Version 2.0 (BLEACHERS)"
```

For a minor bump within the same family, drop the family: `-m "Version 1.1"`.

If the tag already exists, stop and tell the user rather than moving or forcing it — an
existing tag means that version was already released.

Don't push the tag. Leave that to the user.

Report the result to the user: old version → new version, the file rename if there was one,
the commit, and the tag.
