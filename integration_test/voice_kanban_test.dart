import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:todolist_ai_native/src/bootstrap.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Voice Kanban integration tests', () {
    testWidgets('opens voice kanban tab and performs basic operations', (
      tester,
    ) async {
      // Start the app
      await tester.pumpWidget(createAppRoot());
      await tester.pumpAndSettle();

      // Tap "Get Started" if this is the first time
      final getStartedButton = find.text('Get Started');
      if (getStartedButton.precache()) {
        await tester.tap(getStartedButton);
        await tester.pumpAndSettle();
      }

      // Find and tap the Voice Kanban tab (3rd tab from the left)
      final voiceKanbanTab = find.byKey(const Key('nav-voice-kanban'));
      expect(voiceKanbanTab, findsOneWidget);
      await tester.tap(voiceKanbanTab);
      await tester.pumpAndSettle();

      // Verify we're on the Voice Kanban page
      expect(find.text('语音记录看板'), findsOneWidget);
      expect(find.text('输入记录'), findsOneWidget);

      // Enter some text
      final inputField = find.byKey(const Key('kanban_input_field'));
      expect(inputField, findsOneWidget);
      await tester.enterText(inputField, '今天体重75.5kg，下班去买5斤鸡胸肉，这周感觉力量训练有进步');
      await tester.pumpAndSettle();

      // Tap the parse button
      final parseButton = find.byKey(const Key('btn_parse'));
      expect(parseButton, findsOneWidget);
      await tester.tap(parseButton);
      await tester.pumpAndSettle();

      // Verify parsing results are displayed
      expect(find.text('预览解析结果:'), findsOneWidget);

      // Tap the save button
      final saveButton = find.byKey(const Key('btn_save'));
      expect(saveButton, findsOneWidget);
      await tester.tap(saveButton);
      await tester.pumpAndSettle();

      // Test filtering - tap on "Task" filter
      final taskFilter = find.byKey(const Key('filter_task'));
      expect(taskFilter, findsOneWidget);
      await tester.tap(taskFilter);
      await tester.pumpAndSettle();

      // Test filtering - tap on "全部" filter to show all items
      final allFilter = find.byKey(const Key('filter_all'));
      expect(allFilter, findsOneWidget);
      await tester.tap(allFilter);
      await tester.pumpAndSettle();
    });
  });
}