import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:touchstone/core/constants/app_constants.dart';
import 'package:touchstone/domain/model/todo.dart';

final todoApiClientProvider = Provider<TodoApiClient>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return TodoApiClient(client: client);
});

class TodoApiClient {
  TodoApiClient({required http.Client client}) : _client = client;

  final http.Client _client;

  Future<List<Todo>> fetchTodos() async {
    final uri = Uri.parse('${AppConstants.goRestBaseUrl}/todos');
    final response = await _client.get(uri);
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'GET /todos failed (${response.statusCode})',
        uri: uri,
      );
    }
    final body = jsonDecode(response.body) as List<dynamic>;
    return body
        .map((item) => Todo.fromMap(item as Map<String, dynamic>))
        .toList();
  }
}
