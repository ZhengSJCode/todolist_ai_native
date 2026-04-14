import '../audio/recorded_audio_clip.dart';

abstract interface class VoiceTranscriptionClient {
  Future<String> transcribe(RecordedAudioClip clip);
}
