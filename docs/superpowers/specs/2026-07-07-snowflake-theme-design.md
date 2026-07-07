# Snowflake Flutter Theme Integration — Design

**Date:** 2026-07-07
**Status:** Approved

## Goal

Use the `snowflake_flutter_theme` library in touchstone the same way pixtory uses it: a colors record passed to `getSnowflakeThemeData()` in the `MaterialApp`.

## Context

- Touchstone's `pubspec.yaml` already declares `snowflake_flutter_theme` as a git dependency pinned to `ref: v27` (same as pixtory), but nothing imports it yet.
- Pixtory's pattern: `lib/app/theme/colors.dart` defines a top-level `darkColors` record `(primary, onPrimary, secondary, onSecondary, background, onBackground)` plus an `AppColors` class for app-specific extras; `app.dart` passes the record to `getSnowflakeThemeData(mode: ..., appColors: ...)` with a fixed `themeMode`.
- Pixtory is dark-only. Touchstone will be **light-only** (user decision), reusing its existing light palette.
- Pixtory's `ThemeHelper.buildThemeWithFontFamily()` exists only to apply pixtory's custom fonts; touchstone declares no fonts, so it is not ported (YAGNI).

## Changes

### 1. `lib/core/theme/app_colors.dart`

Add a top-level record above the existing `AppColors` class:

```dart
/// All the colors that are specific to the application in light mode.
const lightColors = (
  primary: Color(0xFFD9472A),      // AppColors.appPrimary
  onPrimary: Color(0xFFFFEBE7),    // AppColors.onAppPrimary
  secondary: Color(0xFFFFC800),    // AppColors.appSecondary
  onSecondary: Color(0xFF6D5B19),  // AppColors.onAppSecondary
  background: Color(0xFFF7F7F7),   // AppColors.background
  onBackground: Color(0xFF1D1C1C), // AppColors.darkBackground — dark text on light bg
);
```

The `AppColors` class stays unchanged for app-specific extras, mirroring pixtory.

### 2. `lib/core/app/app.dart`

Replace `theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: AppColors.appPrimary))` with:

```dart
themeMode: ThemeMode.light,
theme: getSnowflakeThemeData(
  mode: ThemeMode.light,
  appColors: lightColors,
),
```

Import `package:snowflake_flutter_theme/snowflake_flutter_theme.dart`. Everything else in `MyApp` (ProviderScope, TranslationProvider, router config) is untouched.

### 3. `pubspec.yaml`

No change — the dependency is already declared.

## Error handling

None needed — this is compile-time wiring; a wrong record shape fails to compile.

## Verification

- `flutter analyze` clean.
- Existing test suite passes (`flutter test`).
- Launch the app and visually confirm the home screen renders with the snowflake light theme.
