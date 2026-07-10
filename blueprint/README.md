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

#### Data layer: DTOs, entities & mappers

The backend wire format is kept separate from the domain. There are two forms,
and you pick based on whether they actually differ:

- **Simple model (no divergence yet).** Write only the DTO — the
  `dart_mappable` serializable class in `data/api/dto/` — and alias the entity
  to it in `domain/entity/`:

  ```dart
  // domain/entity/foo.dart
  typedef Foo = FooDto;
  ```

  No mapper; the repository passes the DTO through as the entity.

- **Diverged model.** When the backend shape and the entity differ (renamed or
  reshaped fields, type conversions, dropped/computed fields), promote the
  entity to a real class:
  - `FooDto` (`data/api/dto/`) keeps the wire format (`@MappableClass`,
    `snake_case`, raw types).
  - `Foo` (`domain/entity/`) is a pure entity — `@MappableClass` only for
    `==`/`copyWith`, no JSON.
  - `FooEntityMapper.fromDto` (`data/mapper/`) does the transformation. Use the
    `Entity` suffix so the name doesn't collide with `dart_mappable`'s generated
    `FooMapper` (from the entity) and `FooDtoMapper` (from the DTO).
  - The repository maps DTOs to entities; UI consumes only entities.

Promoting a typedef to a real class is localized: consumers already import
`Foo`, so you only add the entity class, the mapper, and the mapping call in the
repository. See `Todo` (`TodoDto` → `TodoEntityMapper` → `Todo`) for a worked
example.
