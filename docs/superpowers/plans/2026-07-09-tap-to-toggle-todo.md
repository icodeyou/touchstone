# Tap-to-Toggle Todo Completion Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tapping a todo row in the home list toggles its status (pending ↔ completed) on the GoRest API with an optimistic UI update and rollback on failure.

**Architecture:** Follows the app's existing layering: `TodoApiClient` (HTTP) → `TodoRepository` (passthrough) → `HomeController` (AsyncNotifier, optimistic state) → `HomeScreen` (UI). The tap runs through snowflake's `MutationController` (`myMutationControllerProvider`, keyed per todo id) — **not** `MutationWidget` — so no loader is shown and the optimistic flip stays visible.

**Tech Stack:** Flutter, flutter_riverpod 3, snowflake_flutter_theme 1.5.5 (exports `MutationController`/`MutationState`), http, dart_mappable, slang (i18n codegen).

**Spec:** `docs/superpowers/specs/2026-07-09-tap-to-toggle-todo-design.md`

## Global Constraints

- All commands run from `blueprint/` (the Flutter app root): `/Users/mb/orca/workspaces/touchstone/blueprint-post-request/blueprint`
- `blueprint/.blueprint/` must exist before writing code (already verified present). Conform to its practices.
- API: `PATCH https://gorest.co.in/public/v2/todos/<ID>` with body `{"status": "completed"|"pending"}`; success is HTTP 200. Never POST, never the value `"done"` (GoRest rejects both).
- Project CLAUDE.md commit rule: this is a multi-commit task, so every commit message is prefixed with `@`, e.g. `@feat(home): …`.
- Lints come from `package:snowflake_flutter_theme/analysis_options.yaml` (includes `implementation_imports`, `unawaited_futures`). Import mutation APIs from the package barrel `package:snowflake_flutter_theme/snowflake_flutter_theme.dart` only.
- i18n: every new key goes in **all four** locale files (`en`, `es`, `fr`, `it` `.i18n.yaml`), then regenerate with `dart run slang`.

---

### Task 1: Repair stale HomeScreen widget tests (green baseline)

The two tests in `test/ui/home/home_screen_test.dart` still describe the old FAB+popup UI; the screen now has an inline `TextField` + "Add an item" `MutationButton`. They fail on `main` today (baseline: `flutter test` → `+4 -2`). Rewrite them to match the current UI so the suite is green before feature work.

**Files:**
- Modify: `blueprint/test/ui/home/home_screen_test.dart`

**Interfaces:**
- Consumes: current `HomeScreen` UI (`lib/ui/home/view/home_screen.dart`), `_FakeTodoRepository` already in the test file.
- Produces: a green `flutter test` baseline; the same fake-repository pattern Task 2 extends.

- [ ] **Step 1: Rewrite the stale group**

Replace the whole `group('HomeScreen create todo popup', …)` block (lines 40–67) with:

```dart
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
```

- [ ] **Step 2: Run the suite to verify it is green**

Run: `flutter test`
Expected: all tests pass (`+6` or similar, `-0`). If the toast keeps a timer pending, increase the post-tap pump to `const Duration(seconds: 8)`.

- [ ] **Step 3: Commit**

```bash
git add test/ui/home/home_screen_test.dart
git commit -m "@test(home): update widget tests for inline create field"
```

---

### Task 2: `updateTodoStatus` in API client and repository

No API-client test layer exists in this app (per spec, behavior is covered through controller/widget tests with fakes); this task is verified by `flutter analyze` + the suite staying green. Both test fakes `implements TodoRepository`, so they must gain the new method in the same task to keep compiling.

**Files:**
- Modify: `blueprint/lib/data/api/todo_api_client.dart` (add method after `createTodo`)
- Modify: `blueprint/lib/data/repository/todo_repository.dart` (add method after `createTodo`)
- Modify: `blueprint/test/ui/home/home_controller_test.dart` (extend `_FakeTodoRepository`)
- Modify: `blueprint/test/ui/home/home_screen_test.dart` (extend `_FakeTodoRepository`)

**Interfaces:**
- Consumes: existing `_headers`, `AppConstants.goRestBaseUrl`, `Todo`, `TodoStatus.toValue()` (dart_mappable enum encoding: `'pending'`/`'completed'`).
- Produces: `Future<Todo> TodoApiClient.updateTodoStatus({required int id, required TodoStatus status})` and `Future<Todo> TodoRepository.updateTodoStatus({required int id, required TodoStatus status})` — Task 3 calls the repository method.

- [ ] **Step 1: Add the API client method**

In `todo_api_client.dart`, after `createTodo`:

```dart
  Future<Todo> updateTodoStatus({
    required int id,
    required TodoStatus status,
  }) async {
    final uri = Uri.parse('${AppConstants.goRestBaseUrl}/todos/$id');
    final response = await _client.patch(
      uri,
      headers: _headers,
      body: jsonEncode({'status': status.toValue()}),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'PATCH /todos/$id failed (${response.statusCode})',
        uri: uri,
      );
    }
    return Todo.fromMap(jsonDecode(response.body) as Map<String, Object?>);
  }
```

- [ ] **Step 2: Add the repository passthrough**

In `todo_repository.dart`, after `createTodo`:

```dart
  Future<Todo> updateTodoStatus({required int id, required TodoStatus status}) =>
      _apiClient.updateTodoStatus(id: id, status: status);
```

- [ ] **Step 3: Extend both test fakes**

In `test/ui/home/home_controller_test.dart`, add to `_FakeTodoRepository` (after `createTodo`):

```dart
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
```

In `test/ui/home/home_screen_test.dart`, add to `_FakeTodoRepository` (after `createTodo`):

```dart
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
```

- [ ] **Step 4: Verify analyze and tests are green**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues, all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/data/api/todo_api_client.dart lib/data/repository/todo_repository.dart test/ui/home/home_controller_test.dart test/ui/home/home_screen_test.dart
git commit -m "@feat(data): add updateTodoStatus PATCH endpoint"
```

---

### Task 3: `HomeController.toggleTodo` with optimistic update (TDD)

**Files:**
- Modify: `blueprint/test/ui/home/home_controller_test.dart` (new test group)
- Modify: `blueprint/lib/ui/home/controller/home_controller.dart`

**Interfaces:**
- Consumes: `TodoRepository.updateTodoStatus` (Task 2), `Todo.copyWith` (dart_mappable).
- Produces: `Future<void> HomeController.toggleTodo(Todo todo)` — flips `pending` ↔ `completed`, emits optimistically, rolls back and **rethrows** on failure (the rethrow is what routes to `MutationController`'s `onError` in Task 5). No-op when state has no data.

- [ ] **Step 1: Write the failing tests**

Add inside `main()`'s `group('HomeController', …)` in `home_controller_test.dart`:

```dart
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
```

- [ ] **Step 2: Run tests to verify they fail**

Run: `flutter test test/ui/home/home_controller_test.dart`
Expected: FAIL — `The method 'toggleTodo' isn't defined for the type 'HomeController'`.

- [ ] **Step 3: Implement `toggleTodo`**

In `home_controller.dart`, after `createTodo`:

```dart
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
    } catch (_) {
      state = AsyncData(todos);
      rethrow;
    }
  }
```

- [ ] **Step 4: Run tests to verify they pass**

Run: `flutter test test/ui/home/home_controller_test.dart`
Expected: PASS (all controller tests).

- [ ] **Step 5: Commit**

```bash
git add lib/ui/home/controller/home_controller.dart test/ui/home/home_controller_test.dart
git commit -m "@feat(home): add optimistic toggleTodo to controller"
```

---

### Task 4: `todoUpdateError` i18n key (all four locales)

**Files:**
- Modify: `blueprint/lib/core/app/i18n/en.i18n.yaml`
- Modify: `blueprint/lib/core/app/i18n/es.i18n.yaml`
- Modify: `blueprint/lib/core/app/i18n/fr.i18n.yaml`
- Modify: `blueprint/lib/core/app/i18n/it.i18n.yaml`
- Regenerate: `blueprint/lib/core/app/i18n/translations.g.dart` (via `dart run slang`, never by hand)

**Interfaces:**
- Produces: `t.homeScreen.todoUpdateError` — Task 5's error toast message. English copy (exact): `Failed to update the todo`.

- [ ] **Step 1: Add the key under `homeScreen` in each locale**

Key name is exactly `todoUpdateError`, placed after `loadError` in every file:

`en.i18n.yaml`:

```yaml
  todoUpdateError: Failed to update the todo
```

`es.i18n.yaml`:

```yaml
  todoUpdateError: No se pudo actualizar la tarea
```

`fr.i18n.yaml`:

```yaml
  todoUpdateError: Échec de la mise à jour de la tâche
```

`it.i18n.yaml`:

```yaml
  todoUpdateError: Impossibile aggiornare l'attività
```

- [ ] **Step 2: Regenerate translations**

Run: `dart run slang`
Expected: `translations.g.dart` regenerated; `grep todoUpdateError lib/core/app/i18n/translations.g.dart` finds getters for all four locales.

- [ ] **Step 3: Verify analyze and tests stay green**

Run: `flutter analyze && flutter test`
Expected: clean.

- [ ] **Step 4: Commit**

```bash
git add lib/core/app/i18n/
git commit -m "@feat(i18n): add todoUpdateError translations"
```

---

### Task 5: Tap-to-toggle UI via MutationController (TDD)

**Files:**
- Modify: `blueprint/test/ui/home/home_screen_test.dart` (new test group + seedable fake)
- Modify: `blueprint/lib/ui/home/view/home_screen.dart` (`_TodoList`)

**Interfaces:**
- Consumes: `HomeController.toggleTodo` (Task 3), `t.homeScreen.todoUpdateError` (Task 4), `myMutationControllerProvider` / `MutationState` / `Notif` from `package:snowflake_flutter_theme/snowflake_flutter_theme.dart` (1.5.5 barrel).
- Produces: tappable todo rows; no loader; error toast on failure.

- [ ] **Step 1: Write the failing widget tests**

In `home_screen_test.dart`, first make the fake seedable and instrumented — replace the `_FakeTodoRepository` class header and add a call counter + optional error + completion gate:

```dart
class _FakeTodoRepository implements TodoRepository {
  _FakeTodoRepository({this.todos = const <Todo>[]});

  List<Todo> todos;
  Exception? updateError;
  Completer<void>? updateGate;
  int updateCalls = 0;

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
```

Add `import 'dart:async';` at the top of the file. Update `pumpHomeScreen` to accept the fake:

```dart
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
```

Then add the new group (after the create-todo group):

```dart
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
      await tester.pump(const Duration(milliseconds: 300));

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
```

Note: the loading-state ListTile still renders normally (no loader), so `find.text('Walk the dog')` works for the second tap.

- [ ] **Step 2: Run tests to verify the new group fails**

Run: `flutter test test/ui/home/home_screen_test.dart`
Expected: the four new tests FAIL (`updateCalls` stays 0 / icon unchanged) because rows have no `onTap` yet. The create-todo group must still PASS.

- [ ] **Step 3: Implement the tappable rows**

In `home_screen.dart`, replace the whole `_TodoList` class with:

```dart
class _TodoList extends ConsumerWidget {
  const _TodoList({required this.todos});

  final List<Todo> todos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      itemCount: todos.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final todo = todos[index];
        final isCompleted = todo.status == TodoStatus.completed;
        // Watching (not reading) keeps this autoDispose provider alive for
        // the in-flight mutation; taps are disabled while loading, with no
        // loader shown so the optimistic flip stays visible.
        final mutationState =
            ref.watch(myMutationControllerProvider(todo.id));
        return ListTile(
          contentPadding: ThemeSizes.sym(h: ThemeSizes.m, v: ThemeSizes.xxs),
          title: AppText.m(todo.title),
          onTap: mutationState == MutationState.loading
              ? null
              : () => _onTodoTap(context, ref, todo),
          trailing: Icon(
            isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
            color:
                isCompleted ? ThemeColors.statusSuccess : ThemeColors.grey40,
          ),
        );
      },
    );
  }

  void _onTodoTap(BuildContext context, WidgetRef ref, Todo todo) {
    ref.read(myMutationControllerProvider(todo.id).notifier).action<void>(
          mutation: () =>
              ref.read(HomeController.provider.notifier).toggleTodo(todo),
          onError: () {
            if (!context.mounted) {
              return;
            }
            Notif.showToast(
              context: context,
              title: t.common.error,
              message: t.homeScreen.todoUpdateError,
              type: ToastType.error,
            );
          },
        );
  }
}
```

(`myMutationControllerProvider`, `MutationState`, `Notif`, `ToastType` all come from the already-imported `package:snowflake_flutter_theme/snowflake_flutter_theme.dart`.)

- [ ] **Step 4: Run the full suite and analyzer**

Run: `flutter analyze && flutter test`
Expected: no analyzer issues; all tests pass.

- [ ] **Step 5: Commit**

```bash
git add lib/ui/home/view/home_screen.dart test/ui/home/home_screen_test.dart
git commit -m "@feat(home): tap todo row to toggle completion"
```

---

### Task 6: End-to-end verification against blueprint conformance

**Files:** none (verification only)

- [ ] **Step 1: Full suite + analyzer one last time**

Run: `flutter analyze && flutter test`
Expected: clean, all green.

- [ ] **Step 2: Conformance check against `.blueprint/`**

Compare the touched files' style with `blueprint/.blueprint/lib` equivalents (layering, provider style, naming). Expected: no divergence beyond the new feature.

- [ ] **Step 3: Manual smoke test (optional, needs network + GOREST_API_TOKEN)**

Run: `flutter run -d chrome --dart-define=GOREST_API_TOKEN=<token>` and tap a todo; confirm the icon flips instantly and a PATCH lands on gorest.co.in (devtools network tab).
