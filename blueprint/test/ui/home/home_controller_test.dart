import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/entity/todo.dart';
import 'package:touchstone/presentation/home/controller/home_controller.dart';

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository({this.todos, this.error});

  List<Todo>? todos;
  Exception? error;

  @override
  Future<List<Todo>> getTodos() async {
    final currentError = error;
    if (currentError != null) {
      throw currentError;
    }
    return todos ?? <Todo>[];
  }

  @override
  Future<Todo> createTodo({required String title}) async {
    final currentError = error;
    if (currentError != null) {
      throw currentError;
    }
    final todo = Todo(
      id: 1,
      userId: 42,
      title: title,
      status: TodoStatus.pending,
    );
    todos = [...?todos, todo];
    return todo;
  }

  @override
  Future<Todo> updateTodoStatus({
    required int id,
    required TodoStatus status,
  }) async {
    final currentError = error;
    if (currentError != null) {
      throw currentError;
    }
    final updated = todos!
        .firstWhere((todo) => todo.id == id)
        .copyWith(status: status);
    todos = [
      for (final todo in todos!)
        if (todo.id == id) updated else todo,
    ];
    return updated;
  }
}

void main() {
  const todo = Todo(
    id: 1,
    userId: 42,
    title: 'Write tests',
    status: TodoStatus.pending,
  );

  ProviderContainer makeContainer(TodoRepository repository) {
    final container = ProviderContainer(
      overrides: [TodoRepository.provider.overrideWithValue(repository)],
      // Riverpod 3 retries failed providers with backoff by default, which
      // would keep the error-path futures pending forever in tests.
      retry: (retryCount, error) => null,
    );
    addTearDown(container.dispose);
    return container;
  }

  group('HomeController', () {
    test('loads todos on init', () async {
      final container = makeContainer(_FakeTodoRepository(todos: [todo]));

      expect(
        container.read(HomeController.provider),
        isA<AsyncLoading<List<Todo>>>(),
      );

      final todos = await container.read(HomeController.provider.future);

      expect(todos, [todo]);
      expect(container.read(HomeController.provider).value, [todo]);
    });

    test('exposes error state when fetching fails', () async {
      final container = makeContainer(
        _FakeTodoRepository(error: Exception('network down')),
      );

      await expectLater(
        container.read(HomeController.provider.future),
        throwsException,
      );
      expect(container.read(HomeController.provider).hasError, isTrue);
    });

    test('refresh recovers after a failure', () async {
      final repository = _FakeTodoRepository(error: Exception('network down'));
      final container = makeContainer(repository);

      await expectLater(
        container.read(HomeController.provider.future),
        throwsException,
      );

      repository
        ..error = null
        ..todos = [todo];
      await container.read(HomeController.provider.notifier).refresh();

      expect(container.read(HomeController.provider).value, [todo]);
    });

    group('toggleTodo', () {
      test('optimistically completes a pending todo', () async {
        final repository = _FakeTodoRepository(todos: [todo]);
        final container = makeContainer(repository);
        await container.read(HomeController.provider.future);

        final future = container
            .read(HomeController.provider.notifier)
            .toggleTodo(todo);

        // State is already flipped before the repository call resolves.
        expect(
          container.read(HomeController.provider).value?.single.status,
          TodoStatus.completed,
        );

        await future;
        expect(
          container.read(HomeController.provider).value?.single.status,
          TodoStatus.completed,
        );
      });

      test('toggles a completed todo back to pending', () async {
        final completed = todo.copyWith(status: TodoStatus.completed);
        final repository = _FakeTodoRepository(todos: [completed]);
        final container = makeContainer(repository);
        await container.read(HomeController.provider.future);

        await container
            .read(HomeController.provider.notifier)
            .toggleTodo(completed);

        expect(
          container.read(HomeController.provider).value?.single.status,
          TodoStatus.pending,
        );
      });

      test('rolls back and rethrows when the update fails', () async {
        final repository = _FakeTodoRepository(todos: [todo]);
        final container = makeContainer(repository);
        await container.read(HomeController.provider.future);

        repository.error = Exception('network down');

        await expectLater(
          container.read(HomeController.provider.notifier).toggleTodo(todo),
          throwsException,
        );
        expect(
          container.read(HomeController.provider).value?.single.status,
          TodoStatus.pending,
        );
      });
    });
  });
}
