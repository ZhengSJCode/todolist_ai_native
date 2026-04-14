import 'package:flutter_riverpod/flutter_riverpod.dart' show Ref;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/todo_api_client.dart';
import '../api/todo_model.dart';
import '../api/todo_repository.dart';

part 'todo_provider.g.dart';

/// Provides the todo repository abstraction.
@riverpod
TodoRepository todoRepository(Ref ref) {
  return TodoApiClient();
}

/// AsyncNotifier that owns the todo list state.
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<TodoModel>> build() async {
    final allTodos = await ref.read(todoRepositoryProvider).list();

    // Filter todos by projectId if a project is selected
    final projectId = ref.watch(currentProjectIdProvider);
    if (projectId != null) {
      return allTodos.where((todo) => todo.projectId == projectId).toList();
    }

    return allTodos;
  }

  Future<void> create({required String title, String description = '', String? projectId}) async {
    final client = ref.read(todoRepositoryProvider);
    final newTodo = await client.create(title: title, description: description, projectId: projectId);
    state = AsyncData([...state.valueOrNull ?? [], newTodo]);
  }

  Future<void> toggleCompleted(TodoModel todo) async {
    final client = ref.read(todoRepositoryProvider);
    final updated = await client.update(todo.id, completed: !todo.completed);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((t) => t.id == updated.id ? updated : t)
          .toList(),
    );
  }

  Future<void> delete(String id) async {
    final client = ref.read(todoRepositoryProvider);
    await client.delete(id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((t) => t.id != id).toList(),
    );
  }

  Future<void> editTitle(String id, String newTitle) async {
    final client = ref.read(todoRepositoryProvider);
    final updated = await client.update(id, title: newTitle);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((t) => t.id == updated.id ? updated : t)
          .toList(),
    );
  }
}

/// Provider for tracking the currently selected project ID.
/// Returns null when no project is selected (show all todos).
@riverpod
String? currentProjectId(Ref ref) {
  // This will be updated by the UI when a project is selected
  return null;
}
