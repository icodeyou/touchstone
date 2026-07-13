import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/app_preferences.dart';
import 'package:touchstone/core/log/log.dart';

/// Eagerly initializes the app's async dependencies during startup.
class AppStartup {
  static final futureProvider = FutureProvider<void>((ref) async {
    await ref.watch(AppPreferences.futureProvider.future);
    throw StateError('This is a test for Sentry');
    throw StateError('Test startup failure');
    'App startup completed'.logInfo;
    ref.onDispose(() {
      ref.invalidate(AppPreferences.futureProvider);
    });
  }, retry: (retryCount, error) => null);
}
