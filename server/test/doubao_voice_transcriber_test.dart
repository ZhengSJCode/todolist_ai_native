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
      onSend: (request) async {
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
        final file = multipart.files.single;
        expect(file.field, 'file');
        expect(file.filename, 'voice-input.pcm');
        expect(file.contentType?.mimeType, 'application/octet-stream');
        expect(await file.finalize().toBytes(), [1, 2, 3]);

        final clone = http.MultipartRequest(request.method, request.url)
          ..headers.addAll(request.headers)
          ..fields.addAll(request.fields);
        clone.files.add(
          http.MultipartFile.fromBytes(
            file.field,
            [1, 2, 3],
            filename: file.filename,
            contentType: file.contentType,
          ),
        );
        return clone;
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

  test(
    'normalizes transport failures into VoiceTranscriptionException',
    () async {
      final mockClient = MockClient((request) {
        throw const FormatException('network down');
      });

      final transcriber = DoubaoVoiceTranscriber(
        httpClient: mockClient,
        baseUrl: 'https://doubao.example/v1',
        apiKey: 'test-key',
        model: 'doubao-asr',
      );

      expect(
        () => transcriber.transcribe(
          const VoiceAudioPayload(
            bytes: [1, 2, 3],
            fileName: 'voice-input.pcm',
            mimeType: 'application/octet-stream',
            format: 'pcm_s16le',
            sampleRateHz: 16000,
          ),
        ),
        throwsA(isA<VoiceTranscriptionException>()),
      );
    },
  );

  test(
    'normalizes invalid JSON responses into VoiceTranscriptionException',
    () async {
      final mockClient = MockClient((request) async {
        return http.Response.bytes(
          utf8.encode('not json'),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final transcriber = DoubaoVoiceTranscriber(
        httpClient: mockClient,
        baseUrl: 'https://doubao.example/v1',
        apiKey: 'test-key',
        model: 'doubao-asr',
      );

      expect(
        () => transcriber.transcribe(
          const VoiceAudioPayload(
            bytes: [1, 2, 3],
            fileName: 'voice-input.pcm',
            mimeType: 'application/octet-stream',
            format: 'pcm_s16le',
            sampleRateHz: 16000,
          ),
        ),
        throwsA(isA<VoiceTranscriptionException>()),
      );
    },
  );
}

class _InspectingClient extends http.BaseClient {
  _InspectingClient(this._inner, {required this.onSend});

  final http.Client _inner;
  final Future<http.BaseRequest> Function(http.BaseRequest request) onSend;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    return _inner.send(await onSend(request));
  }
}
