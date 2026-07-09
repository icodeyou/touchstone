import 'package:flutter/material.dart';
import 'package:touchstone/core/app/app.dart';
import 'package:touchstone/data/local/preferences_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializePreferences();
  runApp(const MyApp());
}
