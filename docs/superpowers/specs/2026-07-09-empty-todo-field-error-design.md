# Empty Create-Todo Field Error — Design

**Date:** 2026-07-09
**Scope:** `blueprint/` app (touchstone blueprint)

## Goal

When the user submits the create-todo field (Add button or keyboard
submit) while it is empty, show an error message below the textfield
instead of silently ignoring the submit.

## Behavior

- On submit with empty trimmed text: display the error message below the
  field and do **not** call the API.
- The error clears as soon as the user types anything in the field.
- A valid submit never shows the error; whitespace-only input counts as
  empty (existing `trim()` behavior is kept).
- The error is not shown on first load — only after an empty submit
  attempt.

## Approach

Use Material's built-in `InputDecoration.errorText`, driven by a local
`String? _errorText` field in `_CreateTodoFieldState`
(`lib/ui/home/view/home_screen.dart`):

1. `_submit()` — when the trimmed title is empty, `setState` the error
   text (new i18n key) and return, instead of the current bare `return`.
   On a non-empty submit, clear any stale error before running the
   mutation.
2. `TextField.onChanged` — if an error is showing, `setState` it back to
   `null`.
3. Pass `errorText: _errorText` to the existing `InputDecoration`.
   Material renders the message below the field in the theme's error
   style and colors the border automatically; no layout changes needed.

Rejected alternatives:

- `Form` + `TextFormField` with a validator: adds a
  `GlobalKey<FormState>` and form machinery for a single field.
- A manual `AppText` below the field: reimplements what `errorText`
  already provides, with less consistent styling.

## i18n

Add `createTodoEmptyError` under `homeScreen` in all four locale files
(`en`, `es`, `fr`, `it` `.i18n.yaml`) and regenerate translations.
English wording: "Please enter a title".

## Testing

Widget tests in `test/ui/home/home_screen_test.dart`, following existing
patterns:

- Tapping Add with an empty field shows the error text and performs no
  POST.
- Typing after the error clears it.
- A valid submit shows no error.

## Out of scope

- Max-length or other validation rules.
- Changing the existing success/error toast behavior for creation.
