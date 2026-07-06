# Touchstone

Touchstone has been built with Mason, using the brick [pokeboom].

## Getting started

### Running the project

To compile the project, run the following command :

```shell
flutter run
```

If you need to specify the device, add the argument :
`-d {DEVICE_ID}`

💡 Replace {DEVICE_ID} by the ID of your target device. You can find it by running the command `flutter devices`

### Deliveries

#### Android

Run the following command :

`flutter build appbundle --release --obfuscate --split-debug-info=android_X.X.X`

With 'X.X.X' being the version of the app.

#### iOS

Run the following command :

`flutter build ipa --obfuscate --split-debug-info=ios_X.X.X`

With 'X.X.X' being the version of the app.

## Git Workflow

### Branch tree

Syntax for the name of branches : kebab-case

Here is the tree of branches :

- main
  - develop

### Commits and tags

For more details concerning commits and tags, please refer to [GIT_CONVENTIONS.md](https://github.com/icodeyou/hello_riverpod/blob/snowball/GIT_CONVENTIONS.md)

## Technical stack

### Flutter

The app is developed in Flutter. More info on [flutter.dev](https://flutter.dev)
The app can run on [several platforms](https://docs.flutter.dev/reference/supported-platforms).

#### Flutter Channels

We must use as much as possible the channel "stable" for production deliveries.
We can switch to "beta" to use a recent feature, or to fix a problem not released on "stable"
However, we should never use "master" or "dev" channels.

More information here : [Flutter channels](https://docs.flutter.dev/release/upgrade#switching-flutter-channels)

### Architecture

This project uses Riverpod for state management and Clean Architecture.
Here is the [Riverpod documentation](https://riverpod.dev/).
