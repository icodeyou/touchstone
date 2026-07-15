import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:touchstone/core/app.dart';
import 'package:touchstone/core/log/sentry_reporter.dart';

Future<void> main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  final packageInfo = await PackageInfo.fromPlatform();
  await SentryReporter.run(
    () => runApp(MyApp(packageInfo: packageInfo)),
    packageInfo.appName,
  );
}
