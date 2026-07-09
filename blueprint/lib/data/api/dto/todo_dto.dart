import 'package:dart_mappable/dart_mappable.dart';

part 'todo_dto.mapper.dart';

/// Wire model for a todo, shaped exactly like the backend payload.
///
/// Holds raw types (`status`/`dueOn` as strings) and snake_case keys. The
/// domain `Todo` entity is derived from this via `TodoEntityMapper.fromDto`.
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
  final String status;
  final String? dueOn;

  static TodoDto fromMap(Map<String, Object?> map) =>
      TodoDtoMapper.fromMap(map);

  static const fromJson = TodoDtoMapper.fromJson;
}
