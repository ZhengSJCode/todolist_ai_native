import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/api/todo_model.dart';
import 'package:todolist_ai_native/src/pages/live_todos_page.dart';
import 'package:todolist_ai_native/src/provider/todo_provider.dart';

/// A fake client that operates on an in-memory list — no HTTP involved.
class _FakeTodoState extends AutoDisposeAsyncNotifier<List<TodoModel>>
    implements TodoList {
  @override
  Future<List<TodoModel>> build() async => [];

  @override
  Future<void> create({required String title, String description = ''}) async {
    final next = TodoModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
    );
    state = AsyncData([...state.valueOrNull ?? [], next]);
  }

  @override
  Future<void> toggleCompleted(TodoModel todo) async {
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((t) => t.id == todo.id ? t.copyWith(completed: !t.completed) : t)
          .toList(),
    );
  }

  @override
  Future<void> delete(String id) async {
    state = AsyncData(
      (state.valueOrNull ?? []).where((t) => t.id != id).toList(),
    );
  }

  @override
  Future<void> editTitle(String id, String newTitle) async {
    state = AsyncData(
      (state.valueOrNull ?? [])
          .map((t) => t.id == id ? t.copyWith(title: newTitle) : t)
          .toList(),
    );
  }
}

ProviderScope _scope() => ProviderScope(
      overrides: [
        todoListProvider.overrideWith(_FakeTodoState.new),
      ],
      child: const MaterialApp(home: LiveTodosPage()),
    );

void main() {
  group('LiveTodosPage — full UI interaction', () {
    testWidgets('shows empty state initially', (tester) async {
      await tester.pumpWidget(_scope());
      await tester.pumpAndSettle();
      expect(find.text('No tasks yet. Tap + to add one.'), findsOneWidget);
    });

    testWidgets('creates a task via dialog', (tester) async {
      await tester.pumpWidget(_scope());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-task-btn')));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Buy groceries');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Buy groceries'), findsOneWidget);
      expect(find.text('No tasks yet. Tap + to add one.'), findsNothing);
    });

    testWidgets('tapping task toggles completed state', (tester) async {
      await tester.pumpWidget(_scope());
      await tester.pumpAndSettle();

      // Create first
      await tester.tap(find.byKey(const Key('add-task-btn')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Learn Flutter');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Not yet completed — unchecked icon
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsOneWidget);

      // Tap to toggle
      await tester.tap(find.text('Learn Flutter'));
      await tester.pumpAndSettle();

      // Should be completed icon
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('long pressing task opens edit dialog', (tester) async {
      await tester.pumpWidget(_scope());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-task-btn')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Old title');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      await tester.longPress(find.text('Old title'));
      await tester.pumpAndSettle();

      expect(find.text('Edit Task'), findsOneWidget);

      // Clear and type new title
      await tester.tap(find.byType(TextField).last);
      await tester.pump();
      await tester.enterText(find.byType(TextField).last, 'New title');
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(find.text('New title'), findsOneWidget);
      expect(find.text('Old title'), findsNothing);
    });

    testWidgets('dismissing task removes it from list', (tester) async {
      await tester.pumpWidget(_scope());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('add-task-btn')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Delete me');
      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      expect(find.text('Delete me'), findsOneWidget);

      await tester.drag(
        find.text('Delete me'),
        const Offset(-500, 0),
      );
      await tester.pumpAndSettle();

      expect(find.text('Delete me'), findsNothing);
      expect(find.text('No tasks yet. Tap + to add one.'), findsOneWidget);
    });
  });
}
