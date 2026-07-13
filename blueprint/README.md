# Touchstone

## Getting started

### 1. Install dependencies

```shell
flutter pub get
```

### 2. Generate code

Generated files (`*.mapper.dart`, `translations.g.dart`) are not versioned, so
they must be generated before the first compilation :

```shell
dart run build_runner build --delete-conflicting-outputs
dart run slang
```

Run `build_runner` again after modifying a `dart_mappable` model, and `slang`
after modifying a `.i18n.yaml` translation file.

### 3. Configure API keys

Secrets are injected at compile time with `--dart-define` and are not
versioned. Create your own `api_keys.json` from the example :

```shell
cp api_keys.example.json api_keys.json
```

Then fill in the values (e.g. your goRest token from
[gorest.co.in](https://gorest.co.in/consumer/login)).

### 4. Run the app

```shell
flutter run -d {DEVICE_ID} --dart-define-from-file=api_keys.json
```

💡 Replace {DEVICE_ID} by the ID of your target device. You can find it by
running the command `flutter devices`

You can also pass a single key directly :

```shell
flutter run -d chrome --dart-define=GOREST_API_TOKEN={YOUR_TOKEN}
```

### Deliveries

#### Android

Run the following command :

`flutter build appbundle --release --obfuscate --split-debug-info=android_X.X.X --dart-define-from-file=api_keys.json`

With 'X.X.X' being the version of the app.

#### iOS

Run the following command :

`flutter build ipa --obfuscate --split-debug-info=ios_X.X.X --dart-define-from-file=api_keys.json`

With 'X.X.X' being the version of the app.
