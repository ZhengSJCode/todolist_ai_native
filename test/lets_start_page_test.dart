import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/pages/lets_start_page.dart';

void main() {
  group('LetsStartPage', () {
    testWidgets('shows headline and tagline', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LetsStartPage()),
      );
      expect(find.text("Let's Start!"), findsOneWidget);
      expect(find.textContaining('task'), findsWidgets);
    });

    testWidgets('has a Get Started button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: LetsStartPage()),
      );
      expect(find.text('Get Started'), findsOneWidget);
    });

    testWidgets('Get Started button triggers onStart callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: LetsStartPage(onStart: () => tapped = true),
        ),
      );
      await tester.tap(find.text('Get Started'));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
