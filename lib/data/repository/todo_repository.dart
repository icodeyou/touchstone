import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:touchstone/data/api/todo_api_client.dart';
import 'package:touchstone/domain/model/todo.dart';

final todoRepositoryProvider = Provider<TodoRepository>(
  (ref) => TodoRepository(apiClient: ref.watch(todoApiClientProvider)),
);

class TodoRepository {
  TodoRepository({required TodoApiClient apiClient}) : _apiClient = apiClient;

  final TodoApiClient _apiClient;

  Future<List<Todo>> getTodos() => _apiClient.fetchTodos();
}
