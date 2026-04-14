import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:todolist_server/doubao_voice_transcriber.dart';
import 'package:todolist_server/voice_transcriber.dart';

void main() {
  test('sends the official Doubao ASR multipart request shape', () async {
    final mockClient = MockClient((request) async {
      return http.Response.bytes(
        utf8.encode('{"text": "买鸡蛋"}'),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final inspectingClient = _InspectingClient(
      mockClient,
      onSend: (request) {
        expect(request.method, 'POST');
        expect(
          request.url.toString(),
          'https://doubao.example/v1/audio/transcriptions',
        );
        expect(request.headers['authorization'], 'Bearer test-key');
        expect(request, isA<http.MultipartRequest>());

        final multipart = request as http.MultipartRequest;
        expect(multipart.fields['model'], 'doubao-asr');
        expect(multipart.fields['response_format'], 'json');
        expect(multipart.files, hasLength(1));
        expect(multipart.files.single.field, 'file');
        expect(multipart.files.single.filename, 'voice-input.pcm');
      },
    );

    final transcriber = DoubaoVoiceTranscriber(
      httpClient: inspectingClient,
      baseUrl: 'https://doubao.example/v1',
      apiKey: 'test-key',
      model: 'doubao-asr',
    );

    final transcript = await transcriber.transcribe(
      const VoiceAudioPayload(
        bytes: [1, 2, 3],
        fileName: 'voice-input.pcm',
        mimeType: 'application/octet-stream',
        format: 'pcm_s16le',
        sampleRateHz: 16000,
      ),
    );

    expect(transcript, '买鸡蛋');
  });
}

class _InspectingClient extends http.BaseClient {
  _InspectingClient(this._inner, {required this.onSend});

  final http.Client _inner;
  final void Function(http.BaseRequest request) onSend;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    onSend(request);
    return _inner.send(request);
  }
}
