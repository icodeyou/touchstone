import 'package:touchstone/data/local/preferences_store.dart';
import 'package:web/web.dart';

Future<void> initializePreferences() async {}

PreferencesStore createPreferencesStore() => _LocalStoragePreferencesStore();

class _LocalStoragePreferencesStore implements PreferencesStore {
  @override
  bool getBool(String key) => window.localStorage.getItem(key) == 'true';

  @override
  void setBool(String key, {required bool value}) =>
      window.localStorage.setItem(key, '$value');
}
