import 'dart:async';
import 'dart:typed_data';

import 'package:record/record.dart';

import 'recorded_audio_clip.dart';
import 'voice_audio_recorder.dart';

class RecordVoiceAudioRecorder implements VoiceAudioRecorder {
  RecordVoiceAudioRecorder({AudioRecorder? recorder})
    : _recorder = recorder ?? AudioRecorder();

  final AudioRecorder _recorder;
  StreamSubscription<Uint8List>? _subscription;
  BytesBuilder _buffer = BytesBuilder(copy: false);

  @override
  Future<void> start() async {
    if (!await _recorder.hasPermission()) {
      throw StateError('microphone permission denied');
    }

    _buffer = BytesBuilder(copy: false);
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
      ),
    );
    _subscription = stream.listen(_buffer.add);
  }

  @override
  Future<RecordedAudioClip?> stop() async {
    await _subscription?.cancel();
    _subscription = null;
    await _recorder.stop();

    final bytes = _buffer.takeBytes();
    if (bytes.isEmpty) {
      return null;
    }

    return RecordedAudioClip(
      bytes: bytes,
      fileName: 'voice-input.pcm',
      format: 'pcm_s16le',
      sampleRateHz: 16000,
    );
  }
}
