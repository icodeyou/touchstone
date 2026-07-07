---
name: verify
description: Build, run, and visually verify the touchstone Flutter web app
---

# Verifying touchstone changes at runtime

Touchstone is a Flutter web app (deployed to Vercel as a release web build).

## Build & serve (reliable for headless capture)

Debug mode (`flutter run -d web-server`) renders blank under headless
Chrome's `--virtual-time-budget` — use the release build instead, which is
also what production runs:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # generates *.mapper.dart (gitignored)
flutter build web --release
(cd build/web && python3 -m http.server 8124 --bind 127.0.0.1) &
```

## Capture

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --hide-scrollbars --window-size=1280,800 \
  --virtual-time-budget=30000 --screenshot=/path/shot.png http://127.0.0.1:8124
```

The home screen fetches live todos from the GoRest API; network works in
headless Chrome, so real data renders.

## Gotchas

- If `dart run build_runner build` fails with "Invoked Dart programs must
  have a 'main' function defined", the `.dart_tool` cache is stale from
  another SDK: `rm -rf .dart_tool && flutter pub get`, then retry.
- Slang translations are committed (`lib/core/app/i18n/*.g.dart`); only
  dart_mappable output needs generating.
- `HomeScreen` overrides its AppBar color with `colorScheme.inversePrimary`,
  so AppBar pixels don't reflect `appBarTheme` from the app theme.
