import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/shared/widgets/toast/toast_controller.dart';

/// Renders the global toast pill, bottom-center above the screen edge. Never
/// blocks input.
class ToastLayerView extends ConsumerWidget {
  const ToastLayerView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final toast = ref.watch(ToastController.provider);

    return Positioned(
      left: 0,
      right: 0,
      bottom: ThemeSizes.xxxl,
      child: IgnorePointer(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.xl),
            child: AnimatedSwitcher(
              duration: ThemeDurations.xxs,
              switchInCurve: Curves.easeOutBack,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(scale: animation, child: child),
              ),
              child: toast == null
                  ? const SizedBox.shrink()
                  : _ToastPill(
                      key: ValueKey(toast.id),
                      message: toast.message,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ToastPill extends StatelessWidget {
  const _ToastPill({required this.message, super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.m,
        vertical: ThemeSizes.xs,
      ),
      decoration: BoxDecoration(
        color: colors.inverseSurface,
        borderRadius: ThemeRadius.xl.asBorderRadius,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.25),
            blurRadius: ThemeSizes.xl,
            offset: const Offset(0, ThemeSizes.xs),
          ),
        ],
      ),
      child: AppText.s(
        message,
        bold: true,
        color: colors.onInverseSurface,
        textAlign: TextAlign.center,
      ),
    );
  }
}
