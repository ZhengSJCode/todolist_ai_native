import 'dart:convert';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'todo_repository.dart';
import 'voice_kanban_parser.dart';

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
    final projectId = req.url.queryParameters['projectId'];
    final todos = repo.list(projectId: projectId).map((t) => t.toJson()).toList();
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
      projectId: body['projectId'] as String?,
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
      projectId: body['projectId'] as String?,
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

  // POST /parse
  router.post('/parse', (Request req) async {
    final body = await _parseBody(req);
    final rawText = body['rawText'] as String?;
    final sourceType = body['sourceType'] as String? ?? 'text';

    if (sourceType != 'text') {
      return _error(400, 'Invalid sourceType, only "text" is supported');
    }

    if (rawText == null || rawText.trim().isEmpty) {
      return _error(400, 'rawText is required and cannot be empty');
    }

    final parser = RuleBasedEntryParser();
    final drafts = await parser.parse(rawText);

    return _json({'items': drafts.map((d) => d.toJson()).toList()}, statusCode: 200);
  });

  // POST /entries
  router.post('/entries', (Request req) async {
    final body = await _parseBody(req);
    final rawText = body['rawText'] as String?;
    final sourceType = body['sourceType'] as String? ?? 'text';

    if (sourceType != 'text') {
      return _error(400, 'Invalid sourceType, only "text" is supported');
    }

    if (rawText == null || rawText.trim().isEmpty) {
      return _error(400, 'rawText is required and cannot be empty');
    }

    final parser = RuleBasedEntryParser();
    final drafts = await parser.parse(rawText);

    final result = repo.createEntry(
      rawText: rawText.trim(),
      sourceType: sourceType,
      drafts: drafts,
    );

    return _json(result.toJson(), statusCode: 201);
  });

  // GET /items
  router.get('/items', (Request req) {
    final type = req.url.queryParameters['type'];
    if (type != null && type != 'all' && type != 'task' && type != 'metric' && type != 'note') {
      return _error(400, 'Invalid type parameter');
    }

    final items = repo.listItems(type: type);
    return _json(items.map((i) => i.toJson()).toList(), statusCode: 200);
  });

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addHandler(router.call);

  final server = await shelf_io.serve(
    handler,
    InternetAddress('192.168.67.235'),
    port,
  );
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
