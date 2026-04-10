import 'package:uuid/uuid.dart';
import 'todo.dart';

/// In-memory repository for Todo items.
class TodoRepository {
  final _store = <String, Todo>{};
  final _uuid = const Uuid();

  List<Todo> list() => _store.values.toList()
    ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

  Todo create({required String title, String description = ''}) {
    final todo = Todo(
      id: _uuid.v4(),
      title: title,
      description: description,
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
  }) {
    final existing = _store[id];
    if (existing == null) return null;
    final updated = existing.copyWith(
      title: title,
      description: description,
      completed: completed,
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
