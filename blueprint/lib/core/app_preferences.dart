import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchstone/shared/constants/pref_keys.dart';

/// User preferences, persisted with [SharedPreferences].
class AppPreferences {
  AppPreferences({required SharedPreferences preferences})
    : _preferences = preferences;

  static final futureProvider = FutureProvider<SharedPreferences>(
    (ref) => SharedPreferences.getInstance(),
    retry: (retryCount, error) => null,
  );

  static final provider = Provider<AppPreferences>(
    (ref) =>
        AppPreferences(preferences: ref.watch(futureProvider).requireValue),
  );

  final SharedPreferences _preferences;

  bool get welcomeMessageSeen =>
      _preferences.getBool(PrefKeys.welcomeMessageSeen) ?? false;

  Future<void> markWelcomeMessageSeen() =>
      _preferences.setBool(PrefKeys.welcomeMessageSeen, true);
}
