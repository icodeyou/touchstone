import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/i18n/translations.g.dart';
import 'package:touchstone/core/riverpod/riverpod_observers.dart';
import 'package:touchstone/core/routing/router.dart';
import 'package:touchstone/core/theme/app_colors.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      observers: [RiverpodObserver()],
      child: TranslationProvider(
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: getSnowflakeThemeData(
            mode: ThemeMode.light,
            appColors: lightColors,
          ),
          routerConfig: router,
        ),
      ),
    );
  }
}
