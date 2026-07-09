import 'package:touchstone/data/api/dto/todo_dto.dart';
import 'package:touchstone/domain/entity/todo.dart';

/// Maps the [TodoDto] wire model to the domain [Todo] entity: parses the raw
/// `status` string into [TodoStatus] and the `dueOn` string into a [DateTime].
///
/// Named `TodoEntityMapper` to avoid colliding with `dart_mappable`'s generated
/// `TodoMapper` (from [Todo]) and `TodoDtoMapper` (from [TodoDto]).
class TodoEntityMapper {
  const TodoEntityMapper._();

  static Todo fromDto(TodoDto dto) => Todo(
        id: dto.id,
        userId: dto.userId,
        title: dto.title,
        status: TodoStatus.values.byName(dto.status),
        dueOn: dto.dueOn == null ? null : DateTime.tryParse(dto.dueOn!),
      );
}
