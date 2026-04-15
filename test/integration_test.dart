/// End-to-end integration test.
///
/// Starts a real Dart REST backend in-process (no device needed),
/// then drives the full todo lifecycle through [TodoApiClient].
///
/// Covers: list → create → update (complete) → delete
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
// ignore: depend_on_referenced_packages
import 'package:todolist_server/server.dart' as server_lib;
import 'package:todolist_ai_native/src/api/todo_api_client.dart';

void main() {
  late HttpServer httpServer;
  late TodoApiClient client;

  setUpAll(() async {
    httpServer = await server_lib.createServer(port: 0);
    client = TodoApiClient(baseUrl: 'http://127.0.0.1:${httpServer.port}');
  });

  tearDownAll(() async {
    await httpServer.close(force: true);
  });

  group('End-to-end todo lifecycle', () {
    test('list is empty at start', () async {
      final todos = await client.list();
      expect(todos, isEmpty);
    });

    test('create adds a todo', () async {
      final created = await client.create(title: 'Buy groceries');
      expect(created.id, isNotEmpty);
      expect(created.title, 'Buy groceries');
      expect(created.completed, isFalse);

      final list = await client.list();
      expect(list, hasLength(1));
      expect(list.first.title, 'Buy groceries');
    });

    test('update marks todo as completed', () async {
      final list = await client.list();
      final todo = list.first;
      final updated = await client.update(todo.id, completed: true);
      expect(updated.completed, isTrue);

      final refreshed = await client.list();
      expect(refreshed.first.completed, isTrue);
    });

    test('delete removes the todo', () async {
      final list = await client.list();
      await client.delete(list.first.id);

      final afterDelete = await client.list();
      expect(afterDelete, isEmpty);
    });

    test('full lifecycle: create multiple, complete one, delete all', () async {
      final a = await client.create(title: 'Task A');
      final b = await client.create(title: 'Task B');
      final c = await client.create(title: 'Task C');

      // Complete B
      await client.update(b.id, completed: true);
      final afterComplete = await client.list();
      final bUpdated = afterComplete.firstWhere((t) => t.id == b.id);
      expect(bUpdated.completed, isTrue);

      // A and C still incomplete
      expect(afterComplete.firstWhere((t) => t.id == a.id).completed, isFalse);
      expect(afterComplete.firstWhere((t) => t.id == c.id).completed, isFalse);

      // Delete all
      for (final t in [a, b, c]) {
        await client.delete(t.id);
      }
      expect(await client.list(), isEmpty);
    });
  });
}
