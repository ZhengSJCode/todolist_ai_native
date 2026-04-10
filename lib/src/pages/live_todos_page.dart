import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/todo_model.dart';
import '../provider/todo_provider.dart';

/// A live todos page connected to the REST backend via Riverpod.
///
/// Used as the "Today's Tasks" tab when a real backend is available.
class LiveTodosPage extends ConsumerWidget {
  const LiveTodosPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTodos = ref.watch(todoListProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          children: [
            _LiveHeader(onAdd: () => _showCreateDialog(context, ref)),
            Expanded(
              child: asyncTodos.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Error: $e')),
                data: (todos) => todos.isEmpty
                    ? const _EmptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                        itemCount: todos.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final todo = todos[index];
                          return _TodoTile(todo: todo);
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Task'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Task title'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              final title = controller.text.trim();
              if (title.isEmpty) return;
              Navigator.pop(ctx);
              await ref
                  .read(todoListProvider.notifier)
                  .create(title: title);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _LiveHeader extends StatelessWidget {
  const _LiveHeader({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'My Tasks',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            key: const Key('add-task-btn'),
            onPressed: onAdd,
            icon: const Icon(Icons.add_circle_rounded, size: 32, color: Color(0xFF5F33E1)),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No tasks yet. Tap + to add one.',
        style: TextStyle(color: Color(0xFF9E9E9E)),
      ),
    );
  }
}

class _TodoTile extends ConsumerWidget {
  const _TodoTile({required this.todo});
  final TodoModel todo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: Key('todo-${todo.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFFF5252),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) =>
          ref.read(todoListProvider.notifier).delete(todo.id),
      child: GestureDetector(
        onTap: () =>
            ref.read(todoListProvider.notifier).toggleCompleted(todo),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0A000000),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                todo.completed
                    ? Icons.check_circle_rounded
                    : Icons.radio_button_unchecked_rounded,
                color: todo.completed
                    ? const Color(0xFF5F33E1)
                    : const Color(0xFFBDBDBD),
                size: 24,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  todo.title,
                  style: TextStyle(
                    fontSize: 15,
                    decoration: todo.completed
                        ? TextDecoration.lineThrough
                        : TextDecoration.none,
                    color: todo.completed
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF24252C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
