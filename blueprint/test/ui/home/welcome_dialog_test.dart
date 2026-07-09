import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touchstone/core/app/i18n/translations.g.dart';
import 'package:touchstone/data/local/preferences_keys.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/view/home_screen.dart';

class _FakeTodoRepository implements TodoRepository {
  @override
  Future<List<Todo>> getTodos() async => [];
}

Widget _buildApp() {
  return ProviderScope(
    overrides: [
      TodoRepository.provider.overrideWithValue(_FakeTodoRepository()),
    ],
    child: TranslationProvider(
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
}

void main() {
  testWidgets('HomeScreen shows the welcome dialog on first launch',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(t.welcomeDialog.title), findsOneWidget);
  });

  testWidgets('Tapping OK closes the dialog and records the preference',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.common.ok));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(PreferencesKeys.welcomeMessageSeen), isTrue);
  });

  testWidgets('Dismissing the dialog does not record the preference',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getBool(PreferencesKeys.welcomeMessageSeen), isNull);
  });

  testWidgets('HomeScreen does not show the dialog once acknowledged',
      (tester) async {
    SharedPreferences.setMockInitialValues({
      PreferencesKeys.welcomeMessageSeen: true,
    });
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
