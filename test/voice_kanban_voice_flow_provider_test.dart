import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/voice_transcription_client.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_api_client.dart';
import 'package:todolist_ai_native/src/api/voice_kanban_model.dart';
import 'package:todolist_ai_native/src/audio/recorded_audio_clip.dart';
import 'package:todolist_ai_native/src/audio/voice_audio_recorder.dart';
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
  group('VoiceKanbanVoiceFlow', () {
    late MockVoiceKanbanApiClient mockApiClient;
    late ProviderContainer container;

    setUp(() {
      mockApiClient = MockVoiceKanbanApiClient();
      container = ProviderContainer(
        overrides: [
          voiceAudioRecorderProvider.overrideWithValue(FakeVoiceAudioRecorder()),
          voiceTranscriptionClientProvider.overrideWithValue(
            FakeVoiceTranscriptionClient(),
          ),
          voiceKanbanApiClientProvider.overrideWithValue(mockApiClient),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('VF1: stopRecordingAndParse stores transcript and parsed drafts', () async {
      when(mockApiClient.parse('买鸡蛋')).thenAnswer(
        (_) async => [const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')],
      );

      await container.read(voiceKanbanVoiceFlowProvider.notifier).startRecording();
      expect(container.read(voiceKanbanVoiceFlowProvider).isRecording, isTrue);

      await container
          .read(voiceKanbanVoiceFlowProvider.notifier)
          .stopRecordingAndParse();

      final captureState = container.read(voiceKanbanVoiceFlowProvider);
      final draftsState = container.read(voiceKanbanDraftsProvider);

      expect(captureState.transcript, '买鸡蛋');
      expect(captureState.isRecording, isFalse);
      expect(captureState.isTranscribing, isFalse);
      expect(captureState.errorMessage, isNull);
      expect(draftsState.requireValue, hasLength(1));
      verify(mockApiClient.parse('买鸡蛋')).called(1);
    });

    test('VF1b: stopRecordingAndParse clears transcript and exposes error on parse failure', () async {
      when(mockApiClient.parse('买鸡蛋')).thenThrow(Exception('parse failed'));

      await container.read(voiceKanbanVoiceFlowProvider.notifier).startRecording();
      await container
          .read(voiceKanbanVoiceFlowProvider.notifier)
          .stopRecordingAndParse();

      final captureState = container.read(voiceKanbanVoiceFlowProvider);
      final draftsState = container.read(voiceKanbanDraftsProvider);

      expect(captureState.isRecording, isFalse);
      expect(captureState.isTranscribing, isFalse);
      expect(captureState.transcript, isNull);
      expect(captureState.errorMessage, '语音转写失败，请重试');
      expect(draftsState.hasError, isFalse);
      expect(draftsState.requireValue, isEmpty);
    });

    test('VF2: saveVoiceDraft persists transcript as sourceType voice', () async {
      when(mockApiClient.parse('买鸡蛋')).thenAnswer(
        (_) async => [const ParsedDraft(type: ParsedItemType.task, content: '买鸡蛋')],
      );
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
      when(mockApiClient.listItems()).thenAnswer((_) async => []);

      await container.read(voiceKanbanVoiceFlowProvider.notifier).startRecording();
      await container
          .read(voiceKanbanVoiceFlowProvider.notifier)
          .stopRecordingAndParse();
      await container.read(voiceKanbanVoiceFlowProvider.notifier).saveVoiceDraft();

      verify(mockApiClient.createEntry('买鸡蛋', sourceType: 'voice')).called(1);
      expect(container.read(voiceKanbanVoiceFlowProvider).transcript, isNull);
    });
  });
}
