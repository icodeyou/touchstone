import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/core/log/log.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/entity/todo.dart';

class HomeController extends AsyncNotifier<List<Todo>> {
  static final provider = AsyncNotifierProvider<HomeController, List<Todo>>(
    HomeController.new,
  );

  @override
  Future<List<Todo>> build() => ref.watch(TodoRepository.provider).getTodos();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(TodoRepository.provider).getTodos(),
    );
  }

  Future<void> createTodo(String title) async {
    final created = await ref
        .read(TodoRepository.provider)
        .createTodo(title: title);
    'Todo ${created.id} created'.logInfo;
    state = AsyncData([created, ...?state.value]);
  }

  /// Optimistic flip
  Future<void> toggleTodo(Todo todo) async {
    final todos = state.value;
    if (todos == null) {
      return;
    }
    final newStatus = todo.status == TodoStatus.completed
        ? TodoStatus.pending
        : TodoStatus.completed;
    state = AsyncData([
      for (final item in todos)
        if (item.id == todo.id) item.copyWith(status: newStatus) else item,
    ]);
    try {
      await ref
          .read(TodoRepository.provider)
          .updateTodoStatus(id: todo.id, status: newStatus);
      'Todo ${todo.id} updated to ${newStatus.name}'.logInfo;
    } catch (error, stackTrace) {
      'Failed to update todo ${todo.id}, reverting'.logWarning(
        error: error,
        stackTrace: stackTrace,
      );
      state = AsyncData(todos);
      rethrow;
    }
  }
}
