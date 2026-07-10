import 'package:touchstone/data/source/api/dto/todo_dto.dart';
import 'package:touchstone/domain/entity/todo.dart';

/// Maps the [TodoDto] wire model to the domain [Todo] entity.
///
/// Named `TodoEntityConverter` to avoid colliding with `dart_mappable`'s 
/// generated `TodoMapper` (from [Todo]) and `TodoDtoMapper` (from [TodoDto]).
class TodoEntityConverter {
  const TodoEntityConverter._();

  static Todo fromDto(TodoDto dto) => Todo(
    id: dto.id,
    userId: dto.userId,
    title: dto.title,
    status: TodoStatus.values.byName(dto.status),
    dueOn: dto.dueOn == null ? null : DateTime.tryParse(dto.dueOn!),
  );
}
