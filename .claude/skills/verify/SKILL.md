---
name: verify
description: Build, run, and visually verify the touchstone Flutter web app
---

# Verifying touchstone at runtime

Touchstone is a Flutter web app; production (Vercel) serves the release build.

## Build, serve, capture

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs  # dart_mappable output is gitignored
flutter build web --release   # debug mode renders blank in headless capture
(cd build/web && python3 -m http.server 8124 --bind 127.0.0.1) &

"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --hide-scrollbars --window-size=1280,800 \
  --virtual-time-budget=30000 --screenshot=shot.png http://127.0.0.1:8124
```

## Touchstone specifics

- Slang translations (`lib/core/app/i18n/*.g.dart`) are committed; only the
  dart_mappable `*.mapper.dart` files need generating.
- The home screen fetches live todos from the GoRest API; real data renders
  in headless capture.
- `HomeScreen` overrides its AppBar color with `colorScheme.inversePrimary`
  (`lib/ui/home/view/home_screen.dart`), so AppBar pixels do NOT reflect the
  app-level `appBarTheme`.
- build_runner failing with "must have a 'main' function"? Stale cache:
  `rm -rf .dart_tool && flutter pub get`, retry.
