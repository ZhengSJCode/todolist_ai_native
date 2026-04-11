import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/todo_api_client.dart';
import '../api/todo_model.dart';

part 'todo_provider.g.dart';

/// Provides the singleton [TodoApiClient].
@riverpod
TodoApiClient todoApiClient(TodoApiClientRef ref) {
  return TodoApiClient();
}

/// AsyncNotifier that owns the todo list state.
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<TodoModel>> build() async {
    return ref.read(todoApiClientProvider).list();
  }

  Future<void> create({required String title, String description = ''}) async {
    final client = ref.read(todoApiClientProvider);
    final newTodo = await client.create(title: title, description: description);
    state = AsyncData([...state.valueOrNull ?? [], newTodo]);
  }

  Future<void> toggleCompleted(TodoModel todo) async {
    final client = ref.read(todoApiClientProvider);
    final updated = await client.update(todo.id, completed: !todo.completed);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((t) => t.id == updated.id ? updated : t)
          .toList(),
    );
  }

  Future<void> delete(String id) async {
    final client = ref.read(todoApiClientProvider);
    await client.delete(id);
    state = AsyncData(
      (state.valueOrNull ?? []).where((t) => t.id != id).toList(),
    );
  }

  Future<void> editTitle(String id, String newTitle) async {
    final client = ref.read(todoApiClientProvider);
    final updated = await client.update(id, title: newTitle);
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((t) => t.id == updated.id ? updated : t)
          .toList(),
    );
  }
}
