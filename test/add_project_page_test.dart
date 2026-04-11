import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/pages/add_project_page.dart';

void main() {
  Widget wrap(Widget child) => ProviderScope(child: MaterialApp(home: child));

  group('AddProjectPage', () {
    testWidgets('shows form with project name field', (tester) async {
      await tester.pumpWidget(wrap(const AddProjectPage()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('project-name-field')), findsOneWidget);
    });

    testWidgets('shows Add button', (tester) async {
      await tester.pumpWidget(wrap(const AddProjectPage()));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('project-submit-button')), findsOneWidget);
    });

    testWidgets('Add button is disabled when name is empty', (tester) async {
      await tester.pumpWidget(wrap(const AddProjectPage()));
      await tester.pumpAndSettle();
      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('project-submit-button')),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets('Add button enables after typing a name', (tester) async {
      await tester.pumpWidget(wrap(const AddProjectPage()));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('project-name-field')),
        'New Project',
      );
      await tester.pump();

      final btn = tester.widget<FilledButton>(
        find.byKey(const Key('project-submit-button')),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('tapping Add with valid name calls onAdd callback', (
      tester,
    ) async {
      String? added;
      await tester.pumpWidget(
        wrap(AddProjectPage(onAdd: (name) => added = name)),
      );
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('project-name-field')),
        'Work Project',
      );
      await tester.pump();
      await tester.tap(find.byKey(const Key('project-submit-button')));
      await tester.pumpAndSettle();

      expect(added, 'Work Project');
    });
  });
}
