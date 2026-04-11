import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todolist_ai_native/src/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<void> pumpAppShell(WidgetTester tester) async {
    tester.view
      ..physicalSize = const Size(375, 812)
      ..devicePixelRatio = 1;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();
  }

  testWidgets('home shell matches golden', (tester) async {
    await pumpAppShell(tester);

    expect(find.text('Livia Vaccaro'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/home_shell.png'),
    );
  });

  testWidgets('today tasks shell matches golden', (tester) async {
    await pumpAppShell(tester);

    await tester.tap(find.byKey(const Key('nav-calendar')));
    await tester.pumpAndSettle();

    expect(find.text('Today’s Tasks'), findsOneWidget);

    await expectLater(
      find.byType(MaterialApp),
      matchesGoldenFile('goldens/today_tasks_shell.png'),
    );
  });
}
