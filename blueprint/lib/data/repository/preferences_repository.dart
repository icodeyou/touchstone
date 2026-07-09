import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/data/local/preferences_keys.dart';
import 'package:touchstone/data/local/preferences_store.dart';

class PreferencesRepository {
  PreferencesRepository({required PreferencesStore store}) : _store = store;

  static final provider = Provider<PreferencesRepository>(
    (ref) =>
        PreferencesRepository(store: ref.watch(PreferencesStore.provider)),
  );

  final PreferencesStore _store;

  bool get welcomeMessageSeen =>
      _store.getBool(PreferencesKeys.welcomeMessageSeen);

  void markWelcomeMessageSeen() =>
      _store.setBool(PreferencesKeys.welcomeMessageSeen, value: true);
}
