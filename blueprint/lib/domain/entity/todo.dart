import 'package:dart_mappable/dart_mappable.dart';

part 'todo.mapper.dart';

@MappableEnum()
enum TodoStatus { pending, completed }

/// Domain entity for a todo. Pure of any wire format: it carries no JSON
/// serialization. `@MappableClass` is used only for `==`/`hashCode`/`copyWith`.
///
/// It is built from a `TodoDto` via `TodoEntityMapper.fromDto`.
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
