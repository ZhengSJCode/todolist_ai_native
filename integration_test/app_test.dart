import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todolist_ai_native/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Todo app integration test', () {
    testWidgets('launches onboarding and navigates into the home shell', (
      tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      expect(find.text("Let's Start!"), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.text('Hello!'), findsOneWidget);
      expect(find.text('Livia Vaccaro'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.byKey(const Key('nav-home')), findsOneWidget);
      expect(find.byKey(const Key('nav-documents')), findsOneWidget);
    });
  });
}
