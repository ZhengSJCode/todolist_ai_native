import 'dart:convert';
import 'package:http/http.dart' as http;
import 'todo_model.dart';

/// REST client for the todo backend.
///
/// [baseUrl] defaults to `http://192.168.67.235:9001` for local development.
class TodoApiClient {
  TodoApiClient({http.Client? httpClient, String? baseUrl})
    : _client = httpClient ?? http.Client(),
      _base = baseUrl ?? 'http://192.168.67.235:9001';

  final http.Client _client;
  final String _base;

  Future<List<TodoModel>> list() async {
    final res = await _client.get(Uri.parse('$_base/todos'));
    _assertOk(res);
    final data = jsonDecode(res.body) as List<dynamic>;
    return data
        .map((e) => TodoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TodoModel> create({
    required String title,
    String description = '',
    String? projectId,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      'description': description,
    };

    if (projectId != null) {
      body['projectId'] = projectId;
    }

    final res = await _client.post(
      Uri.parse('$_base/todos'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    _assertOk(res, expected: 201);
    return TodoModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<TodoModel> update(
    String id, {
    String? title,
    String? description,
    bool? completed,
    String? projectId,
  }) async {
    final body = <String, dynamic>{};
    if (title != null) body['title'] = title;
    if (description != null) body['description'] = description;
    if (completed != null) body['completed'] = completed;
    if (projectId != null) body['projectId'] = projectId;

    final res = await _client.patch(
      Uri.parse('$_base/todos/$id'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode(body),
    );
    _assertOk(res);
    return TodoModel.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<void> delete(String id) async {
    final res = await _client.delete(Uri.parse('$_base/todos/$id'));
    _assertOk(res, expected: 204);
  }

  void _assertOk(http.Response res, {int expected = 200}) {
    if (res.statusCode != expected) {
      throw ApiException(res.statusCode, res.body);
    }
  }
}

class ApiException implements Exception {
  const ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  @override
  String toString() => 'ApiException($statusCode): $body';
}
