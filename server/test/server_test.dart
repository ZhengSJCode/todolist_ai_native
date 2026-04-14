import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:test/test.dart';
import 'package:todolist_server/server.dart';
import 'package:todolist_server/voice_transcriber.dart';

class FakeVoiceTranscriber implements VoiceTranscriber {
  FakeVoiceTranscriber({this.transcript = '买鸡蛋', this.shouldFail = false});

  final String transcript;
  final bool shouldFail;
  VoiceAudioPayload? lastPayload;

  @override
  Future<String> transcribe(VoiceAudioPayload payload) async {
    lastPayload = payload;
    if (shouldFail) {
      throw const VoiceTranscriptionException('transcriber failed');
    }
    return transcript;
  }
}

void main() {
  late HttpServer httpServer;
  late String baseUrl;
  late FakeVoiceTranscriber fakeVoiceTranscriber;

  setUp(() async {
    fakeVoiceTranscriber = FakeVoiceTranscriber();
    httpServer = await createServer(port: 0, transcriber: fakeVoiceTranscriber);
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

  group('POST /parse', () {
    test('S1: Valid text returns draft list without IDs', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/parse'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '买鸡蛋'}),
      );
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['items'] as List;
      expect(items, isNotEmpty);
      expect(items.first['type'], 'task');
      expect(items.first['content'], '买鸡蛋');
      expect(items.first.containsKey('id'), isFalse);
      expect(items.first.containsKey('rawEntryId'), isFalse);
      expect(items.first.containsKey('createdAt'), isFalse);
    });

    test('S2: PRD example sentences should return multiple items', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/parse'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '今天体重75.5kg，下班去买5斤鸡胸肉，这周感觉力量训练有进步'}),
      );
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['items'] as List;
      expect(items.length, greaterThanOrEqualTo(3));

      final metric = items.firstWhere((i) => i['type'] == 'metric');
      expect(metric['value'], 75.5);

      final task = items.firstWhere((i) => i['type'] == 'task');
      expect(task['content'], '买 5 斤鸡胸肉');
    });

    test('S3: Whitespace only rawText returns 400', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/parse'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '   \n\t  '}),
      );
      expect(response.statusCode, 400);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['error'], isNotEmpty);
    });

    test('S4: Missing rawText returns 400', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/parse'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({}),
      );
      expect(response.statusCode, 400);
    });

    test('S5: Invalid sourceType returns 400', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/parse'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': 'test', 'sourceType': 'voice'}),
      );
      expect(response.statusCode, 400);
    });

    test('S6: parse is side-effect free', () async {
      // Call parse
      final response = await http.post(
        Uri.parse('$baseUrl/parse'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '测试副作用'}),
      );
      expect(response.statusCode, 200);
      // As we haven't implemented /entries or /items yet, we verify that /todos remain empty
      final listRes = await http.get(Uri.parse('$baseUrl/todos'));
      final list = jsonDecode(listRes.body) as List;
      expect(list, isEmpty);
    });
  });

  group('POST /entries', () {
    test('P1: Valid text creates entry and items', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '买鸡蛋'}),
      );
      expect(response.statusCode, 201);
      final body = jsonDecode(response.body) as Map<String, dynamic>;

      final rawEntry = body['rawEntry'] as Map<String, dynamic>;
      expect(rawEntry['id'], isNotEmpty);
      expect(rawEntry['rawText'], '买鸡蛋');
      expect(rawEntry['sourceType'], 'text');

      final items = body['items'] as List;
      expect(items.length, 1);
      expect(items.first['id'], isNotEmpty);
      expect(items.first['rawEntryId'], rawEntry['id']);
      expect(items.first['type'], 'task');
      expect(items.first['content'], '买鸡蛋');
    });

    test('P2: PRD example sentences separated into multiple items', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '今天体重75.5kg，下班去买5斤鸡胸肉，这周感觉力量训练有进步'}),
      );
      expect(response.statusCode, 201);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final items = body['items'] as List;
      expect(items.length, greaterThanOrEqualTo(3));
    });

    test('P3: Default sourceType is text', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '测试'}),
      );
      expect(response.statusCode, 201);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['rawEntry']['sourceType'], 'text');
    });

    test('P4: Whitespace only rawText returns 400', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '   \n\t  '}),
      );
      expect(response.statusCode, 400);
    });

    test('P5: Missing rawText returns 400', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({}),
      );
      expect(response.statusCode, 400);
    });

    test('P6: Invalid sourceType returns 400', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': 'test', 'sourceType': 'audio'}),
      );
      expect(response.statusCode, 400);
    });
  });

  group('POST /voice/transcribe', () {
    test('V1: returns transcript from the transcriber', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/voice/transcribe'),
        headers: {
          'content-type': 'application/octet-stream',
          'x-audio-format': 'pcm_s16le',
          'x-sample-rate': '16000',
          'x-file-name': 'voice-input.pcm',
        },
        body: [1, 2, 3, 4],
      );

      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      expect(body['transcript'], '买鸡蛋');
      expect(fakeVoiceTranscriber.lastPayload!.bytes, [1, 2, 3, 4]);
      expect(fakeVoiceTranscriber.lastPayload!.format, 'pcm_s16le');
      expect(fakeVoiceTranscriber.lastPayload!.sampleRateHz, 16000);
    });

    test('V2: empty audio body returns 400', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/voice/transcribe'),
        headers: {
          'content-type': 'application/octet-stream',
          'x-audio-format': 'pcm_s16le',
          'x-sample-rate': '16000',
        },
        body: <int>[],
      );

      expect(response.statusCode, 400);
    });
  });

  test('P7: POST /entries accepts sourceType voice', () async {
    final response = await http.post(
      Uri.parse('$baseUrl/entries'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'rawText': '买鸡蛋', 'sourceType': 'voice'}),
    );

    expect(response.statusCode, 201);
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    expect(body['rawEntry']['sourceType'], 'voice');
  });

  group('GET /items', () {
    test('G1: Empty database returns 200 and empty list', () async {
      // First clear store via another way or depend on test isolation (setUp creates fresh server, but repo might not be cleared if singleton, here we create new repo per server because server.dart handles it? Wait, server.dart uses default TodoRepository per createServer. So it's isolated!)
      final response = await http.get(Uri.parse('$baseUrl/items'));
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body, isEmpty);
    });

    test('G2: Multiple items ordered by createdAt descending', () async {
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': 'First note'}),
      );
      await Future.delayed(
        const Duration(milliseconds: 10),
      ); // Ensure different timestamp
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': 'Second note'}),
      );

      final response = await http.get(Uri.parse('$baseUrl/items'));
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body.length, 2);

      final firstTime = DateTime.parse(body[0]['createdAt'] as String);
      final secondTime = DateTime.parse(body[1]['createdAt'] as String);
      expect(
        firstTime.isAfter(secondTime) || firstTime.isAtSameMomentAs(secondTime),
        isTrue,
      );
      expect(body[0]['content'], 'Second note');
      expect(body[1]['content'], 'First note');
    });

    test('G3: Filter type=task', () async {
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '买牛奶'}), // task
      );
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '今天很累'}), // note
      );

      final response = await http.get(Uri.parse('$baseUrl/items?type=task'));
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body.length, 1);
      expect(body.first['type'], 'task');
      expect(body.first['content'], '买牛奶');
    });

    test('G4: Filter type=metric', () async {
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '今天体重75.5kg'}), // metric
      );
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '今天很累'}), // note
      );

      final response = await http.get(Uri.parse('$baseUrl/items?type=metric'));
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body.length, 1);
      expect(body.first['type'], 'metric');
      expect(body.first['content'], '今天体重75.5kg');
    });

    test('G4: Filter type=note', () async {
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '买牛奶'}), // task
      );
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '今天感觉很好'}), // note
      );

      final response = await http.get(Uri.parse('$baseUrl/items?type=note'));
      expect(response.statusCode, 200);
      final body = jsonDecode(response.body) as List;
      expect(body.length, 1);
      expect(body.first['type'], 'note');
      expect(body.first['content'], '今天感觉很好');
    });

    test('G5: type=all same as omitting type', () async {
      await http.post(
        Uri.parse('$baseUrl/entries'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'rawText': '测试条目'}),
      );

      final responseAll = await http.get(Uri.parse('$baseUrl/items?type=all'));
      final responseOmit = await http.get(Uri.parse('$baseUrl/items'));

      expect(responseAll.statusCode, 200);
      expect(responseOmit.statusCode, 200);

      final bodyAll = jsonDecode(responseAll.body) as List;
      final bodyOmit = jsonDecode(responseOmit.body) as List;

      expect(bodyAll.length, bodyOmit.length);
      expect(bodyAll.map((e) => e['id']), bodyOmit.map((e) => e['id']));
    });

    test('G6: Invalid type returns 400', () async {
      final response = await http.get(Uri.parse('$baseUrl/items?type=foo'));
      expect(response.statusCode, 400);
    });
  });
}
