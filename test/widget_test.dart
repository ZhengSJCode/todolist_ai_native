import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todolist_ai_native/main.dart';

void main() {
  testWidgets('app opens on the home screen', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello!'), findsOneWidget);
    expect(find.text('Livia Vaccaro'), findsOneWidget);
    expect(find.text('In Progress'), findsWidgets);
    // await tester.scrollUntilVisible(find.text('Task Groups'), 200);
    // expect(find.text('Task Groups'), findsOneWidget);
  });

  testWidgets('bottom navigation switches between home and today tasks', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Today’s Tasks'), findsNothing);

    await tester.tap(find.byKey(const Key('nav-calendar')));
    await tester.pumpAndSettle();

    expect(find.text('Today’s Tasks'), findsOneWidget);
    expect(find.text('Market Research'), findsOneWidget);

    await tester.tap(find.byKey(const Key('nav-home')));
    await tester.pumpAndSettle();

    expect(find.text('Today’s Tasks'), findsNothing);
    expect(find.text('Livia Vaccaro'), findsOneWidget);
  });

  testWidgets('today tasks screen shows date chips and representative tasks', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.byKey(const Key('nav-calendar')));
    await tester.pumpAndSettle();

    expect(find.text('25'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('To do'), findsOneWidget);
    expect(find.text('In Progress'), findsWidgets);
    expect(find.text('Completed'), findsOneWidget);
    expect(find.text('Competitive Analysis'), findsOneWidget);
    expect(find.text('Create Low-fidelity Wireframe'), findsOneWidget);
  });
}
