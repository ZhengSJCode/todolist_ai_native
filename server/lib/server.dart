import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'todo_repository.dart';

/// Creates and starts an HTTP server bound to [port].
/// If [port] is 0, the OS will pick a free port.
/// Returns the [HttpServer] instance so callers can close it and inspect its port.
Future<HttpServer> createServer({
  int port = 8080,
  TodoRepository? repository,
}) async {
  final repo = repository ?? TodoRepository();
  final router = Router();

  // GET /todos
  router.get('/todos', (Request req) {
    final todos = repo.list().map((t) => t.toJson()).toList();
    return _json(todos, statusCode: 200);
  });

  // POST /todos
  router.post('/todos', (Request req) async {
    final body = await _parseBody(req);
    final title = body['title'] as String?;
    if (title == null || title.trim().isEmpty) {
      return _error(400, 'title is required');
    }
    final todo = repo.create(
      title: title.trim(),
      description: (body['description'] as String?) ?? '',
    );
    return _json(todo.toJson(), statusCode: 201);
  });

  // PATCH /todos/:id
  router.patch('/todos/<id>', (Request req, String id) async {
    final body = await _parseBody(req);
    final updated = repo.update(
      id,
      title: body['title'] as String?,
      description: body['description'] as String?,
      completed: body['completed'] as bool?,
    );
    if (updated == null) return _error(404, 'not found');
    return _json(updated.toJson(), statusCode: 200);
  });

  // DELETE /todos/:id
  router.delete('/todos/<id>', (Request req, String id) {
    final deleted = repo.delete(id);
    if (!deleted) return _error(404, 'not found');
    return Response(204);
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(handler, InternetAddress.loopbackIPv4, port);
  return server;
}

Response _json(dynamic data, {int statusCode = 200}) => Response(
      statusCode,
      body: jsonEncode(data),
      headers: {'content-type': 'application/json'},
    );

Response _error(int status, String message) => Response(
      status,
      body: jsonEncode({'error': message}),
      headers: {'content-type': 'application/json'},
    );

Future<Map<String, dynamic>> _parseBody(Request req) async {
  final body = await req.readAsString();
  if (body.isEmpty) return {};
  return jsonDecode(body) as Map<String, dynamic>;
}
