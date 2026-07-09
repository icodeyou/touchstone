# Tap-to-Toggle Todo Completion — Design

**Date:** 2026-07-09
**Scope:** `blueprint/` app (touchstone blueprint)

## Goal

Tapping a todo item in the home list toggles its completion status on the
GoRest API and reflects the change in the UI.

## API contract

- Request: `PATCH https://gorest.co.in/public/v2/todos/<ID>`
- Body: `{"status": "completed"}` to complete, `{"status": "pending"}` to
  un-complete (GoRest only accepts these two values; POST on `/todos/<ID>`
  and the value `"done"` are rejected by the API, so PATCH + valid enum
  values are used instead of the raw initial wording of the request).
- Success: HTTP 200 with the updated todo JSON.
- Auth/headers: same `_headers` getter already used by `TodoApiClient`
  (JSON content type + optional Bearer token).

## Architecture

Follows the existing layering: API client → repository → controller → UI.

### 1. `TodoApiClient.updateTodoStatus` (`lib/data/api/todo_api_client.dart`)

```dart
Future<Todo> updateTodoStatus({required int id, required TodoStatus status})
```

Sends the PATCH request above. Throws `HttpException` when the status code
is not `HttpStatus.ok`, mirroring `fetchTodos`/`createTodo`. Returns the
parsed `Todo` from the response body.

### 2. `TodoRepository.updateTodoStatus` (`lib/data/repository/todo_repository.dart`)

Thin passthrough to the API client, same style as `getTodos`.

### 3. `HomeController.toggleTodo` (`lib/ui/home/controller/home_controller.dart`)

```dart
Future<void> toggleTodo(Todo todo)
```

Optimistic update:

1. Compute the new status: `pending` ↔ `completed`.
2. Immediately emit `AsyncData` with the todo replaced by
   `todo.copyWith(status: newStatus)` in the current list.
3. Await `TodoRepository.updateTodoStatus`.
4. On success: keep the updated state (no full-list refetch, no
   `invalidateSelf`).
5. On failure: restore the previous list state, then rethrow so the UI
   layer can react.

If the controller has no data yet (loading/error state), the method is a
no-op.

### 4. UI (`lib/ui/home/view/home_screen.dart`)

Uses the package's `MutationController` directly (exported since
`snowflake_flutter_theme 1.5.5`, which this change pins), **not**
`MutationWidget` — no loader is shown, so the optimistic flip stays
visible. Each `ListTile` in `_TodoList` gets an `onTap`:

- Runs the mutation through the per-todo controller instance:
  `ref.read(myMutationControllerProvider(todo.id).notifier).action<void>(...)`
  with:
  - `mutation`: `() => ref.read(HomeController.provider.notifier).toggleTodo(todo)`
  - `onError`: shows an error toast (`Notif.showToast`, type error) using
    a new `todoUpdateError` i18n key. The home controller's rethrow after
    rollback is what routes here (`action()`'s internal `mutate()`
    catches it).
  - `onSuccess`: nothing — state is already updated. No success toast.
- Double-tap guard: `onTap` no-ops while that todo's mutation state is
  `MutationState.loading` (read from `myMutationControllerProvider(todo.id)`),
  without rendering any loading UI.
- `_TodoList` becomes a `ConsumerWidget` to reach the providers.

## i18n

Add `todoUpdateError` under `homeScreen` in all four locale files
(`en`, `es`, `fr`, `it` `.i18n.yaml`) and regenerate translations.

## Error handling

- API/network failure → home controller rolls back the list state and
  rethrows → `MutationController.action()` routes to `onError` → error
  toast. Icon returns to its previous state.
- No retry logic; the user can simply tap again.

## Testing

Follow existing test files and patterns:

- **Controller** (`test/ui/home/home_controller_test.dart`): optimistic
  flip is emitted before the repository completes; success keeps the new
  state; failure rolls back and rethrows.
- **Widget** (`test/ui/home/home_screen_test.dart`): tapping a row
  triggers the toggle; completed/pending icons render correctly; error
  path shows the toast.

## Out of scope

- Editing todo titles, deleting todos.
- Success toasts for toggling.
- Concurrent-tap dedup beyond the per-todo `MutationState.loading` guard.
