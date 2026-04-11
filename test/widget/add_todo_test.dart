import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/api/todo_model.dart';
import 'package:todolist_ai_native/src/widgets/add_todo_dialog.dart';
import 'package:todolist_ai_native/src/provider/todo_provider.dart';

class _MockTodoState extends AutoDisposeAsyncNotifier<List<TodoModel>>
    implements TodoList {
  bool createCalled = false;
  String? createdTitle;
  String? createdDescription;

  @override
  Future<List<TodoModel>> build() async => [];

  @override
  Future<void> create({required String title, String description = ''}) async {
    createCalled = true;
    createdTitle = title;
    createdDescription = description;
  }

  @override
  Future<void> toggleCompleted(TodoModel todo) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> editTitle(String id, String newTitle) async {}
}

void main() {
  group('AddTodoDialog Widget Tests', () {
    testWidgets('shows input fields and buttons', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const AddTodoDialog(),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Add Todo'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2)); // Title and Description
      expect(find.text('Add'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('Add button is disabled when title is empty', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const AddTodoDialog(),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      final addButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Add'),
      );
      expect(addButton.onPressed, isNull);
    });

    testWidgets('calls create and closes dialog when valid data submitted', (
      tester,
    ) async {
      final mockState = _MockTodoState();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [todoListProvider.overrideWith(() => mockState)],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (context) => const AddTodoDialog(),
                  ),
                  child: const Text('Open'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // Enter title
      await tester.enterText(find.byType(TextField).first, 'New Task');
      await tester.pump(); // to trigger setState in TextField onChanged

      // Enter description
      await tester.enterText(find.byType(TextField).last, 'Task Description');
      await tester.pump();

      // Button should be enabled now
      final addButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Add'),
      );
      expect(addButton.onPressed, isNotNull);

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();

      // Check if dialog closed
      expect(find.text('Add Todo'), findsNothing);

      // Verify create was called
      expect(mockState.createCalled, isTrue);
      expect(mockState.createdTitle, 'New Task');
      expect(mockState.createdDescription, 'Task Description');
    });
  });
}
