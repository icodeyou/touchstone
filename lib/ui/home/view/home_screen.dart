import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/app/i18n/translations.g.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/controller/home_controller.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todosState = ref.watch(homeControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(t.homeScreen.todosTitle),
      ),
      body: switch (todosState) {
        AsyncData(:final value) when value.isEmpty => Center(
          child: Text(t.homeScreen.emptyTodos),
        ),
        AsyncData(:final value) => _TodoList(todos: value),
        AsyncError() => _ErrorView(
          onRetry: () => ref.read(homeControllerProvider.notifier).refresh(),
        ),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _TodoList extends StatelessWidget {
  const _TodoList({required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: todos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final todo = todos[index];
        final isCompleted = todo.status == TodoStatus.completed;
        return ListTile(
          title: Text(todo.title),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isCompleted ? Colors.green : Colors.grey,
          ),
        );
      },
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(t.homeScreen.loadError),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: onRetry,
            child: Text(t.common.retry),
          ),
        ],
      ),
    );
  }
}
