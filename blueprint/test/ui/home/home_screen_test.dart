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

  group('HomeScreen create todo popup', () {
    testWidgets('dismissing the popup does not crash', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.byType(TextField), findsOneWidget);

      // Dismiss by tapping the barrier, then let the exit animation finish.
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsNothing);
    });

    testWidgets('confirming creates the todo', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Buy milk');
      await tester.tap(find.text('Create'));
      await tester.pumpAndSettle();

      expect(find.text('Buy milk'), findsOneWidget);
    });
  });
}
