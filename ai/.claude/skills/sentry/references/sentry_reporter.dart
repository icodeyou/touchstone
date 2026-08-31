import 'package:flutter/foundation.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:touchstone/shared/constants/app_constants.dart';

/// Reports logs to Sentry. Each Pixelita app has its own Sentry project in
/// the shared organization, provisioned by the `sentry` skill when the app
/// goes to production. Events carry an `app` tag and an app-name fingerprint
/// suffix so they stay correctly separated even if several apps ever point
/// at one project.
///
/// Disabled in debug mode and when [AppConstants.sentryDsn] is empty.
class SentryReporter {
  const SentryReporter._();

  static bool _enabled = false;

  static Future<void> run(VoidCallback appRunner, String appName) async {
    if (AppConstants.sentryDsn.isEmpty) {
      appRunner();
      return;
    }

    await SentryFlutter.init((options) {
      options
        ..dsn = AppConstants.sentryDsn
        ..environment = kReleaseMode ? 'production' : 'profile'
        ..beforeSend = (event, hint) {
          event.fingerprint = ['{{ default }}', appName];
          return event;
        };
    }, appRunner: appRunner);
    _enabled = true;

    await Sentry.configureScope((scope) => scope.setTag('app', appName));
  }

  /// Every log becomes a breadcrumb, attached to the next event; error and
  /// fatal logs additionally become events of their own.
  static void report(
    SentryLevel level,
    Object? message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) {
      return;
    }

    Sentry.addBreadcrumb(
      Breadcrumb(message: '$message', level: level, category: 'log'),
    );

    if (level != SentryLevel.error && level != SentryLevel.fatal) {
      return;
    }
    if (error != null) {
      Sentry.captureException(error, stackTrace: stackTrace);
    } else {
      Sentry.captureMessage('$message', level: level);
    }
  }
}
