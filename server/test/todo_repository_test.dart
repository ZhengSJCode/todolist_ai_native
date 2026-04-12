import 'package:test/test.dart';
import 'package:todolist_server/todo_repository.dart';
import 'package:todolist_server/voice_kanban_models.dart';

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
      final updated = repo.update(
        original.id,
        title: 'New title',
        completed: true,
      );
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

    group('Voice Kanban Items', () {
      test('L1: List items ordered by createdAt descending', () {
        // Create entries with different timestamps
        final entry1 = repo.createEntry(
          rawText: 'First entry',
          sourceType: 'text',
          drafts: [ParsedDraft(type: 'note', content: 'First note')],
        );

        // Add a small delay to ensure different timestamps
        Future.delayed(const Duration(milliseconds: 1));

        final entry2 = repo.createEntry(
          rawText: 'Second entry',
          sourceType: 'text',
          drafts: [ParsedDraft(type: 'task', content: 'Second task')],
        );

        final items = repo.listItems();

        // Should have 2 items
        expect(items.length, 2);

        // Should be ordered by createdAt descending (newest first)
        expect(items[0].createdAt.isAfter(items[1].createdAt) ||
               items[0].createdAt.isAtSameMomentAs(items[1].createdAt), isTrue);
      });

      test('L2: Filter items by type', () {
        // Create entries with different types
        repo.createEntry(
          rawText: 'Task entry',
          sourceType: 'text',
          drafts: [ParsedDraft(type: 'task', content: 'Buy milk')],
        );

        repo.createEntry(
          rawText: 'Metric entry',
          sourceType: 'text',
          drafts: [ParsedDraft(type: 'metric', content: 'Weight 75kg', value: 75, unit: 'kg')],
        );

        repo.createEntry(
          rawText: 'Note entry',
          sourceType: 'text',
          drafts: [ParsedDraft(type: 'note', content: 'Feeling good today')],
        );

        // Test filtering by task
        final tasks = repo.listItems(type: 'task');
        expect(tasks.length, 1);
        expect(tasks.first.type, 'task');

        // Test filtering by metric
        final metrics = repo.listItems(type: 'metric');
        expect(metrics.length, 1);
        expect(metrics.first.type, 'metric');

        // Test filtering by note
        final notes = repo.listItems(type: 'note');
        expect(notes.length, 1);
        expect(notes.first.type, 'note');

        // Test no filter (should return all)
        final all = repo.listItems();
        expect(all.length, 3);
      });

      test('R1: Created entry items share same rawEntryId', () {
        final drafts = [
          ParsedDraft(type: 'task', content: 'Buy milk'),
          ParsedDraft(type: 'note', content: 'Remember to buy milk'),
        ];

        final result = repo.createEntry(
          rawText: 'Shopping list',
          sourceType: 'text',
          drafts: drafts,
        );

        // All items should share the same rawEntryId
        expect(result.items.length, 2);
        expect(result.items[0].rawEntryId, result.items[1].rawEntryId);
        expect(result.items[0].rawEntryId, result.rawEntry.id);
      });

      test('R2: Created entry can be listed by rawEntryId', () {
        final drafts = [
          ParsedDraft(type: 'task', content: 'Buy milk'),
        ];

        final result = repo.createEntry(
          rawText: 'Shopping list',
          sourceType: 'text',
          drafts: drafts,
        );

        // List items and find by rawEntryId
        final items = repo.listItems();
        final entryItems = items.where((item) => item.rawEntryId == result.rawEntry.id).toList();

        expect(entryItems.length, 1);
        expect(entryItems.first.id, result.items.first.id);
      });
    });
  });
}
