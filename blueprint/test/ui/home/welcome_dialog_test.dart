import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/core/app/i18n/translations.g.dart';
import 'package:touchstone/data/repository/preferences_repository.dart';
import 'package:touchstone/data/repository/todo_repository.dart';
import 'package:touchstone/domain/model/todo.dart';
import 'package:touchstone/ui/home/view/home_screen.dart';

class _FakeTodoRepository implements TodoRepository {
  @override
  Future<List<Todo>> getTodos() async => [];
}

class _FakePreferencesRepository implements PreferencesRepository {
  _FakePreferencesRepository({this.seen = false});

  bool seen;

  @override
  bool get welcomeMessageSeen => seen;

  @override
  void markWelcomeMessageSeen() => seen = true;
}

Widget _buildApp(_FakePreferencesRepository preferences) {
  return ProviderScope(
    overrides: [
      TodoRepository.provider.overrideWithValue(_FakeTodoRepository()),
      PreferencesRepository.provider.overrideWithValue(preferences),
    ],
    child: TranslationProvider(
      child: const MaterialApp(home: HomeScreen()),
    ),
  );
}

void main() {
  testWidgets('HomeScreen shows the welcome dialog on first launch',
      (tester) async {
    await tester.pumpWidget(_buildApp(_FakePreferencesRepository()));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text(t.welcomeDialog.title), findsOneWidget);
  });

  testWidgets('Tapping OK closes the dialog and records the preference',
      (tester) async {
    final preferences = _FakePreferencesRepository();
    await tester.pumpWidget(_buildApp(preferences));
    await tester.pumpAndSettle();

    await tester.tap(find.text(t.common.ok));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(preferences.seen, isTrue);
  });

  testWidgets('Dismissing the dialog does not record the preference',
      (tester) async {
    final preferences = _FakePreferencesRepository();
    await tester.pumpWidget(_buildApp(preferences));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(5, 5));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
    expect(preferences.seen, isFalse);
  });

  testWidgets('HomeScreen does not show the dialog once acknowledged',
      (tester) async {
    await tester.pumpWidget(_buildApp(_FakePreferencesRepository(seen: true)));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsNothing);
  });
}
