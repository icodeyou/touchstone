import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/controller/home_controller.dart';

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
      overrides: [todoRepositoryProvider.overrideWithValue(repository)],
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
        container.read(homeControllerProvider),
        isA<AsyncLoading<List<Todo>>>(),
      );

      final todos = await container.read(homeControllerProvider.future);

      expect(todos, [todo]);
      expect(container.read(homeControllerProvider).value, [todo]);
    });

    test('exposes error state when fetching fails', () async {
      final container = makeContainer(
        _FakeTodoRepository(error: Exception('network down')),
      );

      await expectLater(
        container.read(homeControllerProvider.future),
        throwsException,
      );
      expect(container.read(homeControllerProvider).hasError, isTrue);
    });

    test('refresh recovers after a failure', () async {
      final repository = _FakeTodoRepository(error: Exception('network down'));
      final container = makeContainer(repository);

      await expectLater(
        container.read(homeControllerProvider.future),
        throwsException,
      );

      repository
        ..error = null
        ..todos = [todo];
      await container.read(homeControllerProvider.notifier).refresh();

      expect(container.read(homeControllerProvider).value, [todo]);
    });
  });
}
