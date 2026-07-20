import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/i18n/translations.g.dart';
import 'package:touchstone/core/riverpod/riverpod_observers.dart';
import 'package:touchstone/core/routing/router.dart';
import 'package:touchstone/core/startup/app_startup_widget.dart';
import 'package:touchstone/core/startup/startup_providers.dart';
import 'package:touchstone/core/theme/app_colors.dart';
import 'package:touchstone/shared/constants/app_constants.dart';

class MyApp extends StatelessWidget {
  const MyApp({required this.packageInfo, super.key});

  final PackageInfo packageInfo;

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      observers: [RiverpodObserver()],
      overrides: [StartupProviders.packageInfo.overrideWithValue(packageInfo)],
      child: TranslationProvider(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: getSnowflakeThemeData(
            mode: ThemeMode.light,
            appColors: lightColors,
          ),
          routerConfig: router,
          builder: (_, child) =>
              PhoneFrame(child: AppStartupWidget(onLoaded: (_) => child!)),
        ),
      ),
    );
  }
}

/// Caps the app width to an iPhone portrait aspect ratio, so wide viewports
/// (web, desktop) render the app as a centered phone-shaped column.
class PhoneFrame extends StatelessWidget {
  const PhoneFrame({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxHeight * AppConstants.iphoneAspectRatio;
        if (constraints.maxWidth <= maxWidth) {
          return child;
        }
        return ColoredBox(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: SizedBox(
              width: maxWidth,
              child: MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(maxWidth, constraints.maxHeight),
                ),
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}
