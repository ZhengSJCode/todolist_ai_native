import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/pages/lets_start_page.dart';
import 'package:todolist_ai_native/src/router.dart';

void main() {
  group('AppRouter', () {
    testWidgets('/ redirects to /start', (tester) async {
      final router = buildAppRouter(startAtHome: false);
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LetsStartPage), findsOneWidget);
    });

    testWidgets('navigating to /home shows AppShell with home tab', (
      tester,
    ) async {
      final router = buildAppRouter(startAtHome: true);
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();
      // Home tab should show greeting
      expect(find.text('Hello!'), findsOneWidget);
    });

    testWidgets('tapping Get Started on LetsStartPage navigates to home', (
      tester,
    ) async {
      final router = buildAppRouter(startAtHome: false);
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp.router(routerConfig: router)),
      );
      await tester.pumpAndSettle();
      expect(find.byType(LetsStartPage), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Hello!'), findsOneWidget);
      expect(find.byType(LetsStartPage), findsNothing);
    });
  });
}
