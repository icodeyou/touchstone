import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/app.dart';
import 'package:touchstone/core/app_preferences.dart';
import 'package:touchstone/core/riverpod/riverpod_observers.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  final container = ProviderContainer(observers: [RiverpodObserver()]);
  await container.read(AppPreferences.futureProvider.future);

  runApp(UncontrolledProviderScope(container: container, child: const MyApp()));
  FlutterNativeSplash.remove();
}
