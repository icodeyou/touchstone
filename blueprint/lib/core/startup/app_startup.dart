import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/app_preferences.dart';
import 'package:touchstone/core/log/log.dart';
import 'package:touchstone/core/startup/startup_future_providers.dart';

/// Eagerly initializes the app's async dependencies during startup.
class AppStartup {
  static final futureProvider = FutureProvider<void>((ref) async {
    final dependencies = <Future<Object>>[
      ref.watch(AppPreferences.futureProvider.future),
      ref.watch(StartupFutureProviders.deviceId.future),
    ];
    await Future.wait(dependencies);
    'App startup completed'.logInfo;
    ref.onDispose(() {
      ref.invalidate(AppPreferences.futureProvider);
      ref.invalidate(StartupFutureProviders.deviceId);
    });
  }, retry: (retryCount, error) => null);
}
