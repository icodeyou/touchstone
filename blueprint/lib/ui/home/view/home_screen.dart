import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/app_preferences.dart';
import 'package:touchstone/core/i18n/translations.g.dart';
import 'package:touchstone/ui/home/controller/home_controller.dart';
import 'package:touchstone/ui/home/view/create_todo_view.dart';
import 'package:touchstone/ui/home/view/todo_list_view.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<void> _showWelcomeDialog(BuildContext context, WidgetRef ref) async {
    final preferences = ref.read(AppPreferences.provider);
    if (await preferences.welcomeMessageSeen) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    final confirmed = await Notif.showPopup(
      context: context,
      title: t.welcomeDialog.title,
      content: AppText.m(t.welcomeDialog.message),
      confirmButtonText: t.common.ok,
    );
    if (confirmed) {
      await preferences.markWelcomeMessageSeen();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosState = ref.watch(HomeController.provider);

    return Init(
      onInitPostFrame: () => _showWelcomeDialog(context, ref),
      child: Scaffold(
        appBar: AppBar(title: AppText.l(t.homeScreen.todosTitle, bold: true)),
        body: Padding(
          padding: ThemeSizes.m.asInsets,
          child: Column(
            children: [
              const CreateTodoView(),
              const AppGap.m(),
              Expanded(
                child: todosState.when(
                  data: (todos) => todos.isEmpty
                      ? Center(child: AppText.m(t.homeScreen.emptyTodos))
                      : TodoListView(todos: todos),
                  error: (error, stackTrace) => AppErrorView(
                    errorTitle: t.common.error,
                    errorMessage: t.homeScreen.loadError,
                    retryButton: (
                      label: t.common.retry,
                      callback: () =>
                          ref.read(HomeController.provider.notifier).refresh(),
                    ),
                  ),
                  loading: () => const Center(child: AppLoader.regular()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
