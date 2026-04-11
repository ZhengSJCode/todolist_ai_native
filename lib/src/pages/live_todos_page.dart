import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/todo_model.dart';
import '../provider/todo_provider.dart';
import 'task_details_page.dart';

/// A live todos page connected to the REST backend via Riverpod.
///
/// Used as the "My Tasks" tab when a real backend is available.
class LiveTodosPage extends ConsumerWidget {
  const LiveTodosPage({super.key, this.onOpenNotifications});

  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncTodos = ref.watch(todoListProvider);

    return Material(
      color: Colors.transparent,
      child: Column(
        children: [
          _LiveHeader(
            onAdd: () => _showTaskComposer(context, ref),
            onOpenNotifications: onOpenNotifications,
          ),
          Expanded(
            child: asyncTodos.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _ErrorState(
                message: '$e',
                onRetry: () => ref.invalidate(todoListProvider),
              ),
              data: (todos) => todos.isEmpty
                  ? _EmptyState(onAdd: () => _showTaskComposer(context, ref))
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
                      itemCount: todos.length,
                      separatorBuilder: (_, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final todo = todos[index];
                        return _TodoTile(todo: todo);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showTaskComposer(
    BuildContext context,
    WidgetRef ref, {
    TodoModel? todo,
  }) async {
    final controller = TextEditingController();
    if (todo != null) {
      controller.text = todo.title;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5DEF8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                todo == null ? 'New Task' : 'Edit Task',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Keep it short and actionable so it is easy to scan later.',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF6E6A7C),
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Task title'),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final title = controller.text.trim();
                        if (title.isEmpty) {
                          return;
                        }
                        Navigator.pop(ctx);
                        if (todo == null) {
                          await ref
                              .read(todoListProvider.notifier)
                              .create(title: title);
                        } else {
                          await ref
                              .read(todoListProvider.notifier)
                              .editTitle(todo.id, title);
                        }
                      },
                      child: Text(todo == null ? 'Add' : 'Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LiveHeader extends StatelessWidget {
  const _LiveHeader({required this.onAdd, this.onOpenNotifications});

  final VoidCallback onAdd;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
      child: Row(
        children: [
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'My Tasks',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Live items synced with the local REST backend.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF6E6A7C)),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onOpenNotifications,
            icon: const Icon(Icons.notifications_none_rounded),
          ),
          IconButton(
            key: const Key('add-task-btn'),
            onPressed: onAdd,
            icon: const Icon(
              Icons.add_circle_rounded,
              size: 32,
              color: Color(0xFF5F33E1),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: const Color(0xFFF1EBFF),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.checklist_rounded,
                color: Color(0xFF5F33E1),
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No tasks yet. Tap + to add one.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF24252C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'This tab is hooked to the backend, so every new task will show up in the live list.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF6E6A7C),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: onAdd,
              child: const Text('Add your first task'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_off_rounded,
              size: 42,
              color: Color(0xFFFF7D53),
            ),
            const SizedBox(height: 16),
            const Text(
              'Could not reach the backend.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.5,
                color: Color(0xFF6E6A7C),
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
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
      onDismissed: (_) => ref.read(todoListProvider.notifier).delete(todo.id),
      child: GestureDetector(
        onTap: () => _openDetails(context, ref),
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
              GestureDetector(
                onTap: () =>
                    ref.read(todoListProvider.notifier).toggleCompleted(todo),
                child: Padding(
                  padding: const EdgeInsets.all(2),
                  child: Icon(
                    todo.completed
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    color: todo.completed
                        ? const Color(0xFF5F33E1)
                        : const Color(0xFFBDBDBD),
                    size: 24,
                  ),
                ),
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
              IconButton(
                onPressed: () => _showEditDialog(context, ref),
                icon: const Icon(Icons.edit_outlined, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openDetails(BuildContext context, WidgetRef ref) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TaskDetailsPage(
          todo: todo,
          onToggleComplete: () async {
            await ref.read(todoListProvider.notifier).toggleCompleted(todo);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onDelete: () async {
            await ref.read(todoListProvider.notifier).delete(todo.id);
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController(text: todo.title);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
          16,
          0,
          16,
          MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 22),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5DEF8),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Edit Task',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 18),
              TextField(controller: controller, autofocus: true),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () async {
                        final newTitle = controller.text.trim();
                        if (newTitle.isEmpty) {
                          return;
                        }
                        Navigator.pop(ctx);
                        await ref
                            .read(todoListProvider.notifier)
                            .editTitle(todo.id, newTitle);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
