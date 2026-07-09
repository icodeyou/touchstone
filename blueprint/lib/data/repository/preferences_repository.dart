import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/data/local/preferences_store.dart';

class PreferencesRepository {
  PreferencesRepository({required PreferencesStore store}) : _store = store;

  static final provider = Provider<PreferencesRepository>(
    (ref) => PreferencesRepository(store: createPreferencesStore()),
  );

  static const _welcomeMessageSeenKey = 'welcomeMessageSeen';

  final PreferencesStore _store;

  bool get welcomeMessageSeen => _store.getBool(_welcomeMessageSeenKey);

  void markWelcomeMessageSeen() =>
      _store.setBool(_welcomeMessageSeenKey, value: true);
}
