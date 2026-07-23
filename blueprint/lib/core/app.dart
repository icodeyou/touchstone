import 'package:flutter/foundation.dart';
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
import 'package:touchstone/shared/widgets/toast/toast_layer_view.dart';

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
          builder: (_, child) => PhoneFrame(
            child: AppStartupWidget(
              onLoaded: (_) => Stack(
                fit: StackFit.expand,
                children: [
                  child!,
                  // The toast lives above the Navigator, outside any Material:
                  // give it one so text renders with the default style.
                  const Material(
                    type: MaterialType.transparency,
                    child: ToastLayerView(),
                  ),
                ],
              ),
            ),
          ),
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

  static const double _rim = ThemeSizes.xxxs;
  static const double _bezel = ThemeSizes.xs;
  static const double _margin = ThemeSizes.xl;
  static const double _verticalMargin = _margin / 5;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenHeight =
            constraints.maxHeight - 2 * (_verticalMargin + _rim + _bezel);
        final screenWidth = screenHeight * AppConstants.iphoneAspectRatio;
        final framed =
            screenHeight > 0 &&
            constraints.maxWidth >= screenWidth + 2 * (_margin + _rim + _bezel);
        if (!framed) {
          return child;
        }
        return DecoratedBox(
          decoration: kIsWeb
              ? const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(AppConstants.webBackgroundAsset),
                    fit: BoxFit.cover,
                  ),
                )
              : BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: _verticalMargin),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.white, Colors.white38, Colors.white],
                  ),
                  borderRadius: ThemeRadius.xl.asBorderRadius,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: ThemeSizes.xxl,
                      offset: const Offset(0, ThemeSizes.m),
                    ),
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.25),
                      blurRadius: ThemeSizes.l,
                    ),
                  ],
                ),
                padding: _rim.asInsets,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: ThemeRadius.xl.asBorderRadius,
                  ),
                  padding: _bezel.asInsets,
                  child: ClipRRect(
                    borderRadius: ThemeRadius.l.asBorderRadius,
                    child: SizedBox(
                      width: screenWidth,
                      height: screenHeight,
                      child: MediaQuery(
                        data: MediaQuery.of(
                          context,
                        ).copyWith(size: Size(screenWidth, screenHeight)),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
