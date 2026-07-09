import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/entity/todo.dart';
import 'package:touchstone/ui/home/view/home_screen.dart';

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository({this.todos = const <Todo>[]});

  List<Todo> todos;
  Exception? updateError;
  Completer<void>? createGate;
  Completer<void>? updateGate;
  int updateCalls = 0;
  int createCalls = 0;

  @override
  Future<List<Todo>> getTodos() async => todos;

  @override
  Future<Todo> createTodo({required String title}) async {
    createCalls++;
    final gate = createGate;
    if (gate != null) {
      await gate.future;
    }
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
    updateCalls++;
    final gate = updateGate;
    if (gate != null) {
      await gate.future;
    }
    final currentError = updateError;
    if (currentError != null) {
      throw currentError;
    }
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
  Future<void> pumpHomeScreen(
    WidgetTester tester, {
    _FakeTodoRepository? repository,
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          TodoRepository.provider
              .overrideWithValue(repository ?? _FakeTodoRepository()),
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
      expect(find.text('Please enter a title'), findsNothing);
    });

    testWidgets('submitting an empty field shows an error and does not create',
        (tester) async {
      final repository = _FakeTodoRepository();
      await pumpHomeScreen(tester, repository: repository);

      await tester.tap(find.text('Add an item'));
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
      expect(repository.createCalls, 0);
    });

    testWidgets('submitting a whitespace-only field shows the error',
        (tester) async {
      final repository = _FakeTodoRepository();
      await pumpHomeScreen(tester, repository: repository);

      await tester.enterText(find.byType(TextField), '   ');
      await tester.tap(find.text('Add an item'));
      await tester.pump();

      expect(find.text('Please enter a title'), findsOneWidget);
      expect(repository.createCalls, 0);
    });

    testWidgets('typing clears the empty-field error', (tester) async {
      await pumpHomeScreen(tester);

      await tester.tap(find.text('Add an item'));
      await tester.pump();
      expect(find.text('Please enter a title'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'B');
      await tester.pump();

      expect(find.text('Please enter a title'), findsNothing);
    });

    testWidgets('the field is disabled while the create is in flight',
        (tester) async {
      final repository = _FakeTodoRepository()..createGate = Completer<void>();
      await pumpHomeScreen(tester, repository: repository);

      await tester.enterText(find.byType(TextField), 'Buy milk');
      await tester.tap(find.text('Add an item'));
      await tester.pump();

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isFalse);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Add an item'), findsNothing);

      repository.createGate!.complete();
      await tester.pump();
      // Let the success toast (5s auto-close) expire so no timers leak.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();

      expect(tester.widget<TextField>(find.byType(TextField)).enabled, isTrue);
    });
  });

  group('HomeScreen toggle todo', () {
    const pendingTodo = Todo(
      id: 7,
      userId: 42,
      title: 'Walk the dog',
      status: TodoStatus.pending,
    );

    testWidgets('tapping a pending todo marks it completed', (tester) async {
      final repository = _FakeTodoRepository(todos: [pendingTodo]);
      await pumpHomeScreen(tester, repository: repository);

      await tester.tap(find.text('Walk the dog'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(repository.updateCalls, 1);
    });

    testWidgets('tapping a completed todo marks it pending', (tester) async {
      final repository = _FakeTodoRepository(
        todos: [pendingTodo.copyWith(status: TodoStatus.completed)],
      );
      await pumpHomeScreen(tester, repository: repository);

      await tester.tap(find.text('Walk the dog'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);
    });

    testWidgets('failed update rolls the icon back and shows a toast',
        (tester) async {
      final repository = _FakeTodoRepository(todos: [pendingTodo])
        ..updateError = Exception('network down');
      await pumpHomeScreen(tester, repository: repository);

      await tester.tap(find.text('Walk the dog'));
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Failed to update the todo'), findsOneWidget);
      expect(find.byIcon(Icons.radio_button_unchecked), findsOneWidget);

      // Let the toast (5s auto-close) expire so no timers leak.
      await tester.pump(const Duration(seconds: 6));
      await tester.pumpAndSettle();
    });

    testWidgets('taps are ignored while an update is in flight',
        (tester) async {
      final repository = _FakeTodoRepository(todos: [pendingTodo])
        ..updateGate = Completer<void>();
      await pumpHomeScreen(tester, repository: repository);

      await tester.tap(find.text('Walk the dog'));
      await tester.pump();
      await tester.tap(find.text('Walk the dog'));
      await tester.pump();

      repository.updateGate!.complete();
      await tester.pumpAndSettle();

      expect(repository.updateCalls, 1);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });
  });
}
