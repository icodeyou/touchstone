import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/app_preferences.dart';
import 'package:touchstone/core/startup/startup_providers.dart';

/// Eagerly initializes the app's async dependencies during startup.
class AppStartup {
  static final futureProvider = FutureProvider<void>((ref) async {
    await ref.watch(AppPreferences.futureProvider.future);
    await ref.watch(StartupFutureProviders.packageInfo.future);
    //throw StateError('Test startup failure');
    ref.onDispose(() {
      ref.invalidate(AppPreferences.futureProvider);
      ref.invalidate(StartupFutureProviders.packageInfo);
    });
  }, retry: (retryCount, error) => null);
}
