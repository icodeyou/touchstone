import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchstone/core/app_preferences.dart';
import 'package:touchstone/core/i18n/translations.g.dart';
import 'package:touchstone/core/startup/startup_providers.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/entity/todo.dart';
import 'package:touchstone/shared/constants/pref_keys.dart';
import 'package:touchstone/ui/home/view/home_screen.dart';

class _FakeTodoRepository implements TodoRepository {
  List<Todo> todos = const <Todo>[];

  @override
  Future<List<Todo>> getTodos() async => todos;

  @override
  Future<Todo> createTodo({required String title}) async {
    final todo = Todo(
      id: todos.length + 1,
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

Future<Widget> _buildApp() async {
  final preferences = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      TodoRepository.provider.overrideWithValue(_FakeTodoRepository()),
      AppPreferences.futureProvider.overrideWithValue(
        AsyncValue.data(preferences),
      ),
      StartupFutureProviders.packageInfo.overrideWithValue(
        AsyncValue.data(
          PackageInfo(
            appName: 'touchstone',
            packageName: 'com.example.touchstone',
            version: '1.0.0',
            buildNumber: '1',
          ),
        ),
      ),
    ],
    child: TranslationProvider(child: const MaterialApp(home: HomeScreen())),
  );
}

void main() {
  testWidgets('HomeScreen shows the welcome dialog on first launch', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(t.welcomeDialog.title), findsOneWidget);
  });

  testWidgets('Tapping OK closes the dialog and records the preference', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.common.ok));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(PrefKeys.welcomeMessageSeen), isTrue);
  });

  testWidgets('Dismissing the dialog does not record the preference', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(PrefKeys.welcomeMessageSeen), isNull);
  });

  testWidgets('HomeScreen does not show the dialog once acknowledged', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({PrefKeys.welcomeMessageSeen: true});
    await tester.pumpWidget(await _buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
