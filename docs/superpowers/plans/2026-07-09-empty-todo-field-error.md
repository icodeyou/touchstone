# Empty Create-Todo Field Error Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Show an error message below the create-todo textfield when the user submits it empty, instead of silently ignoring the submit.

**Architecture:** Pure UI-layer change. A local `String? _errorText` in `_CreateTodoFieldState` drives Material's built-in `InputDecoration.errorText`: set on empty submit, cleared on typing. One new i18n key (`homeScreen.createTodoEmptyError`) in all four slang locale files. No controller, repository, or API changes.

**Tech Stack:** Flutter, Riverpod, slang (i18n codegen via build_runner), flutter_test.

**Spec:** `docs/superpowers/specs/2026-07-09-empty-todo-field-error-design.md`

## Global Constraints

- All commands run from the `blueprint/` directory of the repo.
- Commit messages use the multi-commit convention: `@<type>(<scope>): message` (conventional commits with a leading `@`).
- Conform to the `.blueprint/` reference (architecture, naming, theming) per `blueprint/CLAUDE.md`; verify `blueprint/.blueprint/` exists before writing code.
- English error copy is exactly: `Please enter a title`.
- **Precondition:** the working tree must be clean before Task 1. The current uncommitted changes to `blueprint/lib/ui/home/view/home_screen.dart` and `blueprint/test/ui/home/home_screen_test.dart` are a previous feature (mutation-controller create flow) and must be committed separately first — do NOT include them in this plan's commits, and do not start until they are committed.

---

### Task 1: i18n key `createTodoEmptyError`

**Files:**
- Modify: `blueprint/lib/core/app/i18n/en.i18n.yaml`
- Modify: `blueprint/lib/core/app/i18n/es.i18n.yaml`
- Modify: `blueprint/lib/core/app/i18n/fr.i18n.yaml`
- Modify: `blueprint/lib/core/app/i18n/it.i18n.yaml`
- Regenerate: `blueprint/lib/core/app/i18n/translations*.g.dart` (via build_runner, do not hand-edit)

**Interfaces:**
- Consumes: nothing.
- Produces: `t.homeScreen.createTodoEmptyError` (a `String` getter on the generated translations), used by Task 2.

- [ ] **Step 1: Add the key to the four locale files**

In each file, add one line under the `homeScreen:` block, directly after the `createTodoHint:` line (each file already has `homeScreen:` with a `createTodoHint` key around line 15).

`en.i18n.yaml`:

```yaml
  createTodoEmptyError: Please enter a title
```

`es.i18n.yaml`:

```yaml
  createTodoEmptyError: Introduce un título
```

`fr.i18n.yaml`:

```yaml
  createTodoEmptyError: Veuillez saisir un titre
```

`it.i18n.yaml`:

```yaml
  createTodoEmptyError: Inserisci un titolo
```

- [ ] **Step 2: Regenerate translations**

Run (from `blueprint/`):

```bash
dart run build_runner build --delete-conflicting-outputs
```

Expected: exits 0 with "Succeeded" in the output.

- [ ] **Step 3: Verify the generated getter exists**

Run:

```bash
grep -rn "createTodoEmptyError" lib/core/app/i18n/translations_en.g.dart
```

Expected: one match, a getter returning `'Please enter a title'`.

- [ ] **Step 4: Commit**

```bash
git add lib/core/app/i18n/
git commit -m "@feat(i18n): add createTodoEmptyError translations"
```

---

### Task 2: Error display in `_CreateTodoField`

**Files:**
- Modify: `blueprint/lib/ui/home/view/home_screen.dart` (the `_CreateTodoFieldState` class, `_submit()` and `build()`)
- Test: `blueprint/test/ui/home/home_screen_test.dart`

**Interfaces:**
- Consumes: `t.homeScreen.createTodoEmptyError` from Task 1.
- Produces: nothing consumed by later tasks (final task).

- [ ] **Step 1: Write the failing tests**

In `blueprint/test/ui/home/home_screen_test.dart`:

First, add a call counter to `_FakeTodoRepository` so tests can assert no create request is made. Add the field next to `updateCalls`:

```dart
  int createCalls = 0;
```

and increment it as the first line of the existing `createTodo` override:

```dart
  @override
  Future<Todo> createTodo({required String title}) async {
    createCalls++;
    final gate = createGate;
    ...
```

Then add these tests inside the existing `group('HomeScreen create todo', ...)`:

```dart
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
```

Finally, extend the existing `'submitting the field creates the todo'` test: after its last `expect`, add:

```dart
      expect(find.text('Please enter a title'), findsNothing);
```

- [ ] **Step 2: Run the tests to verify the new ones fail**

Run (from `blueprint/`):

```bash
flutter test test/ui/home/home_screen_test.dart
```

Expected: the three new tests FAIL (error text not found: `findsOneWidget` matched nothing); the pre-existing tests and the extended one still PASS.

- [ ] **Step 3: Implement the error state**

In `blueprint/lib/ui/home/view/home_screen.dart`, inside `_CreateTodoFieldState`:

Add the state field next to `_controller`:

```dart
  String? _errorText;
```

Change the top of `_submit()` from the current silent return:

```dart
  Future<void> _submit() async {
    final title = _controller.text.trim();
    if (title.isEmpty) {
      setState(() => _errorText = t.homeScreen.createTodoEmptyError);
      return;
    }
    if (_errorText != null) {
      setState(() => _errorText = null);
    }
```

(the rest of `_submit()` is unchanged; the second `if` guards against a stale
error on submits where the text changed without `onChanged` firing, e.g.
programmatic changes).

In `build()`, on the `TextField`: add an `onChanged` that clears the error, and pass `errorText` to the existing `InputDecoration` (keep all current decoration properties):

```dart
        TextField(
          controller: _controller,
          enabled: !isLoading,
          onChanged: (_) {
            if (_errorText != null) {
              setState(() => _errorText = null);
            }
          },
          decoration: InputDecoration(
            hintText: t.homeScreen.createTodoHint,
            errorText: _errorText,
            border: OutlineInputBorder(
```

- [ ] **Step 4: Run the tests to verify they pass**

Run (from `blueprint/`):

```bash
flutter test test/ui/home/home_screen_test.dart
```

Expected: all tests PASS.

- [ ] **Step 5: Run analyzer**

Run (from `blueprint/`):

```bash
flutter analyze
```

Expected: `No issues found!`

- [ ] **Step 6: Commit**

```bash
git add lib/ui/home/view/home_screen.dart test/ui/home/home_screen_test.dart
git commit -m "@feat(home): show error below field on empty todo submit"
```
