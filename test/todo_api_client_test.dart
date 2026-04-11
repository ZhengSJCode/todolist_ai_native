import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/todo_api_client.dart';

import 'todo_api_client_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  late MockClient mockClient;
  late TodoApiClient client;

  setUp(() {
    mockClient = MockClient();
    client = TodoApiClient(
      httpClient: mockClient,
      baseUrl: 'http://192.168.67.235:9001',
    );
  });

  group('TodoApiClient.list', () {
    test('returns list of todos on 200', () async {
      final todos = [
        {'id': '1', 'title': 'A', 'description': '', 'completed': false},
        {'id': '2', 'title': 'B', 'description': '', 'completed': true},
      ];
      when(
        mockClient.get(Uri.parse('http://192.168.67.235:9001/todos')),
      ).thenAnswer((_) async => http.Response(jsonEncode(todos), 200));

      final result = await client.list();
      expect(result, hasLength(2));
      expect(result.first.title, 'A');
      expect(result.last.completed, isTrue);
    });

    test('throws ApiException on non-200', () async {
      when(
        mockClient.get(any),
      ).thenAnswer((_) async => http.Response('error', 500));
      expect(() => client.list(), throwsA(isA<ApiException>()));
    });
  });

  group('TodoApiClient.create', () {
    test('returns created todo on 201', () async {
      final payload = {
        'id': 'abc',
        'title': 'Buy milk',
        'description': '',
        'completed': false,
      };
      when(
        mockClient.post(
          Uri.parse('http://192.168.67.235:9001/todos'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(payload), 201));

      final result = await client.create(title: 'Buy milk');
      expect(result.id, 'abc');
      expect(result.title, 'Buy milk');
    });
  });

  group('TodoApiClient.update', () {
    test('returns updated todo on 200', () async {
      final payload = {
        'id': '1',
        'title': 'Updated',
        'description': '',
        'completed': true,
      };
      when(
        mockClient.patch(
          Uri.parse('http://192.168.67.235:9001/todos/1'),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        ),
      ).thenAnswer((_) async => http.Response(jsonEncode(payload), 200));

      final result = await client.update(
        '1',
        title: 'Updated',
        completed: true,
      );
      expect(result.title, 'Updated');
      expect(result.completed, isTrue);
    });
  });

  group('TodoApiClient.delete', () {
    test('completes on 204', () async {
      when(
        mockClient.delete(Uri.parse('http://192.168.67.235:9001/todos/1')),
      ).thenAnswer((_) async => http.Response('', 204));
      await expectLater(client.delete('1'), completes);
    });
  });
}
