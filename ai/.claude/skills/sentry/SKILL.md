---
name: sentry
description: Wire this app to its own Sentry project. Use when the app goes to production — apps are crafted without Sentry.
---

# Adding Sentry to a production-bound app

Apps are created without any Sentry wiring; this skill adds it. It has two
parts: conforming the code to the blueprint reference, and provisioning the
Sentry project. Each Pixelita app gets its own project, in the single shared
Pixelita organization.

## Code

The blueprint contains no Sentry wiring; this skill is the reference. Add:

- the `sentry_flutter` dependency in `pubspec.yaml` (latest version)
- `lib/core/log/sentry_reporter.dart`, copied from
  `references/sentry_reporter.dart` (adapt the `touchstone` package name to
  this app's)
- in `lib/main.dart`, wrap the `runApp` call:

  ```dart
  await SentryReporter.run(
    () => runApp(MyApp(packageInfo: packageInfo)),
    packageInfo.appName,
  );
  ```

- in `lib/core/log/log.dart`, at the end of `_log(...)`, after the `print`:

  ```dart
  SentryReporter.report(
    level.sentryLevel,
    message,
    error: error,
    stackTrace: stackTrace,
  );
  ```

  and a private mapping extension next to the other extensions:

  ```dart
  extension on _Level {
    SentryLevel get sentryLevel => switch (this) {
      _Level.trace || _Level.debug => SentryLevel.debug,
      _Level.info => SentryLevel.info,
      _Level.warning => SentryLevel.warning,
      _Level.error => SentryLevel.error,
      _Level.fatal => SentryLevel.fatal,
    };
  }
  ```

- an `AppConstants.sentryDsn` constant in
  `lib/shared/constants/app_constants.dart`, filled by the provisioning
  steps below

Only the DSN value is app-specific; everything else must match this skill.

## Project provisioning

1. Check that `sentry-cli` is installed. If not, install it:
   `brew install getsentry/tools/sentry-cli`
2. Check authentication with `sentry-cli info`. If not authenticated, ask the
   user to type `! sentry-cli login` (it opens the browser to create the auth
   token), then check again
3. Read the auth token from `~/.sentryclirc`. Never print or commit this token
4. Fetch the organization and team slugs (a single organization and team are
   expected, stop and ask the user otherwise):

   `curl -s -H "Authorization: Bearer <token>" https://sentry.io/api/0/organizations/`

   `curl -s -H "Authorization: Bearer <token>" https://sentry.io/api/0/organizations/<org>/teams/`
5. Create the project, named like the app (the `name` from `pubspec.yaml`):

   `curl -s -X POST -H "Authorization: Bearer <token>" -H "Content-Type: application/json" -d '{"name": "<app_name>", "platform": "flutter"}' https://sentry.io/api/0/teams/<org>/<team>/projects/`
6. Fetch the project DSN and write it into `AppConstants.sentryDsn`:

   `curl -s -H "Authorization: Bearer <token>" https://sentry.io/api/0/projects/<org>/<app_name>/keys/`

   Use the `dsn.public` value of the first key.
7. If any step fails, stop and report the failure to the user; leave
   `AppConstants.sentryDsn` empty

## Verify

Run `flutter pub get` and `dart analyze lib`; both must pass. Remind the user
that reporting is disabled in debug mode: verifying end-to-end requires a
profile or release run.
