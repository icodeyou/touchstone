import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchstone/core/startup/startup_providers.dart';
import 'package:touchstone/shared/constants/pref_keys.dart';

/// User preferences, persisted with [SharedPreferences].
/// Provider is located in [StartupProviders]
class AppPreferences {
  AppPreferences({required SharedPreferences preferences})
    : _preferences = preferences;

  static final futureProvider = FutureProvider<SharedPreferences>(
    (ref) => SharedPreferences.getInstance(),
    retry: (retryCount, error) => null,
  );

  final SharedPreferences _preferences;

  bool get welcomeMessageSeen =>
      _preferences.getBool(PrefKeys.welcomeMessageSeen) ?? false;

  Future<void> markWelcomeMessageSeen() =>
      _preferences.setBool(PrefKeys.welcomeMessageSeen, true);
}
