import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:todolist_ai_native/src/pages/today_tasks_page.dart';

void main() {
  group('TodayTasksPage filter chips', () {
    testWidgets('shows all tasks when All is selected', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TodayTasksPage())),
      );
      await tester.pumpAndSettle();
      // All filter selected by default — all four tasks visible
      expect(find.text('Market Research'), findsOneWidget);
      expect(find.text('Competitive Analysis'), findsOneWidget);
      expect(find.text('Create Low-fidelity Wireframe'), findsOneWidget);
    });

    testWidgets('tapping To do shows only to-do tasks', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TodayTasksPage())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('filter-todo')));
      await tester.pumpAndSettle();

      // To-do tasks should be visible
      expect(find.text('Create Low-fidelity Wireframe'), findsOneWidget);
      // Done task should be hidden
      expect(find.text('Market Research'), findsNothing);
    });

    testWidgets('tapping In Progress shows only in-progress tasks', (
      tester,
    ) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TodayTasksPage())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('filter-in-progress')));
      await tester.pumpAndSettle();

      expect(find.text('Competitive Analysis'), findsOneWidget);
      expect(find.text('Market Research'), findsNothing);
    });

    testWidgets('tapping Completed shows only completed tasks', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(child: MaterialApp(home: TodayTasksPage())),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('filter-completed')));
      await tester.pumpAndSettle();

      expect(find.text('Market Research'), findsOneWidget);
      expect(find.text('Competitive Analysis'), findsNothing);
    });
  });
}
