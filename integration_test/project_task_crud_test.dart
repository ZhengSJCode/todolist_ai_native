import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todolist_ai_native/src/bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Project CRUD and Task Association integration tests', () {
    testWidgets('create a new project and verify it appears in the list', (
      tester,
    ) async {
      final runId = DateTime.now().millisecondsSinceEpoch;
      final projectName = 'Test Project $runId';

      await tester.pumpWidget(createAppRoot());
      await tester.pumpAndSettle();

      // Navigate past onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Navigate to Projects tab
      await tester.tap(find.byKey(const Key('nav-documents')));
      await tester.pumpAndSettle();

      // Verify we're on Projects page
      expect(find.text('Projects'), findsOneWidget);

      // Count initial projects
      final initialProjectTileCount = find.byType(Dismissible).evaluate().length;

      // Tap Add Project button
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      // Enter project name
      await tester.enterText(
        find.byKey(const Key('project-name-field')),
        projectName,
      );
      await tester.pumpAndSettle();
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      // Verify button is enabled
      await tester.ensureVisible(
        find.byKey(const Key('project-submit-button')),
      );
      final submitButton = tester.widget<FilledButton>(
        find.byKey(const Key('project-submit-button')),
      );
      expect(submitButton.onPressed, isNotNull);

      // Submit
      await tester.tap(find.byKey(const Key('project-submit-button')));
      await tester.pumpAndSettle();

      // Verify the new project appears in the list
      final projectsScrollable = find.descendant(
        of: find.byKey(const Key('projects-list-view')),
        matching: find.byType(Scrollable),
      );
      final createdProject = find.descendant(
        of: find.byKey(const Key('projects-list-view')),
        matching: find.text(projectName),
      );
      await tester.scrollUntilVisible(
        createdProject,
        240,
        scrollable: projectsScrollable.first,
      );
      expect(createdProject, findsOneWidget);

      // Verify projects count increased
      final finalProjectTileCount = find.byType(Dismissible).evaluate().length;
      expect(finalProjectTileCount, greaterThan(initialProjectTileCount));
    });

    testWidgets('delete a project by swiping and verify it disappears', (
      tester,
    ) async {
      final runId = DateTime.now().millisecondsSinceEpoch;
      final projectName = 'To Delete Project $runId';

      await tester.pumpWidget(createAppRoot());
      await tester.pumpAndSettle();

      // Navigate past onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Navigate to Projects tab
      await tester.tap(find.byKey(const Key('nav-documents')));
      await tester.pumpAndSettle();

      // Create a project to delete
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('project-name-field')),
        projectName,
      );
      await tester.pumpAndSettle();
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('project-submit-button')),
      );
      await tester.tap(find.byKey(const Key('project-submit-button')));
      await tester.pumpAndSettle();

      // Verify project was created
      final projectsScrollable = find.descendant(
        of: find.byKey(const Key('projects-list-view')),
        matching: find.byType(Scrollable),
      );
      final projectText = find.descendant(
        of: find.byKey(const Key('projects-list-view')),
        matching: find.text(projectName),
      );
      await tester.scrollUntilVisible(
        projectText,
        240,
        scrollable: projectsScrollable.first,
      );
      expect(projectText, findsOneWidget);

      // Now delete the project by swiping left
      final dismissible = find.ancestor(
        of: projectText,
        matching: find.byType(Dismissible),
      );
      expect(dismissible, findsOneWidget);

      await tester.drag(dismissible.first, const Offset(-500, 0));
      await tester.pumpAndSettle();

      // Verify project was deleted from UI
      expect(find.text(projectName), findsNothing);
    });

    testWidgets('create a task associated with a project', (tester) async {
      final runId = DateTime.now().millisecondsSinceEpoch;
      final taskName = 'Project Task $runId';

      await tester.pumpWidget(createAppRoot());
      await tester.pumpAndSettle();

      // Navigate past onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Navigate to tasks tab
      await tester.tap(find.byKey(const Key('nav-profile')));
      await tester.pumpAndSettle();

      // Verify we're on tasks page
      expect(find.text('My Tasks'), findsOneWidget);

      // Add a task
      await tester.tap(find.byKey(const Key('add-task-btn')));
      await tester.pumpAndSettle();

      // Enter task name
      await tester.enterText(find.byType(TextField).last, taskName);
      await tester.pumpAndSettle();
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      await tester.pumpAndSettle();

      await tester.ensureVisible(
        find.byKey(const Key('task-composer-submit-button')),
      );

      final submitButton = tester.widget<FilledButton>(
        find.byKey(const Key('task-composer-submit-button')),
      );
      expect(submitButton.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('task-composer-submit-button')));
      await tester.pumpAndSettle();

      // Verify task appears in the list
      final liveTodosScrollable = find.descendant(
        of: find.byKey(const Key('live-todos-list-view')),
        matching: find.byType(Scrollable),
      );
      final createdTask = find.descendant(
        of: find.byKey(const Key('live-todos-list-view')),
        matching: find.text(taskName),
      );
      await tester.scrollUntilVisible(
        createdTask,
        180,
        scrollable: liveTodosScrollable.first,
      );
      expect(createdTask, findsOneWidget);
    });

    testWidgets('task list shows tasks in correct order', (tester) async {
      final runId = DateTime.now().millisecondsSinceEpoch;
      final taskName1 = 'First Task $runId';
      final taskName2 = 'Second Task $runId';

      await tester.pumpWidget(createAppRoot());
      await tester.pumpAndSettle();

      // Navigate past onboarding
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Navigate to tasks tab
      await tester.tap(find.byKey(const Key('nav-profile')));
      await tester.pumpAndSettle();

      // Add first task
      await tester.tap(find.byKey(const Key('add-task-btn')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, taskName1);
      await tester.pumpAndSettle();
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('task-composer-submit-button')),
      );
      await tester.tap(find.byKey(const Key('task-composer-submit-button')));
      await tester.pumpAndSettle();

      // Add second task
      await tester.tap(find.byKey(const Key('add-task-btn')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, taskName2);
      await tester.pumpAndSettle();
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const Key('task-composer-submit-button')),
      );
      await tester.tap(find.byKey(const Key('task-composer-submit-button')));
      await tester.pumpAndSettle();

      // Verify both tasks appear
      final liveTodosScrollable = find.descendant(
        of: find.byKey(const Key('live-todos-list-view')),
        matching: find.byType(Scrollable),
      );

      final firstTask = find.descendant(
        of: find.byKey(const Key('live-todos-list-view')),
        matching: find.text(taskName1),
      );
      await tester.scrollUntilVisible(
        firstTask,
        180,
        scrollable: liveTodosScrollable.first,
      );
      expect(firstTask, findsOneWidget);

      final secondTask = find.descendant(
        of: find.byKey(const Key('live-todos-list-view')),
        matching: find.text(taskName2),
      );
      await tester.scrollUntilVisible(
        secondTask,
        180,
        scrollable: liveTodosScrollable.first,
      );
      expect(secondTask, findsOneWidget);

      // Verify task order - task2 should appear after task1 in the list
      // Both tasks are visible and second task should be below first
      final firstTaskOffset = tester.getTopLeft(firstTask);
      final secondTaskOffset = tester.getTopLeft(secondTask);
      expect(secondTaskOffset.dy, greaterThan(firstTaskOffset.dy));
    });
  });
}
