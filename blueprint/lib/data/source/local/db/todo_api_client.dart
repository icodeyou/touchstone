import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:touchstone/data/source/api/dto/todo/todo_dto.dart';
import 'package:touchstone/domain/entity/todo.dart';
import 'package:touchstone/shared/constants/app_constants.dart';

class TodoApiClient {
  // [BLUEPRINT COMMENT] First the constructor
  TodoApiClient({required this._client});
  final http.Client _client; // [BLUEPRINT COMMENT] Then the class variable

  // [BLUEPRINT COMMENT] Then the provider
  static final provider = Provider<TodoApiClient>((ref) {
    final client = http.Client();
    ref.onDispose(client.close);
    return TodoApiClient(client: client);
  });

  // [BLUEPRINT COMMENT] Then the private variables
  Map<String, String> get _headers => {
    HttpHeaders.contentTypeHeader: 'application/json',
    if (AppConstants.goRestApiToken.isNotEmpty)
      HttpHeaders.authorizationHeader: 'Bearer ${AppConstants.goRestApiToken}',
  };

  // [BLUEPRINT COMMENT] Then the methods
  Future<List<TodoDto>> fetchTodos() async {
    final uri = Uri.parse('${AppConstants.goRestBaseUrl}/todos');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'GET /todos failed (${response.statusCode})',
        uri: uri,
      );
    }
    final body = jsonDecode(response.body) as List<Object?>;
    return body.whereType<Map<String, Object?>>().map(TodoDto.fromMap).toList();
  }

  Future<TodoDto> createTodo({
    required int userId,
    required String title,
    TodoStatus status = TodoStatus.pending,
  }) async {
    final uri = Uri.parse('${AppConstants.goRestBaseUrl}/todos');
    final response = await _client.post(
      uri,
      headers: _headers,
      body: jsonEncode({
        'user_id': userId,
        'title': title,
        'status': status.toValue(),
      }),
    );
    if (response.statusCode != HttpStatus.created) {
      throw HttpException(
        'POST /todos failed (${response.statusCode})',
        uri: uri,
      );
    }
    return TodoDto.fromMap(jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<TodoDto> updateTodoStatus({
    required int id,
    required TodoStatus status,
  }) async {
    final uri = Uri.parse('${AppConstants.goRestBaseUrl}/todos/$id');
    final response = await _client.patch(
      uri,
      headers: _headers,
      body: jsonEncode({'status': status.toValue()}),
    );
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'PATCH /todos/$id failed (${response.statusCode})',
        uri: uri,
      );
    }
    return TodoDto.fromMap(jsonDecode(response.body) as Map<String, Object?>);
  }

  Future<int> fetchFirstUserId() async {
    final uri = Uri.parse('${AppConstants.goRestBaseUrl}/users?per_page=1');
    final response = await _client.get(uri, headers: _headers);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'GET /users failed (${response.statusCode})',
        uri: uri,
      );
    }
    final body = jsonDecode(response.body) as List<Object?>;
    final user = body.whereType<Map<String, Object?>>().firstOrNull;
    if (user == null) {
      throw HttpException('GET /users returned no users', uri: uri);
    }
    return user['id']! as int;
  }
}
