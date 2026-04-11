import 'package:uuid/uuid.dart';
import 'todo.dart';

/// In-memory repository for Todo items.
class TodoRepository {
  final _store = <String, Todo>{};
  final _uuid = const Uuid();

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
