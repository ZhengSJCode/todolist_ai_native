import 'todo_model.dart';

/// Abstract todo data access contract used by state layer.
abstract interface class TodoRepository {
  Future<List<TodoModel>> list();

  Future<TodoModel> create({
    required String title,
    String description = '',
    String? projectId,
  });

  Future<TodoModel> update(
    String id, {
    String? title,
    String? description,
    bool? completed,
    String? projectId,
  });

  Future<void> delete(String id);
}
