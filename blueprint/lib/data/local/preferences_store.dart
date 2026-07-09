import 'package:touchstone/data/local/preferences_store_io.dart'
    if (dart.library.js_interop) 'package:touchstone/data/local/preferences_store_web.dart'
    as impl;

/// Key-value storage for user preferences.
///
/// Backed by MMKV on native platforms and localStorage on the web.
abstract interface class PreferencesStore {
  static final provider = impl.preferencesStoreProvider;

  bool getBool(String key);

  void setBool(String key, {required bool value});
}

/// Must be called once before reading [PreferencesStore.provider], before
/// running the app.
Future<void> initializePreferences() => impl.initializePreferences();
