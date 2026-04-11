import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/api/todo_model.dart';
import 'package:todolist_ai_native/src/pages/task_details_page.dart';

void main() {
  final sampleTodo = const TodoModel(
    id: '1',
    title: 'Market Research',
    description: 'Research competitors and market trends',
    completed: false,
  );

  Widget _wrap(Widget child) => ProviderScope(child: MaterialApp(home: child));

  group('TaskDetailsPage', () {
    testWidgets('shows todo title', (tester) async {
      await tester.pumpWidget(_wrap(TaskDetailsPage(todo: sampleTodo)));
      await tester.pumpAndSettle();
      expect(find.text('Market Research'), findsOneWidget);
    });

    testWidgets('shows description when present', (tester) async {
      await tester.pumpWidget(_wrap(TaskDetailsPage(todo: sampleTodo)));
      await tester.pumpAndSettle();
      expect(find.text('Research competitors and market trends'), findsOneWidget);
    });

    testWidgets('shows incomplete status for incomplete todo', (tester) async {
      await tester.pumpWidget(_wrap(TaskDetailsPage(todo: sampleTodo)));
      await tester.pumpAndSettle();
      expect(find.text('To-do'), findsOneWidget);
    });

    testWidgets('shows completed status for completed todo', (tester) async {
      await tester.pumpWidget(_wrap(
        TaskDetailsPage(todo: sampleTodo.copyWith(completed: true)),
      ));
      await tester.pumpAndSettle();
      expect(find.text('Done'), findsOneWidget);
    });

    testWidgets('has a toggle complete button', (tester) async {
      await tester.pumpWidget(_wrap(TaskDetailsPage(todo: sampleTodo)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('toggle-complete-btn')), findsOneWidget);
    });

    testWidgets('has a delete button', (tester) async {
      await tester.pumpWidget(_wrap(TaskDetailsPage(todo: sampleTodo)));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('delete-todo-btn')), findsOneWidget);
    });
  });
}
