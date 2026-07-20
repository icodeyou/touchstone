import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/data/source/api/db/todo_api_client.dart';
import 'package:touchstone/data/source/api/dto/todo/todo_entity_converter.dart';
import 'package:touchstone/domain/entity/todo.dart';

class TodoRepository {
  TodoRepository({required this._apiClient});
  final TodoApiClient _apiClient;

  static final provider = Provider<TodoRepository>(
    (ref) => TodoRepository(apiClient: ref.watch(TodoApiClient.provider)),
  );

  Future<List<Todo>> getTodos() async {
    final dtos = await _apiClient.fetchTodos();
    return dtos.map(TodoEntityConverter.fromDto).toList();
  }

  Future<Todo> createTodo({required String title}) async {
    final userId = await _apiClient.fetchFirstUserId();
    final dto = await _apiClient.createTodo(userId: userId, title: title);
    return TodoEntityConverter.fromDto(dto);
  }

  Future<Todo> updateTodoStatus({
    required int id,
    required TodoStatus status,
  }) async {
    final dto = await _apiClient.updateTodoStatus(id: id, status: status);
    return TodoEntityConverter.fromDto(dto);
  }
}
