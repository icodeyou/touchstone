# Title of the app

## Global instructions

### Root file CLAUDE.md

@../../ai/CLAUDE.md : This file contains your default instructions. Read it and apply it all the time.

### Blueprint conformance

Every time you write code, always make sure the app uses the same practices, architecture, folder structure, naming conventions, dependencies and theming as the reference @.blueprint/.

#### Blueprint version : 1.0

`@.blueprint/` is a local cache: a snapshot of the touchstone blueprint frozen at this version. Always conform to it, never to a live blueprint.

**The `.blueprint/` folder is a hard prerequisite for writing any code.** Before writing or modifying any code, verify it exists. If it does not, you MUST create it first — and you MUST NOT write any code until it exists. Create it from the touchstone repository (at `../..`) at the git tag matching the version above; this reads the tag's snapshot without checking out or modifying touchstone:

```
mkdir -p .blueprint && git -C ../.. archive <version> blueprint | tar -x --strip-components=1 -C .blueprint
```

If `.blueprint/` cannot be created (touchstone is unavailable or the tag is missing), **stop and refuse to write code** — there is no valid reference to conform to.

Add `.blueprint/` to this project's `.gitignore`; it is a regenerable cache.

#### Sentry

The app is created **without Sentry**. When conforming to `.blueprint/`, omit all Sentry wiring: the `sentry_flutter` dependency, `lib/core/log/sentry_reporter.dart`, the `SentryReporter` calls in `main.dart` and `log.dart`, and the `AppConstants.sentryDsn` constant. Sentry is added only when the app goes to production, via the `sentry` skill.

## Custom instructions

Write here your custom instructions, concerning this project only.

