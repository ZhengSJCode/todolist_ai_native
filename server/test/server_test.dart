import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:todolist_server/server.dart';

void main() {
  late HttpServer httpServer;
  late String baseUrl;

  setUp(() async {
    httpServer = await createServer(port: 0); // OS picks a free port
    baseUrl = 'http://192.168.67.235:${httpServer.port}';
  });

  tearDown(() async {
    await httpServer.close(force: true);
  });

  group('GET /todos', () {
    test('returns 200 and empty list on fresh start', () async {
      final res = await http.get(Uri.parse('$baseUrl/todos'));
      expect(res.statusCode, 200);
      final body = jsonDecode(res.body) as List;
      expect(body, isEmpty);
    });
  });

  group('POST /todos', () {
    test('returns 201 and created todo', () async {
      final res = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'title': 'Buy milk'}),
      );
      expect(res.statusCode, 201);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      expect(body['title'], 'Buy milk');
      expect(body['id'], isNotEmpty);
      expect(body['completed'], isFalse);
    });

    test('returns 400 when title is missing', () async {
      final res = await http.post(
        Uri.parse('$baseUrl/todos'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({}),
      );
      expect(res.statusCode, 400);
    });
  });

  group('PATCH /todos/:id', () {
    test('returns 200 and updated todo', () async {
      final created =
          jsonDecode(
                (await http.post(
                  Uri.parse('$baseUrl/todos'),
                  headers: {'content-type': 'application/json'},
                  body: jsonEncode({'title': 'Original'}),
                )).body,
              )
              as Map<String, dynamic>;

      final res = await http.patch(
        Uri.parse('$baseUrl/todos/${created['id']}'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'title': 'Updated', 'completed': true}),
      );
      expect(res.statusCode, 200);
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      expect(body['title'], 'Updated');
      expect(body['completed'], isTrue);
    });

    test('returns 404 for unknown id', () async {
      final res = await http.patch(
        Uri.parse('$baseUrl/todos/nonexistent'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'title': 'X'}),
      );
      expect(res.statusCode, 404);
    });
  });

  group('DELETE /todos/:id', () {
    test('returns 204 when deleted', () async {
      final created =
          jsonDecode(
                (await http.post(
                  Uri.parse('$baseUrl/todos'),
                  headers: {'content-type': 'application/json'},
                  body: jsonEncode({'title': 'Delete me'}),
                )).body,
              )
              as Map<String, dynamic>;

      final res = await http.delete(
        Uri.parse('$baseUrl/todos/${created['id']}'),
      );
      expect(res.statusCode, 204);

      // Verify it's gone
      final listRes = await http.get(Uri.parse('$baseUrl/todos'));
      final list = jsonDecode(listRes.body) as List;
      expect(list, isEmpty);
    });

    test('returns 404 for unknown id', () async {
      final res = await http.delete(Uri.parse('$baseUrl/todos/nonexistent'));
      expect(res.statusCode, 404);
    });
  });
}
