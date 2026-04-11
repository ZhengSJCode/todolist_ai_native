import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/api/todo_model.dart';
import 'package:todolist_ai_native/src/pages/todo_list_page.dart';
import 'package:todolist_ai_native/src/provider/todo_provider.dart';

class _FakeTodoState extends AutoDisposeAsyncNotifier<List<TodoModel>>
    implements TodoList {
  _FakeTodoState(this.initialState);
  final AsyncValue<List<TodoModel>> initialState;

  @override
  Future<List<TodoModel>> build() async {
    if (initialState.isLoading) {
      return Completer<List<TodoModel>>().future;
    }
    if (initialState.hasError) {
      throw initialState.error!;
    }
    return initialState.value!;
  }

  @override
  Future<void> create({required String title, String description = ''}) async {}

  @override
  Future<void> toggleCompleted(TodoModel todo) async {}

  @override
  Future<void> delete(String id) async {}

  @override
  Future<void> editTitle(String id, String newTitle) async {}
}

ProviderScope _createScope(AsyncValue<List<TodoModel>> state) {
  return ProviderScope(
    overrides: [todoListProvider.overrideWith(() => _FakeTodoState(state))],
    child: const MaterialApp(home: TodoListPage()),
  );
}

void main() {
  group('TodoListPage Widget Tests', () {
    testWidgets('shows loading indicator when state is loading', (
      tester,
    ) async {
      await tester.pumpWidget(_createScope(const AsyncLoading()));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when list is empty', (tester) async {
      await tester.pumpWidget(_createScope(const AsyncData([])));
      await tester.pumpAndSettle();

      expect(find.text('暂无任务，点击 + 新建'), findsOneWidget);
    });

    testWidgets('shows error state when error occurs', (tester) async {
      final error = Exception('Failed to load todos');
      await tester.pumpWidget(
        _createScope(AsyncError(error, StackTrace.empty)),
      );
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Exception: Failed to load todos'),
        findsOneWidget,
      );
    });

    testWidgets('shows todo items when data is loaded', (tester) async {
      final todos = [
        const TodoModel(id: '1', title: 'Task 1', completed: false),
        const TodoModel(id: '2', title: 'Task 2', completed: true),
      ];
      await tester.pumpWidget(_createScope(AsyncData(todos)));
      await tester.pumpAndSettle();

      expect(find.text('Task 1'), findsOneWidget);
      expect(find.text('Task 2'), findsOneWidget);
      expect(find.byType(Checkbox), findsNWidgets(2));
    });
  });
}
