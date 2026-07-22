import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/log/log.dart';
import 'package:touchstone/core/preferences/app_preferences.dart';
import 'package:touchstone/core/startup/startup_future_providers.dart';

/// Eagerly initializes the app's async dependencies during startup.
class AppStartup {
  static final _futureProviders = <FutureProvider<Object?>>[
    AppPreferences.futureProvider,
    StartupFutureProviders.deviceId,
    // [BLUEPRINT COMMENT] : Add your other Future providers here
  ];

  /// Those providers are kept alive
  static final _simpleProviders = <Provider<Object?>>[
    // [BLUEPRINT COMMENT] : Add your providers here
  ];

  static final futureProvider = FutureProvider<void>((ref) async {
    await Future.wait(
      _futureProviders.map((dependency) => ref.watch(dependency.future)),
    );
    _simpleProviders.map((p) => ref.watch(p));
    await _init(ref);
    'App startup completed'.logInfo;
    ref.onDispose(() => _futureProviders.forEach(ref.invalidate));
  }, retry: (retryCount, error) => null);

  /// Any task (async or not) that needs to be done during app initialization
  static Future<void> _init(Ref ref) async {
    // [BLUEPRINT COMMENT] Add your init tasks here
  }
}
