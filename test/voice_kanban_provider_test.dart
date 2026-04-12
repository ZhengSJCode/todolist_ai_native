import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_api_client.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_model.dart';
import 'package:todolist_ai_native/src/provider/voice_kanban_provider.dart';

@GenerateNiceMocks([MockSpec<VoiceKanbanApiClient>()])
import 'voice_kanban_provider_test.mocks.dart';

void main() {
  group('Voice Kanban Providers', () {
    late MockVoiceKanbanApiClient mockApiClient;
    late ProviderContainer container;

    setUp(() {
      mockApiClient = MockVoiceKanbanApiClient();
      container = ProviderContainer(
        overrides: [
          voiceKanbanApiClientProvider.overrideWithValue(mockApiClient),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('T1: VoiceKanbanDrafts initial state is empty list', () {
      final state = container.read(voiceKanbanDraftsProvider);
      expect(state.value, isEmpty);
      expect(state.isLoading, isFalse);
      expect(state.hasError, isFalse);
    });

    test('T2: loadItems (build) success loads fake data', () async {
      when(mockApiClient.listItems()).thenAnswer((_) async => [
            ParsedItem(
                id: '1',
                rawEntryId: 'e1',
                type: ParsedItemType.task,
                content: 'Test task',
                createdAt: DateTime.now())
          ]);

      final future = container.read(voiceKanbanItemsProvider.future);
      final items = await future;
      expect(items.length, 1);
      expect(items.first.content, 'Test task');
    });

    test('T3: fetchItems updates state and supports filtering', () async {
      when(mockApiClient.listItems(type: ParsedItemType.metric)).thenAnswer((_) async => []);

      await container.read(voiceKanbanItemsProvider.notifier).fetchItems(type: ParsedItemType.metric);

      verify(mockApiClient.listItems(type: ParsedItemType.metric)).called(1);

      final state = container.read(voiceKanbanItemsProvider);
      expect(state.value, isEmpty);
    });

    test('T4: parse then createEntry adds to list', () async {
      when(mockApiClient.parse('买菜')).thenAnswer((_) async => [
            const ParsedDraft(type: ParsedItemType.task, content: '买菜')
          ]);

      await container.read(voiceKanbanDraftsProvider.notifier).parse('买菜');

      final drafts = container.read(voiceKanbanDraftsProvider).value!;
      expect(drafts.length, 1);

      when(mockApiClient.createEntry('买菜')).thenAnswer((_) async => CreateEntryResponse(
            rawEntry: RawEntry(
                id: '1',
                sourceType: 'text',
                rawText: '买菜',
                createdAt: DateTime.now()),
            items: [
              ParsedItem(
                  id: '1',
                  rawEntryId: '1',
                  type: ParsedItemType.task,
                  content: '买菜',
                  createdAt: DateTime.now())
            ],
          ));

      when(mockApiClient.listItems()).thenAnswer((_) async => [
            ParsedItem(
                id: '1',
                rawEntryId: '1',
                type: ParsedItemType.task,
                content: '买菜',
                createdAt: DateTime.now())
          ]);

      await container.read(voiceKanbanItemsProvider.notifier).createEntry('买菜');

      verify(mockApiClient.createEntry('买菜')).called(1);
      verify(mockApiClient.listItems()).called(2); // once during build, once from fetchItems after create
    });
  });
}
