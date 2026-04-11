import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/api/todo_model.dart';

void main() {
  group('TodoModel', () {
    group('fromJson', () {
      test('parses model with all fields', () {
        final json = <String, dynamic>{
          'id': '123',
          'title': 'Test Todo',
          'description': 'A test todo item',
          'completed': true,
        };

        final todo = TodoModel.fromJson(json);

        expect(todo.id, '123');
        expect(todo.title, 'Test Todo');
        expect(todo.description, 'A test todo item');
        expect(todo.completed, isTrue);
        expect(todo.projectId, isNull);
      });

      test('uses empty string for missing description', () {
        final json = <String, dynamic>{
          'id': '123',
          'title': 'Test Todo',
          'completed': false,
        };

        final todo = TodoModel.fromJson(json);

        expect(todo.description, '');
      });

      test('uses false for missing completed field', () {
        final json = <String, dynamic>{
          'id': '123',
          'title': 'Test Todo',
          'description': 'A test todo item',
        };

        final todo = TodoModel.fromJson(json);

        expect(todo.completed, isFalse);
      });

      test('parses model with projectId field', () {
        final json = <String, dynamic>{
          'id': '123',
          'title': 'Test Todo',
          'description': 'A test todo item',
          'completed': true,
          'projectId': 'project-456',
        };

        final todo = TodoModel.fromJson(json);

        expect(todo.id, '123');
        expect(todo.title, 'Test Todo');
        expect(todo.description, 'A test todo item');
        expect(todo.completed, isTrue);
        expect(todo.projectId, 'project-456');
      });
    });

    group('toJson', () {
      test('serializes all fields', () {
        final todo = TodoModel(
          id: '123',
          title: 'Test Todo',
          description: 'A test todo item',
          completed: true,
        );

        final json = todo.toJson();

        expect(json['id'], '123');
        expect(json['title'], 'Test Todo');
        expect(json['description'], 'A test todo item');
        expect(json['completed'], isTrue);
        expect(json['projectId'], isNull);
      });

      test('toJson includes projectId when present', () {
        final todo = TodoModel(
          id: '123',
          title: 'Test Todo',
          description: 'A test todo item',
          completed: true,
          projectId: 'project-456',
        );

        final json = todo.toJson();

        expect(json['id'], '123');
        expect(json['title'], 'Test Todo');
        expect(json['description'], 'A test todo item');
        expect(json['completed'], isTrue);
        expect(json['projectId'], 'project-456');
      });
    });
  });
}