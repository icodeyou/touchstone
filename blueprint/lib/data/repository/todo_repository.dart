import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/data/api/todo_api_client.dart';
import 'package:touchstone/data/mapper/todo_mapper.dart';
import 'package:touchstone/domain/entity/todo.dart';

class TodoRepository {
  TodoRepository({required TodoApiClient apiClient}) : _apiClient = apiClient;

  static final provider = Provider<TodoRepository>(
    (ref) => TodoRepository(apiClient: ref.watch(TodoApiClient.provider)),
  );

  final TodoApiClient _apiClient;

  Future<List<Todo>> getTodos() async {
    final dtos = await _apiClient.fetchTodos();
    return dtos.map(TodoEntityMapper.fromDto).toList();
  }

  Future<Todo> createTodo({required String title}) async {
    final userId = await _apiClient.fetchFirstUserId();
    final dto = await _apiClient.createTodo(userId: userId, title: title);
    return TodoEntityMapper.fromDto(dto);
  }

  Future<Todo> updateTodoStatus({
    required int id,
    required TodoStatus status,
  }) async {
    final dto = await _apiClient.updateTodoStatus(id: id, status: status);
    return TodoEntityMapper.fromDto(dto);
  }
}
