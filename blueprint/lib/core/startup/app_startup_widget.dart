import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/i18n/translations.g.dart';
import 'package:touchstone/core/startup/app_startup.dart';

/// Keeps the native splash while [AppStartup] is loading, then removes it and
/// shows either [onLoaded] or an error view with a retry button.
class AppStartupWidget extends ConsumerWidget {
  const AppStartupWidget({super.key, required this.onLoaded});

  final WidgetBuilder onLoaded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupState = ref.watch(AppStartup.futureProvider);
    return startupState.when(
      data: (_) {
        FlutterNativeSplash.remove();
        return onLoaded(context);
      },
      error: (error, stackTrace) {
        FlutterNativeSplash.remove();
        return Scaffold(
          body: AppErrorView(
            errorTitle: t.common.error,
            errorMessage: t.startup.loadError,
            retryButton: (
              label: t.common.retry,
              callback: () => ref.invalidate(AppStartup.futureProvider),
            ),
          ),
        );
      },
      loading: () => const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: AppLoader.regular()),
      ),
    );
  }
}
