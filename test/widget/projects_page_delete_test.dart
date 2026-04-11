import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/pages/projects_page.dart';

void main() {
  group('ProjectsPage Widget Tests', () {
    testWidgets('display projects from provider', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: ProjectsPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show all 4 default projects - check at least first two
      expect(find.text('Grocery shopping app design'), findsOneWidget);
      expect(find.text('Uber Eats redesign challange'), findsOneWidget);
    });

    testWidgets('swipe to delete removes project from UI', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: ProjectsPage()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Find the first project tile by its text content
      final firstProject = find.text('Grocery shopping app design');
      expect(firstProject, findsOneWidget);

      // Find the Dismissible containing this project
      final dismissible = find.ancestor(
        of: firstProject,
        matching: find.byType(Dismissible),
      );
      expect(dismissible, findsOneWidget);

      // Swipe to dismiss (left swipe)
      await tester.drag(dismissible.first, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify project is removed from UI
      expect(find.text('Grocery shopping app design'), findsNothing);
    });
  });
}
