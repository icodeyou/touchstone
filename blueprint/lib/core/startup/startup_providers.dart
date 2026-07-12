import 'package:flutter_riverpod/flutter_riverpod.dart';
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
}

class StartupFutureProviders {}
