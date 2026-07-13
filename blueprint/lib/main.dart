import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:touchstone/core/app.dart';
import 'package:touchstone/core/log/sentry_reporter.dart';
import 'package:touchstone/core/startup/startup_providers.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  appPackageInfo = await PackageInfo.fromPlatform();
  await SentryReporter.run(() => runApp(const MyApp()), appPackageInfo.appName);
}
