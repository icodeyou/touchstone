import 'package:mmkv/mmkv.dart';
import 'package:touchstone/data/local/preferences_store.dart';

Future<void> initializePreferences() async {
  await MMKV.initialize();
}

PreferencesStore createPreferencesStore() => _MmkvPreferencesStore();

class _MmkvPreferencesStore implements PreferencesStore {
  final MMKV _mmkv = MMKV.defaultMMKV();

  @override
  bool getBool(String key) => _mmkv.decodeBool(key);

  @override
  void setBool(String key, {required bool value}) =>
      _mmkv.encodeBool(key, value);
}
