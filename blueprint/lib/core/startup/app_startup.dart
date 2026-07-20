import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/log/log.dart';
import 'package:touchstone/core/preferences/app_preferences.dart';
import 'package:touchstone/core/startup/startup_future_providers.dart';

/// Eagerly initializes the app's async dependencies during startup.
class AppStartup {
  static final _futureProviders = <FutureProvider<Object?>>[
    AppPreferences.futureProvider,
    StartupFutureProviders.deviceId,
    // Add your other provider initializations here
  ];

  static final futureProvider = FutureProvider<void>((ref) async {
    await Future.wait(
      _futureProviders.map((dependency) => ref.watch(dependency.future)),
    );
    'App startup completed'.logInfo;
    ref.onDispose(() => _futureProviders.forEach(ref.invalidate));
  }, retry: (retryCount, error) => null);
}
