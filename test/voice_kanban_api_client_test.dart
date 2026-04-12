import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/todo_api_client.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_api_client.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_model.dart';
import 'dart:convert';

@GenerateNiceMocks([MockSpec<http.Client>()])
import 'voice_kanban_api_client_test.mocks.dart';

void main() {
  group('VoiceKanbanApiClient', () {
    late VoiceKanbanApiClient client;
    late MockClient mockHttpClient;
    const baseUrl = 'http://test';

    setUp(() {
      mockHttpClient = MockClient();
      client = VoiceKanbanApiClient(httpClient: mockHttpClient, baseUrl: baseUrl);
    });

    test('C1: parse sends POST to /parse', () async {
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/parse'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'items': [
                {'type': 'task', 'content': 'test task'}
              ]
            }),
            200,
          ));

      final drafts = await client.parse('test text');
      expect(drafts.length, 1);
      expect(drafts.first.type, ParsedItemType.task);

      final captured = verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: captureAnyNamed('body'))).captured;
      final body = jsonDecode(captured.first as String) as Map<String, dynamic>;
      expect(body['rawText'], 'test text');
    });

    test('C2: createEntry sends POST to /entries', () async {
      when(mockHttpClient.post(
        Uri.parse('$baseUrl/entries'),
        headers: anyNamed('headers'),
        body: anyNamed('body'),
      )).thenAnswer((_) async => http.Response(
            jsonEncode({
              'rawEntry': {
                'id': 'entry-1',
                'sourceType': 'text',
                'rawText': 'test text',
                'createdAt': '2026-04-12T10:00:00.000Z'
              },
              'items': []
            }),
            201,
          ));

      final res = await client.createEntry('test text');
      expect(res.rawEntry.id, 'entry-1');

      final captured = verify(mockHttpClient.post(any, headers: anyNamed('headers'), body: captureAnyNamed('body'))).captured;
      final body = jsonDecode(captured.first as String) as Map<String, dynamic>;
      expect(body['rawText'], 'test text');
    });

    test('C3: listItems without type filter requests type=all', () async {
      when(mockHttpClient.get(Uri.parse('$baseUrl/items?type=all')))
          .thenAnswer((_) async => http.Response('[]', 200));

      final items = await client.listItems();
      expect(items, isEmpty);

      verify(mockHttpClient.get(Uri.parse('$baseUrl/items?type=all'))).called(1);
    });

    test('C4: listItems with metric type filter requests type=metric', () async {
      when(mockHttpClient.get(Uri.parse('$baseUrl/items?type=metric')))
          .thenAnswer((_) async => http.Response('[]', 200));

      await client.listItems(type: ParsedItemType.metric);

      verify(mockHttpClient.get(Uri.parse('$baseUrl/items?type=metric'))).called(1);
    });

    test('C5: 400 response throws ApiException with server error message', () async {
      when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((_) async => http.Response(jsonEncode({'error': 'Server error details'}), 400));

      try {
        await client.parse('test text');
        fail('Should throw exception');
      } catch (e) {
        expect(e, isA<ApiException>());
        expect((e as ApiException).statusCode, 400);
        expect(e.body, 'Server error details');
      }
    });
  });
}
