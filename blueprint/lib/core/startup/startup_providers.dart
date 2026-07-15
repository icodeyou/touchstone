import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:touchstone/core/app_preferences.dart';
import 'package:touchstone/core/startup/app_startup.dart';

/// Synchronous access to the async dependencies initialized by [AppStartup].
/// Reading one before startup completes throws a [StateError].
class StartupProviders {
  static final appPreferences = Provider<AppPreferences>(
    (ref) => AppPreferences(
      preferences: ref.watch(AppPreferences.futureProvider).requireValue,
    ),
  );

  /// Overridden in `MyApp` with the instance resolved in `main`.
  static final packageInfo = Provider<PackageInfo>(
    (ref) => throw UnimplementedError('packageInfo was not overridden'),
  );
}
