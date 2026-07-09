import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/view/home_screen.dart';

class _FakeTodoRepository implements TodoRepository {
  List<Todo> todos = <Todo>[];

  @override
  Future<List<Todo>> getTodos() async => todos;

  @override
  Future<Todo> createTodo({required String title}) async {
    final todo = Todo(
      id: 1,
      userId: 42,
      title: title,
      status: TodoStatus.pending,
    );
    todos = [...todos, todo];
    return todo;
  }

  @override
  Future<Todo> updateTodoStatus({
    required int id,
    required TodoStatus status,
  }) async {
    final updated = todos
        .firstWhere((todo) => todo.id == id)
        .copyWith(status: status);
    todos = [
      for (final todo in todos)
        if (todo.id == id) updated else todo,
    ];
    return updated;
  }
}

void main() {
  Future<void> pumpHomeScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          TodoRepository.provider.overrideWithValue(_FakeTodoRepository()),
        ],
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('HomeScreen create todo', () {
    testWidgets('shows the empty state initially', (tester) async {
      await pumpHomeScreen(tester);

      expect(find.text('No todos found'), findsOneWidget);
    });

    testWidgets('submitting the field creates the todo', (tester) async {
      await pumpHomeScreen(tester);

      await tester.enterText(find.byType(TextField), 'Buy milk');
      await tester.tap(find.text('Add an item'));
      await tester.pump();
      // Let the success toast (5s auto-close) expire so no timers leak.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(find.text('Buy milk'), findsOneWidget);
    });
  });
}
