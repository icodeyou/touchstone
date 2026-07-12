import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/app_preferences.dart';

/// Eagerly initializes the app's async dependencies during startup.
class AppStartup {
  static final futureProvider = FutureProvider<void>((ref) async {
    await ref.watch(AppPreferences.futureProvider.future);
    //throw StateError('Test startup failure');
    ref.onDispose(() => ref.invalidate(AppPreferences.futureProvider));
  });
}
