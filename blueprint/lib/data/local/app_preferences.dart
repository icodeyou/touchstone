import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchstone/data/local/preferences_keys.dart';

/// User preferences, persisted with [SharedPreferences].
class AppPreferences {
  static final provider = Provider<AppPreferences>((ref) => AppPreferences());

  Future<bool> get welcomeMessageSeen async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(PreferencesKeys.welcomeMessageSeen) ?? false;
  }

  Future<void> markWelcomeMessageSeen() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(PreferencesKeys.welcomeMessageSeen, true);
  }
}
