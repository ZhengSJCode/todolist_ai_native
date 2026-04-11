import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';
import 'package:todolist_ai_native/src/bootstrap.dart';

void main() {
  patrolTest('creates a project, creates a task, and backgrounds the app', (
    $,
  ) async {
    final runId = DateTime.now().millisecondsSinceEpoch;
    final projectName = 'Patrol Launch Plan $runId';
    final taskName = 'Prepare Patrol launch copy $runId';

    await $.pumpWidgetAndSettle(createAppRoot());

    await $('Get Started').tap();
    await $.pumpAndSettle();

    await $(const Key('nav-documents')).tap();
    await $.pumpAndSettle();
    expect($('Projects'), findsOneWidget);

    await $('Add Project').tap();
    await $.pumpAndSettle();
    await $(const Key('project-name-field')).enterText(projectName);
    await $.pumpAndSettle();
    await _dismissKeyboard($);

    final projectSubmitButton = $.tester.widget<FilledButton>(
      find.byKey(const Key('project-submit-button')),
    );
    expect(projectSubmitButton.onPressed, isNotNull);

    await $(const Key('project-submit-button')).scrollTo();
    await $(const Key('project-submit-button')).tap();
    await $.pumpAndSettle();

    final projectsScrollable = find.descendant(
      of: find.byKey(const Key('projects-list-view')),
      matching: find.byType(Scrollable),
    );
    final createdProject = find.descendant(
      of: find.byKey(const Key('projects-list-view')),
      matching: find.text(projectName),
    );
    await $(createdProject).scrollTo(view: projectsScrollable.first);
    expect(createdProject, findsOneWidget);

    await $(const Key('nav-profile')).tap();
    await $.pumpAndSettle();
    expect($('My Tasks'), findsOneWidget);

    await $(const Key('add-task-btn')).tap();
    await $.pumpAndSettle();
    await $(TextField).last.enterText(taskName);
    await $.pumpAndSettle();
    await _dismissKeyboard($);

    final taskSubmitButton = $.tester.widget<FilledButton>(
      find.byKey(const Key('task-composer-submit-button')),
    );
    expect(taskSubmitButton.onPressed, isNotNull);

    await $(const Key('task-composer-submit-button')).scrollTo();
    await $(const Key('task-composer-submit-button')).tap();
    await $.pumpAndSettle();

    final liveTodosScrollable = find.descendant(
      of: find.byKey(const Key('live-todos-list-view')),
      matching: find.byType(Scrollable),
    );
    final createdTask = find.descendant(
      of: find.byKey(const Key('live-todos-list-view')),
      matching: find.text(taskName),
    );
    await $(createdTask).scrollTo(view: liveTodosScrollable.first);
    expect(createdTask, findsOneWidget);

    if (!Platform.isMacOS) {
      // ignore: deprecated_member_use
      await $.native.pressHome();
    }
  });
}

Future<void> _dismissKeyboard(PatrolIntegrationTester $) async {
  WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
  await $.pumpAndSettle();
}
