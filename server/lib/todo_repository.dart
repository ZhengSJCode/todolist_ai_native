import 'package:uuid/uuid.dart';
import 'todo.dart';
import 'voice_kanban_models.dart';

/// In-memory repository for Todo items.
class TodoRepository {
  final _store = <String, Todo>{};
  final _rawEntries = <String, RawEntry>{};
  final _parsedItems = <String, ParsedItem>{};
  final _uuid = const Uuid();

  // --- Voice Kanban ---

  CreateEntryResult createEntry({
    required String rawText,
    required String sourceType,
    required List<ParsedDraft> drafts,
  }) {
    final entryId = _uuid.v4();
    final now = DateTime.now();

    final rawEntry = RawEntry(
      id: entryId,
      sourceType: sourceType,
      rawText: rawText,
      createdAt: now,
    );
    _rawEntries[entryId] = rawEntry;

    final items = drafts.map((d) {
      return ParsedItem(
        id: _uuid.v4(),
        rawEntryId: entryId,
        type: d.type,
        content: d.content,
        title: d.title,
        value: d.value,
        unit: d.unit,
        createdAt: now,
      );
    }).toList();

    for (var item in items) {
      _parsedItems[item.id] = item;
    }

    return CreateEntryResult(rawEntry: rawEntry, items: items);
  }

  List<ParsedItem> listItems({String? type}) {
    var items = _parsedItems.values.toList();

    if (type != null && type != 'all') {
      items = items.where((i) => i.type == type).toList();
    }

    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  // --- Projects ---

  List<Todo> list({String? projectId}) {
    final todos = _store.values;
    if (projectId != null) {
      return todos.where((t) => t.projectId == projectId).toList()
        ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
    return todos.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Todo create({required String title, String description = '', String? projectId}) {
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
      projectId: projectId,
    );
    _store[todo.id] = todo;
    return todo;
  }

  /// Returns null when the id is not found.
  Todo? update(
    String id, {
    String? title,
    String? description,
    bool? completed,
    String? projectId,
  }) {
    final existing = _store[id];
    if (existing == null) return null;
    final updated = existing.copyWith(
      title: title,
      description: description,
      completed: completed,
      projectId: projectId,
    );
    _store[id] = updated;
    return updated;
  }

  /// Returns true when deleted, false when not found.
  bool delete(String id) {
    if (!_store.containsKey(id)) return false;
    _store.remove(id);
    return true;
  }

  /// Exposed for tests.
  void clear() => _store.clear();
}
