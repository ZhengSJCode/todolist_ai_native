import 'recorded_audio_clip.dart';

abstract interface class VoiceAudioRecorder {
  Future<void> start();
  Future<RecordedAudioClip?> stop();
}
