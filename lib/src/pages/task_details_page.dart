import 'package:flutter/material.dart';
import '../api/todo_model.dart';

/// Task details screen — Figma node 101:539.
///
/// Shows todo title, description, completion status.
/// Supports toggle complete and delete via callbacks so the caller can
/// wire up provider or navigation logic.
class TaskDetailsPage extends StatelessWidget {
  const TaskDetailsPage({
    super.key,
    required this.todo,
    this.onToggleComplete,
    this.onDelete,
  });

  final TodoModel todo;
  final VoidCallback? onToggleComplete;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    final statusLabel = todo.completed ? 'Done' : 'To-do';
    final statusColor =
        todo.completed ? const Color(0xFF5F33E1) : const Color(0xFF0087FF);
    final statusBackground =
        todo.completed ? const Color(0xFFEDE8FF) : const Color(0xFFE3F2FF);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F8),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.maybePop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Task Details',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const Key('delete-todo-btn'),
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFFF5252)),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status badge
                    Container(
                      decoration: BoxDecoration(
                        color: statusBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: Text(
                        statusLabel,
                        style: TextStyle(
                          fontSize: 12,
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Title
                    Text(
                      todo.title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF24252C),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Description
                    if (todo.description.isNotEmpty) ...[
                      Text(
                        todo.description,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6E6A7C),
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    const Spacer(),
                    // Toggle complete button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton.icon(
                        key: const Key('toggle-complete-btn'),
                        onPressed: onToggleComplete,
                        icon: Icon(todo.completed
                            ? Icons.refresh_rounded
                            : Icons.check_circle_outline_rounded),
                        label: Text(
                          todo.completed ? 'Mark as To-do' : 'Mark as Done',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF5F33E1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
