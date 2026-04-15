import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:record/record.dart';
import 'package:todolist_ai_native/src/audio/record_voice_audio_recorder.dart';

class _FakeAudioRecorder extends AudioRecorder {
  final StreamController<Uint8List> _controller = StreamController<Uint8List>();
  bool _started = false;

  @override
  Future<bool> hasPermission({bool request = true}) async => true;

  @override
  Future<Stream<Uint8List>> startStream(RecordConfig config) async {
    _started = true;
    return _controller.stream;
  }

  @override
  Future<String?> stop() async {
    if (_started) {
      _controller.add(Uint8List.fromList([1, 2, 3, 4]));
      await _controller.close();
      _started = false;
    }

    return null;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const methodChannel = MethodChannel('com.llfbandit.record/messages');

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, (_) async => null);
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(methodChannel, null);
  });

  test(
    'stop collects buffered bytes emitted during recorder shutdown',
    () async {
      final recorder = RecordVoiceAudioRecorder(recorder: _FakeAudioRecorder());

      await recorder.start();
      final clip = await recorder.stop();

      expect(clip, isNotNull);
      expect(clip!.bytes, Uint8List.fromList([1, 2, 3, 4]));
    },
  );
}
