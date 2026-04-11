import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todolist_ai_native/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Todo app creation flows', () {
    testWidgets('adds a project and a task through the real app UI', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('nav-documents')));
      await tester.pumpAndSettle();

      expect(find.text('Projects'), findsOneWidget);
      await tester.tap(find.text('Add Project'));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('project-name-field')),
        'Codex Launch Plan',
      );
      await tester.pumpAndSettle();
      await _dismissKeyboard(tester);
      await tester.ensureVisible(
        find.byKey(const Key('project-submit-button')),
      );

      final projectSubmitButton = tester.widget<FilledButton>(
        find.byKey(const Key('project-submit-button')),
      );
      expect(projectSubmitButton.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('project-submit-button')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Codex Launch Plan'),
        240,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Codex Launch Plan'), findsOneWidget);

      await tester.tap(find.byKey(const Key('nav-profile')));
      await tester.pumpAndSettle();

      expect(find.text('My Tasks'), findsOneWidget);
      await tester.tap(find.byKey(const Key('add-task-btn')));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).last,
        'Prepare launch copy',
      );
      await tester.pumpAndSettle();
      await _dismissKeyboard(tester);
      await tester.ensureVisible(
        find.byKey(const Key('task-composer-submit-button')),
      );

      final taskSubmitButton = tester.widget<FilledButton>(
        find.byKey(const Key('task-composer-submit-button')),
      );
      expect(taskSubmitButton.onPressed, isNotNull);

      await tester.tap(find.byKey(const Key('task-composer-submit-button')));
      await tester.pumpAndSettle();

      await tester.scrollUntilVisible(
        find.text('Prepare launch copy'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text('Prepare launch copy'), findsOneWidget);
    });
  });
}

Future<void> _dismissKeyboard(WidgetTester tester) async {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
}
