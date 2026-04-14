import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/todo_api_client.dart';
import 'package:todolist_ai_native/src/api/voice_transcription_client.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_model.dart';
import 'package:todolist_ai_native/src/audio/recorded_audio_clip.dart';
import 'package:todolist_ai_native/src/audio/voice_audio_recorder.dart';
import 'package:todolist_ai_native/src/pages/voice_kanban_page.dart';
import 'package:todolist_ai_native/src/provider/voice_kanban_provider.dart';
import 'package:todolist_ai_native/src/provider/voice_kanban_voice_flow_provider.dart';

import 'voice_kanban_provider_test.mocks.dart';

class FakeVoiceAudioRecorder implements VoiceAudioRecorder {
  @override
  Future<void> start() async {}

  @override
  Future<RecordedAudioClip?> stop() async {
    return RecordedAudioClip(
      bytes: Uint8List.fromList([1, 2, 3]),
      fileName: 'voice-input.pcm',
      format: 'pcm_s16le',
      sampleRateHz: 16000,
    );
  }
}

class FakeVoiceTranscriptionClient implements VoiceTranscriptionClient {
  @override
  Future<String> transcribe(RecordedAudioClip clip) async => '买鸡蛋';
}

void main() {
  group('Voice Kanban Page Widgets', () {
    late MockVoiceKanbanApiClient mockApiClient;
    late VoiceAudioRecorder recorder;
    late VoiceTranscriptionClient transcriptionClient;

    setUp(() {
      mockApiClient = MockVoiceKanbanApiClient();
      recorder = FakeVoiceAudioRecorder();
      transcriptionClient = FakeVoiceTranscriptionClient();
    });

    Widget createWidget({
      required MockVoiceKanbanApiClient mockApiClient,
      required VoiceAudioRecorder recorder,
      required VoiceTranscriptionClient transcriptionClient,
    }) {
      return ProviderScope(
        overrides: [
          voiceKanbanApiClientProvider.overrideWithValue(mockApiClient),
          voiceAudioRecorderProvider.overrideWithValue(recorder),
          voiceTranscriptionClientProvider.overrideWithValue(
            transcriptionClient,
          ),
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

      await tester.pumpWidget(
        createWidget(
          mockApiClient: mockApiClient,
          recorder: recorder,
          transcriptionClient: transcriptionClient,
        ),
      );
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

      await tester.pumpWidget(
        createWidget(
          mockApiClient: mockApiClient,
          recorder: recorder,
          transcriptionClient: transcriptionClient,
        ),
      );
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

      await tester.pumpWidget(
        createWidget(
          mockApiClient: mockApiClient,
          recorder: recorder,
          transcriptionClient: transcriptionClient,
        ),
      );
      await tester.pumpAndSettle();

      final container = ProviderScope.containerOf(tester.element(find.byType(VoiceKanbanPage)));
      container.read(voiceKanbanDraftsProvider.notifier).state = const AsyncValue.error('ApiException(400): Bad request', StackTrace.empty);

      await tester.pump();

      expect(find.textContaining('Bad request'), findsOneWidget);
    });

    testWidgets('W4: voice buttons render and show transcript after stop', (
      tester,
    ) async {
      when(mockApiClient.listItems()).thenAnswer((_) async => []);
      when(mockApiClient.parse('买鸡蛋')).thenAnswer((_) async => [
            const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')
          ]);

      await tester.pumpWidget(
        createWidget(
          mockApiClient: mockApiClient,
          recorder: recorder,
          transcriptionClient: transcriptionClient,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('btn_start_recording')), findsOneWidget);
      expect(find.byKey(const Key('btn_stop_recording')), findsOneWidget);

      await tester.tap(find.byKey(const Key('btn_start_recording')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_stop_recording')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('转写文本'), findsOneWidget);
      expect(find.text('买鸡蛋'), findsWidgets);
    });

    testWidgets('W5: save uses sourceType voice when transcript is active', (
      tester,
    ) async {
      when(mockApiClient.listItems()).thenAnswer((_) async => []);
      when(mockApiClient.parse('买鸡蛋')).thenAnswer((_) async => [
            const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')
          ]);
      when(mockApiClient.createEntry('买鸡蛋', sourceType: 'voice')).thenAnswer(
        (_) async => CreateEntryResponse(
          rawEntry: RawEntry(
            id: 'voice-1',
            sourceType: 'voice',
            rawText: '买鸡蛋',
            createdAt: DateTime(2026, 4, 15),
          ),
          items: [
            ParsedItem(
              id: 'item-1',
              rawEntryId: 'voice-1',
              type: ParsedItemType.task,
              content: '买鸡蛋',
              createdAt: DateTime(2026, 4, 15),
            ),
          ],
        ),
      );

      await tester.pumpWidget(
        createWidget(
          mockApiClient: mockApiClient,
          recorder: recorder,
          transcriptionClient: transcriptionClient,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_start_recording')));
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_stop_recording')));
      await tester.pump();
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('btn_save')));
      await tester.pumpAndSettle();

      verify(
        mockApiClient.createEntry('买鸡蛋', sourceType: 'voice'),
      ).called(1);
    });
  });
}
