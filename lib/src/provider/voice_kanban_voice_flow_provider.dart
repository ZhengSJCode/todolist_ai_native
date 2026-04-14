import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../api/http_voice_transcription_client.dart';
import '../api/voice_transcription_client.dart';
import '../audio/record_voice_audio_recorder.dart';
import '../audio/voice_audio_recorder.dart';
import 'voice_kanban_provider.dart';

part 'voice_kanban_voice_flow_provider.g.dart';

class VoiceCaptureState {
  const VoiceCaptureState({
    this.isRecording = false,
    this.isTranscribing = false,
    this.transcript,
    this.errorMessage,
  });

  final bool isRecording;
  final bool isTranscribing;
  final String? transcript;
  final String? errorMessage;

  VoiceCaptureState copyWith({
    bool? isRecording,
    bool? isTranscribing,
    String? transcript,
    String? errorMessage,
    bool clearTranscript = false,
    bool clearError = false,
  }) {
    return VoiceCaptureState(
      isRecording: isRecording ?? this.isRecording,
      isTranscribing: isTranscribing ?? this.isTranscribing,
      transcript: clearTranscript ? null : (transcript ?? this.transcript),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

@riverpod
VoiceAudioRecorder voiceAudioRecorder(VoiceAudioRecorderRef ref) {
  return RecordVoiceAudioRecorder();
}

@riverpod
VoiceTranscriptionClient voiceTranscriptionClient(
  VoiceTranscriptionClientRef ref,
) {
  return HttpVoiceTranscriptionClient();
}

@riverpod
class VoiceKanbanVoiceFlow extends _$VoiceKanbanVoiceFlow {
  @override
  VoiceCaptureState build() => const VoiceCaptureState();

  Future<void> startRecording() async {
    state = state.copyWith(clearError: true, clearTranscript: true);
    try {
      await ref.read(voiceAudioRecorderProvider).start();
      state = state.copyWith(isRecording: true);
    } catch (_) {
      ref.read(voiceKanbanDraftsProvider.notifier).clear();
      state = state.copyWith(
        isRecording: false,
        isTranscribing: false,
        errorMessage: '录音失败，请检查麦克风权限',
        clearTranscript: true,
      );
    }
  }

  Future<void> stopRecordingAndParse() async {
    state = state.copyWith(
      isRecording: false,
      isTranscribing: true,
      clearError: true,
    );

    try {
      final clip = await ref.read(voiceAudioRecorderProvider).stop();
      if (clip == null || clip.bytes.isEmpty) {
        throw StateError('empty clip');
      }

      final transcript = await ref
          .read(voiceTranscriptionClientProvider)
          .transcribe(clip);
      await ref.read(voiceKanbanDraftsProvider.notifier).parse(transcript);

      state = state.copyWith(
        isRecording: false,
        isTranscribing: false,
        transcript: transcript,
      );
    } catch (_) {
      ref.read(voiceKanbanDraftsProvider.notifier).clear();
      state = state.copyWith(
        isRecording: false,
        isTranscribing: false,
        errorMessage: '语音转写失败，请重试',
        clearTranscript: true,
      );
    }
  }

  void clearVoiceResult() {
    ref.read(voiceKanbanDraftsProvider.notifier).clear();
    state = const VoiceCaptureState();
  }

  Future<void> saveVoiceDraft() async {
    final transcript = state.transcript?.trim() ?? '';
    if (transcript.isEmpty) {
      return;
    }

    await ref
        .read(voiceKanbanItemsProvider.notifier)
        .createEntry(transcript, sourceType: 'voice');
    clearVoiceResult();
  }
}
