import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:todolist_ai_native/src/api/http_voice_transcription_client.dart';
import 'package:todolist_ai_native/src/audio/recorded_audio_clip.dart';

import 'http_voice_transcription_client_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('HttpVoiceTranscriptionClient', () {
    late HttpVoiceTranscriptionClient client;
    late MockClient mockHttpClient;
    const baseUrl = 'http://test';

    setUp(() {
      mockHttpClient = MockClient();
      client = HttpVoiceTranscriptionClient(
        httpClient: mockHttpClient,
        baseUrl: baseUrl,
      );
    });

    test(
      'POSTs recorded clip to /voice/transcribe and returns transcript',
      () async {
        const expectedHeaders = {
          'content-type': 'application/octet-stream',
          'x-audio-format': 'pcm_s16le',
          'x-sample-rate': '16000',
          'x-file-name': 'voice-input.pcm',
        };
        final clip = RecordedAudioClip(
          bytes: Uint8List.fromList([1, 2, 3]),
          fileName: 'voice-input.pcm',
          format: 'pcm_s16le',
          sampleRateHz: 16000,
        );

        when(
          mockHttpClient.post(
            Uri.parse('$baseUrl/voice/transcribe'),
            headers: expectedHeaders,
            body: Uint8List.fromList([1, 2, 3]),
          ),
        ).thenAnswer(
          (_) async => http.Response.bytes(
            utf8.encode(jsonEncode({'transcript': '买鸡蛋'})),
            200,
            headers: {'content-type': 'application/json; charset=utf-8'},
          ),
        );

        final transcript = await client.transcribe(clip);

        expect(transcript, '买鸡蛋');
        verify(
          mockHttpClient.post(
            Uri.parse('$baseUrl/voice/transcribe'),
            headers: expectedHeaders,
            body: clip.bytes,
          ),
        ).called(1);
      },
    );
  });
}
