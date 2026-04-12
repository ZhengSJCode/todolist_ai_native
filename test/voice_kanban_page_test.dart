import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/todo_api_client.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_model.dart';
import 'package:todolist_ai_native/src/pages/voice_kanban_page.dart';
import 'package:todolist_ai_native/src/provider/voice_kanban_provider.dart';

import 'voice_kanban_provider_test.mocks.dart';

void main() {
  group('Voice Kanban Page Widgets', () {
    late MockVoiceKanbanApiClient mockApiClient;

    setUp(() {
      mockApiClient = MockVoiceKanbanApiClient();
    });

    Widget createWidget() {
      return ProviderScope(
        overrides: [
          voiceKanbanApiClientProvider.overrideWithValue(mockApiClient),
        ],
        child: const MaterialApp(
          home: VoiceKanbanPage(),
        ),
      );
    }

    testWidgets('W1: Kanban Page lists items and shows filters', (tester) async {
      when(mockApiClient.listItems()).thenAnswer((_) async => [
            ParsedItem(
                id: '1',
                rawEntryId: 'e1',
                type: ParsedItemType.task,
                content: 'Task content here',
                createdAt: DateTime.now())
          ]);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      expect(find.text('Task content here'), findsOneWidget);
      expect(find.byKey(const Key('filter_all')), findsOneWidget);
      expect(find.byKey(const Key('filter_task')), findsOneWidget);
    });

    testWidgets('W2: Input page, mock parse, see preview', (tester) async {
      when(mockApiClient.listItems()).thenAnswer((_) async => []);
      when(mockApiClient.parse('买鸡蛋')).thenAnswer((_) async => [
            const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')
          ]);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('kanban_input_field')), '买鸡蛋');
      await tester.tap(find.byKey(const Key('btn_parse')));
      await tester.pump(); // Start loading
      await tester.pumpAndSettle(); // Finish loading

      expect(find.text('预览解析结果:'), findsOneWidget);
      expect(find.textContaining('买鸡蛋'), findsWidgets);
    });

    testWidgets('W3: Error presentation', (tester) async {
      when(mockApiClient.listItems()).thenAnswer((_) async => []);

      await tester.pumpWidget(createWidget());
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(VoiceKanbanPage)));
      container.read(voiceKanbanDraftsProvider.notifier).state = const AsyncValue.error('ApiException(400): Bad request', StackTrace.empty);

      await tester.pump();

      expect(find.textContaining('Bad request'), findsOneWidget);
    });
  });
}
