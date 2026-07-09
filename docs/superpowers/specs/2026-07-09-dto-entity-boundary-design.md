# DTO ↔ Entity boundary in the blueprint

**Date:** 2026-07-09
**Status:** Approved

## Problem

The blueprint has no DTO (backend model) concept. The domain model `Todo`
(`lib/domain/model/todo.dart`) does double duty: it is both the domain entity
and the backend deserialization target, carrying `dart_mappable` annotations and
`snake_case` wire-format serialization (`fromMap`/`fromJson`). The domain layer
is therefore coupled to the backend wire format, and there is no place to map
between a backend shape and a differently-shaped entity.

We hit concrete divergences: field renaming/reshaping, type conversion
(String → enum, String → `DateTime`), and dropped/computed fields. These need a
mapping boundary.

## Goal

Introduce a DTO ↔ entity boundary as a blueprint convention, demonstrated by
converting the existing `Todo` example. Keep it lightweight for the common case
where DTO and entity are structurally identical.

## The two-tier convention

The blueprint defines two forms and a rule for choosing between them.

**Simple model (no divergence yet).** Write only the DTO (the `dart_mappable`
serializable class) and alias the entity to it:

```dart
// data/api/dto/foo_dto.dart  → FooDto (@MappableClass, wire format)
// domain/entity/foo.dart
typedef Foo = FooDto;
```

No mapper. The repository passes the DTO through as the entity. This is the
"it'll often be the same" case.

**Diverged model.** Promote the entity to a real class and add a mapper:

- `FooDto` (`data/api/dto/`) keeps the wire format (`@MappableClass`,
  `snake_case`, raw types, `fromMap`/`fromJson`).
- `Foo` (`domain/entity/`) becomes a pure entity: `@MappableClass` used **only**
  for `==`/`hashCode`/`copyWith`, no JSON, no `caseStyle`.
- `FooMapper.fromDto` (`data/mapper/`) does the transformation.

Because every consumer already imports `Foo`, promoting a typedef to a real
class is a localized change: add the entity class, add the mapper, map in the
repository. Consumers are untouched.

## Folder structure

```
lib/
  data/
    api/
      todo_api_client.dart      # returns List<TodoDto>
      dto/
        todo_dto.dart           # @MappableClass, snake_case, raw wire types
    mapper/
      todo_mapper.dart          # TodoMapper.fromDto(TodoDto) -> Todo
    repository/
      todo_repository.dart      # maps DTO -> entity, returns List<Todo>
  domain/
    entity/
      todo.dart                 # pure entity + TodoStatus enum
```

`domain/model/` is renamed to `domain/entity/`.

## The `Todo` example (diverged form)

`Todo` has genuine divergence to demonstrate: `status` String → enum,
`due_on` String → `DateTime`.

**`data/api/dto/todo_dto.dart`** — raw wire types, JSON lives here:

```dart
import 'package:dart_mappable/dart_mappable.dart';

part 'todo_dto.mapper.dart';

@MappableClass(caseStyle: CaseStyle.snakeCase)
class TodoDto with TodoDtoMappable {
  const TodoDto({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    this.dueOn,
  });

  final int id;
  final int userId;
  final String title;
  final String status;   // raw
  final String? dueOn;   // raw ISO string

  static TodoDto fromMap(Map<String, Object?> map) => TodoDtoMapper.fromMap(map);

  static const fromJson = TodoDtoMapper.fromJson;
}
```

**`domain/entity/todo.dart`** — pure entity, `@MappableClass` for
`==`/`copyWith` only (no JSON), plus the domain enum:

```dart
import 'package:dart_mappable/dart_mappable.dart';

part 'todo.mapper.dart';

@MappableEnum()
enum TodoStatus { pending, completed }

@MappableClass()
class Todo with TodoMappable {
  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    required this.status,
    this.dueOn,
  });

  final int id;
  final int userId;
  final String title;
  final TodoStatus status;
  final DateTime? dueOn;
}
```

**`data/mapper/todo_mapper.dart`** — the transformation:

```dart
import 'package:touchstone/data/api/dto/todo_dto.dart';
import 'package:touchstone/domain/entity/todo.dart';

class TodoMapper {
  const TodoMapper._();

  static Todo fromDto(TodoDto dto) => Todo(
        id: dto.id,
        userId: dto.userId,
        title: dto.title,
        status: TodoStatus.values.byName(dto.status),
        dueOn: dto.dueOn == null ? null : DateTime.tryParse(dto.dueOn!),
      );
}
```

No name collision: `dart_mappable` generates `TodoDtoMappable`/`TodoDtoMapper`
from `TodoDto`, distinct from the hand-written `TodoMapper`.

## Data flow changes

- **`todo_api_client.dart`:** `fetchTodos()` returns `List<TodoDto>`, parses with
  `TodoDto.fromMap`.
- **`todo_repository.dart`:** `getTodos()` calls the client and maps:
  `dtos.map(TodoMapper.fromDto).toList()`, returns `List<Todo>`.
- UI/controller keep consuming `Todo` — unchanged apart from the import path
  (`domain/model/todo.dart` → `domain/entity/todo.dart`).

## Documentation

Add a short "Data layer: DTOs, entities & mappers" section to the blueprint's
`README.md` describing the two-tier rule, so derived projects inherit the
convention. The converted `Todo` stands as the worked example.

## Testing

- Add `test/data/mapper/todo_mapper_test.dart` covering the conversions:
  `status` → enum, `due_on` parse, null `dueOn`.
- Update existing tests that construct `Todo` or parse wire JSON to use `TodoDto`
  where they touch the wire format; update imports for the `domain/entity/` move.
- Regenerate `dart_mappable` code (`build_runner`) so `todo.mapper.dart` and
  `todo_dto.mapper.dart` exist (both gitignored).
- Run the blueprint verify skill at the end.

## Out of scope

- Multi-source assembly (one entity from several endpoints/DTOs).
- DTOs for the local/preferences layer.
- Converting any model other than `Todo`.
