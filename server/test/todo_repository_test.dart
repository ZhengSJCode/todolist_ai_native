import 'package:test/test.dart';
import '../lib/todo_repository.dart';

void main() {
  late TodoRepository repo;

  setUp(() {
    repo = TodoRepository();
  });

  group('TodoRepository', () {
    test('list returns empty on init', () {
      expect(repo.list(), isEmpty);
    });

    test('create adds a todo and returns it', () {
      final todo = repo.create(title: 'Buy milk');
      expect(todo.title, 'Buy milk');
      expect(todo.completed, isFalse);
      expect(repo.list(), hasLength(1));
    });

    test('create with description stores description', () {
      final todo = repo.create(title: 'Buy milk', description: 'Whole milk');
      expect(todo.description, 'Whole milk');
    });

    test('list returns all created todos in insertion order', () {
      repo.create(title: 'A');
      repo.create(title: 'B');
      repo.create(title: 'C');
      final titles = repo.list().map((t) => t.title).toList();
      expect(titles, ['A', 'B', 'C']);
    });

    test('update changes fields and returns updated todo', () {
      final original = repo.create(title: 'Old title');
      final updated = repo.update(original.id, title: 'New title', completed: true);
      expect(updated, isNotNull);
      expect(updated!.title, 'New title');
      expect(updated.completed, isTrue);
      expect(repo.list().first.title, 'New title');
    });

    test('update returns null for unknown id', () {
      final result = repo.update('nonexistent-id', title: 'X');
      expect(result, isNull);
    });

    test('delete removes the todo and returns true', () {
      final todo = repo.create(title: 'Remove me');
      final deleted = repo.delete(todo.id);
      expect(deleted, isTrue);
      expect(repo.list(), isEmpty);
    });

    test('delete returns false for unknown id', () {
      expect(repo.delete('nonexistent-id'), isFalse);
    });
  });
}
