import 'package:dart_mappable/dart_mappable.dart';

part 'todo.mapper.dart';

@MappableEnum()
enum TodoStatus { pending, completed }

@MappableClass(caseStyle: CaseStyle.snakeCase)
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

  static const fromMap = TodoMapper.fromMap;
  static const fromJson = TodoMapper.fromJson;
}
