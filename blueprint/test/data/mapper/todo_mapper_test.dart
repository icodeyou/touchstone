import 'package:flutter_test/flutter_test.dart';
import 'package:touchstone/data/api/dto/todo_dto.dart';
import 'package:touchstone/data/mapper/todo_mapper.dart';
import 'package:touchstone/domain/entity/todo.dart';

void main() {
  group('TodoEntityMapper.fromDto', () {
    test('maps fields and parses status and dueOn', () {
      const dto = TodoDto(
        id: 1,
        userId: 42,
        title: 'Write tests',
        status: 'completed',
        dueOn: '2026-07-09T00:00:00.000Z',
      );

      final todo = TodoEntityMapper.fromDto(dto);

      expect(todo.id, 1);
      expect(todo.userId, 42);
      expect(todo.title, 'Write tests');
      expect(todo.status, TodoStatus.completed);
      expect(todo.dueOn, DateTime.parse('2026-07-09T00:00:00.000Z'));
    });

    test('maps a pending status', () {
      const dto = TodoDto(
        id: 2,
        userId: 42,
        title: 'Ship app',
        status: 'pending',
      );

      expect(TodoEntityMapper.fromDto(dto).status, TodoStatus.pending);
    });

    test('leaves dueOn null when absent', () {
      const dto = TodoDto(
        id: 3,
        userId: 42,
        title: 'No due date',
        status: 'pending',
      );

      expect(TodoEntityMapper.fromDto(dto).dueOn, isNull);
    });
  });
}
