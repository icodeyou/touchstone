import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/i18n/translations.g.dart';
import 'package:touchstone/ui/home/controller/home_controller.dart';

class CreateTodoView extends ConsumerStatefulWidget {
  const CreateTodoView({super.key});

  @override
  ConsumerState<CreateTodoView> createState() => _CreateTodoViewState();
}

class _CreateTodoViewState extends ConsumerState<CreateTodoView> {
  final _controller = TextEditingController();
  String? _errorText;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = t.homeScreen.createTodoEmptyError);
      return;
    }
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
    await ref
        .read(myMutationControllerProvider(hashCode).notifier)
        .action<void>(
          mutation: () =>
              ref.read(HomeController.provider.notifier).createTodo(title),
          onSuccess: (_) => _onCreateSuccess(),
        );
  }

  void _onCreateSuccess() {
    final hasError = ref.read(HomeController.provider).hasError;
    if (!mounted) {
      return;
    }
    if (hasError) {
      Notif.showToast(
        context: context,
        title: t.common.error,
        message: t.homeScreen.loadError,
        type: ToastType.error,
      );
    } else {
      _controller.clear();
      Notif.showToast(
        context: context,
        title: t.common.success,
        message: t.homeScreen.todoCreated,
        type: ToastType.success,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(myMutationControllerProvider(hashCode)) ==
        MutationState.loading;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _controller,
          enabled: !isLoading,
          onChanged: (_) {
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
          decoration: InputDecoration(
            hintText: t.homeScreen.createTodoHint,
            errorText: _errorText,
            border: OutlineInputBorder(
              borderRadius: ThemeRadius.m.asBorderRadius,
              borderSide: BorderSide(color: ThemeColors.secondary(context)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: ThemeRadius.m.asBorderRadius,
              borderSide: BorderSide(color: ThemeColors.secondary(context)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: ThemeRadius.m.asBorderRadius,
              borderSide: BorderSide(
                color: ThemeColors.secondary(context),
                width: 2,
              ),
            ),
          ),
          onSubmitted: (_) => _submit(),
        ),
        const AppGap.s(),
        if (isLoading)
          Center(
            child: CircularProgressIndicator(
              color: ThemeColors.secondary(context),
            ),
          )
        else
          AppButton(
            buttonType: ButtonType.primary,
            expand: true,
            label: t.homeScreen.addItem,
            color: ThemeColors.secondary(context),
            fontColor: ThemeColors.onSecondary(context),
            onPressed: _submit,
          ),
      ],
    );
  }
}
