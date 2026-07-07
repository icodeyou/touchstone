# Snowflake Flutter Theme Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Wire the already-declared `snowflake_flutter_theme` package into touchstone's `MaterialApp`, mirroring pixtory's pattern with a light-only color record.

**Architecture:** A top-level `lightColors` record (shape: `(primary, onPrimary, secondary, onSecondary, background, onBackground)`) is added to `lib/core/theme/app_colors.dart`, and `MyApp` passes it to `getSnowflakeThemeData(mode: ThemeMode.light, appColors: lightColors)` as the app's `theme`, with `themeMode: ThemeMode.light`. No `ThemeHelper` font wrapper is ported (touchstone declares no custom fonts).

**Tech Stack:** Flutter, `snowflake_flutter_theme` (git dependency, `ref: v27`, already in `pubspec.yaml`), `flutter_test`.

## Global Constraints

- Do not modify `pubspec.yaml` — the `snowflake_flutter_theme` dependency is already declared at `ref: v27`.
- Light mode only: `themeMode: ThemeMode.light`; no `darkTheme` is set.
- The existing `AppColors` class in `lib/core/theme/app_colors.dart` must remain unchanged (only add the record above it).
- Spec: `docs/superpowers/specs/2026-07-07-snowflake-theme-design.md`.

---

### Task 1: Snowflake light theme wiring

**Files:**
- Modify: `lib/core/theme/app_colors.dart`
- Modify: `lib/core/app/app.dart:16-21`
- Test: `test/core/app/app_theme_test.dart` (create)

**Interfaces:**
- Consumes: `getSnowflakeThemeData({required ThemeMode mode, required ({Color primary, Color onPrimary, Color secondary, Color onSecondary, Color background, Color onBackground}) appColors})` from `package:snowflake_flutter_theme/snowflake_flutter_theme.dart`.
- Produces: top-level `const lightColors` record in `package:touchstone/core/theme/app_colors.dart`, usable anywhere app-specific theme colors are needed.

- [ ] **Step 1: Fetch dependencies**

Run: `flutter pub get`
Expected: exits 0 (the snowflake package resolves from git; it is already in `pubspec.lock`).

- [ ] **Step 2: Write the failing test**

Create `test/core/app/app_theme_test.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/core/app/app.dart';
import 'package:touchstone/core/theme/app_colors.dart';

void main() {
  testWidgets('MyApp uses the snowflake light theme', (tester) async {
    await tester.pumpWidget(const MyApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app.themeMode, ThemeMode.light);
    // getSnowflakeThemeData wires appColors.background into the AppBar theme;
    // asserting on it proves the theme came from snowflake, not fromSeed.
    expect(app.theme!.appBarTheme.backgroundColor, lightColors.background);
    expect(app.theme!.appBarTheme.foregroundColor, lightColors.onBackground);
  });
}
```

Note: `MyApp` renders `HomeScreen`, whose repository call fails in tests (flutter_test blocks real HTTP) — that is fine; the test only inspects the `MaterialApp` widget's properties and uses no `pumpAndSettle`.

- [ ] **Step 3: Run test to verify it fails**

Run: `flutter test test/core/app/app_theme_test.dart`
Expected: FAIL — compile error: `Undefined name 'lightColors'` (the record does not exist yet).

- [ ] **Step 4: Add the `lightColors` record**

In `lib/core/theme/app_colors.dart`, add above the `AppColors` class:

```dart
/// All the colors that are specific to the application in light mode.
const lightColors = (
  primary: Color(0xFFD9472A),
  onPrimary: Color(0xFFFFEBE7),
  secondary: Color(0xFFFFC800),
  onSecondary: Color(0xFF6D5B19),
  background: Color(0xFFF7F7F7),
  onBackground: Color(0xFF1D1C1C),
);
```

The values duplicate the `AppColors` constants intentionally, mirroring pixtory's `colors.dart` where the record is self-contained.

- [ ] **Step 5: Wire the theme in `MyApp`**

In `lib/core/app/app.dart`, add the import:

```dart
import 'package:snowflake_flutter_theme/snowflake_flutter_theme.dart';
```

Replace:

```dart
theme: ThemeData(
  colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appPrimary),
),
```

with:

```dart
themeMode: ThemeMode.light,
theme: getSnowflakeThemeData(
  mode: ThemeMode.light,
  appColors: lightColors,
),
```

If the `AppColors` import (`package:touchstone/core/theme/app_colors.dart`) becomes unused-looking, keep it — `lightColors` lives in the same file, so the import stays.

- [ ] **Step 6: Run test to verify it passes**

Run: `flutter test test/core/app/app_theme_test.dart`
Expected: PASS (1 test).

- [ ] **Step 7: Run full verification**

Run: `flutter analyze && flutter test`
Expected: `No issues found!` and all tests pass (the two pre-existing test files plus the new one).

- [ ] **Step 8: Commit**

```bash
git add lib/core/theme/app_colors.dart lib/core/app/app.dart test/core/app/app_theme_test.dart
git commit -m "Use snowflake_flutter_theme for the app light theme"
```
