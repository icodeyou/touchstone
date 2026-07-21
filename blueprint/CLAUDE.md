# Title of the app

## Touchstone: The Global Instructions

### Touchstone version : 1.4

### Prerequisites

`.ai/` and `.blueprint/` must both be present before any Claude Code session. At the very start of every session, verify they exist; if either is missing, create it as described in its section below before doing anything else.

### AI guidelines

@.ai/CLAUDE.md : This file contains your default instructions. Read it and apply it all the time.

The `.ai/` folder defines everything AI-related for this app: besides these default instructions, all skills (`.ai/.claude/skills/`) and all Claude settings — permissions and hooks (`.ai/.claude/settings.json`) — are defined there. The app's `.claude/` folder only contains symlinks into `.ai/.claude/` (plus a local `settings.local.json`); never define skills or settings anywhere else.

**Like `.blueprint/`, the `.ai/` folder is a hard prerequisite — it must always be present before any task.** It is a local copy: a snapshot of the touchstone `ai/` folder frozen at the touchstone version above. Before doing anything else, verify it exists. If it does not, you MUST copy it first — and you MUST NOT do anything until it exists. Create it from the touchstone repository (at `../..`) at the git tag matching the touchstone version; this reads the tag's snapshot without checking out or modifying touchstone:

```sh
mkdir -p .ai && git -C ../.. archive <version> ai | tar -x --strip-components=1 -C .ai
```

If `.ai/` cannot be created (touchstone is unavailable or the tag is missing), **stop and refuse to work** — the default instructions, skills and settings all live here.

Add `.ai/` to this project's `.gitignore`; it is a regenerable cache.

### Blueprint conformance

Every time you write code, always make sure the app uses the same practices, architecture, folder structure, naming conventions, dependencies and theming as the reference @.blueprint/.

`@.blueprint/` is a local cache: a snapshot of the touchstone blueprint frozen at the touchstone version above. Always conform to it, never to a live blueprint.

**The `.blueprint/` folder is a hard prerequisite for writing any code.** Before writing or modifying any code, verify it exists. If it does not, you MUST create it first — and you MUST NOT write any code until it exists. Create it from the touchstone repository (at `../..`) at the git tag matching the version above; this reads the tag's snapshot without checking out or modifying touchstone:

```sh
mkdir -p .blueprint && git -C ../.. archive <version> blueprint | tar -x --strip-components=1 -C .blueprint
```

If `.blueprint/` cannot be created (touchstone is unavailable or the tag is missing), **stop and refuse to write code** — there is no valid reference to conform to.

Add `.blueprint/` to this project's `.gitignore`; it is a regenerable cache.

#### Sentry

The app is created **without Sentry**. When conforming to `.blueprint/`, omit all Sentry wiring: the `sentry_flutter` dependency, `lib/core/log/sentry_reporter.dart`, the `SentryReporter` calls in `main.dart` and `log.dart`, and the `AppConstants.sentryDsn` constant. Sentry is added only when the app goes to production, via the `sentry` skill.

## Custom instructions

Write here your custom instructions, concerning this project only.