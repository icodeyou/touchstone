import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
import 'package:touchstone/core/app/i18n/translations.g.dart';
import 'package:touchstone/data/local/preferences_keys.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/view/home_screen.dart';

class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository(this.todos);

  final List<Todo> todos;

  @override
  Future<List<Todo>> getTodos() async => todos;
}

void main() {
  testWidgets('HomeScreen shows a loader then the todo list', (tester) async {
    SharedPreferences.setMockInitialValues({
      PreferencesKeys.welcomeMessageSeen: true,
    });
    const todos = [
      Todo(id: 1, userId: 42, title: 'Buy milk', status: TodoStatus.pending),
      Todo(id: 2, userId: 42, title: 'Ship app', status: TodoStatus.completed),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          TodoRepository.provider.overrideWithValue(
            _FakeTodoRepository(todos),
          ),
        ],
        child: TranslationProvider(
          child: const MaterialApp(home: HomeScreen()),
        ),
      ),
    );

    expect(find.byType(AppLoader), findsOneWidget);

    await tester.pump();
    await tester.pump();

    expect(find.text('Buy milk'), findsOneWidget);
    expect(find.text('Ship app'), findsOneWidget);
    expect(find.byType(AppLoader), findsNothing);
  });
}
