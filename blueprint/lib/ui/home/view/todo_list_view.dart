import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/app/i18n/translations.g.dart';
import 'package:touchstone/core/theme/app_colors.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/controller/home_controller.dart';

class TodoListView extends ConsumerWidget {
  const TodoListView({required this.todos, super.key});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: todos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final todo = todos[index];
        final isCompleted = todo.status == TodoStatus.completed;
        final mutationState = ref.watch(myMutationControllerProvider(todo.id));
        return ListTile(
          contentPadding: ThemeSizes.sym(h: ThemeSizes.m, v: ThemeSizes.xxs),
          title: AppText.m(
            todo.title,
            color: isCompleted ? AppColors.grey : null,
            textDecoration: isCompleted ? TextDecoration.lineThrough : null,
          ),
          onTap: mutationState == MutationState.loading
              ? null
              : () => _onTodoTap(context, ref, todo),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? ThemeColors.statusSuccess : ThemeColors.grey40,
          ),
        );
      },
    );
  }

  void _onTodoTap(BuildContext context, WidgetRef ref, Todo todo) {
    ref
        .read(myMutationControllerProvider(todo.id).notifier)
        .action<void>(
          mutation: () =>
              ref.read(HomeController.provider.notifier).toggleTodo(todo),
          onError: () {
            if (!context.mounted) {
              return;
            }
            Notif.showToast(
              context: context,
              title: t.common.error,
              message: t.homeScreen.todoUpdateError,
              type: ToastType.error,
            );
          },
        );
  }
}
