import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'todo_repository.dart';
import 'voice_kanban_parser.dart';
import 'voice_transcriber.dart';

/// Creates and starts an HTTP server bound to [port].
/// If [port] is 0, the OS will pick a free port.
/// Returns the [HttpServer] instance so callers can close it and inspect its port.
Future<HttpServer> createServer({
  int port = 8080,
  TodoRepository? repository,
  VoiceTranscriber? transcriber,
  InternetAddress? address,
}) async {
  final repo = repository ?? TodoRepository();
  final router = Router();

  // GET /todos
  router.get('/todos', (Request req) {
    final projectId = req.url.queryParameters['projectId'];
    final todos = repo
        .list(projectId: projectId)
        .map((t) => t.toJson())
        .toList();
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

    return _json({
      'items': drafts.map((d) => d.toJson()).toList(),
    }, statusCode: 200);
  });

  // POST /entries
  router.post('/entries', (Request req) async {
    final body = await _parseBody(req);
    final rawText = body['rawText'] as String?;
    final sourceType = body['sourceType'] as String? ?? 'text';

    if (sourceType != 'text' && sourceType != 'voice') {
      return _error(
        400,
        'Invalid sourceType, only "text" or "voice" are supported',
      );
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

  // POST /voice/transcribe
  router.post('/voice/transcribe', (Request req) async {
    final voiceTranscriber = transcriber;
    if (voiceTranscriber == null) {
      return _error(503, 'voice transcription is not configured');
    }

    final bytes = await _readBytes(req);
    if (bytes.isEmpty) {
      return _error(400, 'audio body is required');
    }

    final format = req.headers['x-audio-format'];
    if (format != 'pcm_s16le') {
      return _error(400, 'x-audio-format must be pcm_s16le');
    }

    final sampleRateValue = req.headers['x-sample-rate'];
    final sampleRateHz = int.tryParse(sampleRateValue ?? '');
    if (sampleRateHz == null || sampleRateHz <= 0) {
      return _error(400, 'x-sample-rate must be a positive integer');
    }

    final fileName = req.headers['x-file-name'] ?? 'voice-input.pcm';
    final payload = VoiceAudioPayload(
      bytes: bytes,
      fileName: fileName,
      mimeType: req.mimeType ?? req.headers['content-type'] ?? 'application/octet-stream',
      format: format!,
      sampleRateHz: sampleRateHz,
    );

    try {
      final transcript = await voiceTranscriber.transcribe(payload);
      return _json({'transcript': transcript}, statusCode: 200);
    } on VoiceTranscriptionException catch (e) {
      return _error(502, e.message);
    }
  });

  // GET /items
  router.get('/items', (Request req) {
    final type = req.url.queryParameters['type'];
    if (type != null &&
        type != 'all' &&
        type != 'task' &&
        type != 'metric' &&
        type != 'note') {
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
    address ?? InternetAddress.anyIPv4,
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

Future<List<int>> _readBytes(Request req) async {
  final builder = BytesBuilder(copy: false);
  await for (final chunk in req.read()) {
    builder.add(chunk);
  }
  return builder.takeBytes();
}
