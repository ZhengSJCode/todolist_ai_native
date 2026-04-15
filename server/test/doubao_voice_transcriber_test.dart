import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';
import 'package:todolist_server/doubao_voice_transcriber.dart';
import 'package:todolist_server/voice_transcriber.dart';

void main() {
  const payload = VoiceAudioPayload(
    bytes: [1, 2, 3],
    fileName: 'voice-input.pcm',
    mimeType: 'application/octet-stream',
    format: 'pcm_s16le',
    sampleRateHz: 16000,
  );

  test('submits LAS task then polls to get transcript', () async {
    var callCount = 0;
    final mockClient = MockClient((request) async {
      callCount += 1;
      expect(request.method, 'POST');
      expect(request.headers['authorization'], 'test-key');
      expect(request.headers['content-type'], 'application/json');

      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (callCount == 1) {
        expect(request.url.toString(), 'https://operator.example/api/v1/submit');
        expect(body['operator_id'], 'las_asr');
        expect(body['operator_version'], 'v2');
        expect(body['data']['request']['model_name'], 'bigmodel');
        expect(body['data']['audio']['format'], 'pcm');
        expect(body['data']['audio']['data'], base64Encode([1, 2, 3]));
        return http.Response(
          '{"metadata":{"task_id":"task-1","task_status":"ACCEPTED","business_code":"0","error_msg":""}}',
          200,
        );
      }

      expect(request.url.toString(), 'https://operator.example/api/v1/poll');
      expect(body['task_id'], 'task-1');
      return http.Response.bytes(
        utf8.encode(
          '{"metadata":{"task_id":"task-1","task_status":"COMPLETED","business_code":"0","error_msg":""},"data":{"result":{"text":"买鸡蛋"}}}',
        ),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final transcriber = DoubaoVoiceTranscriber(
      httpClient: mockClient,
      baseUrl: 'https://operator.example',
      apiKey: 'test-key',
      model: 'bigmodel',
      pollInterval: Duration.zero,
      maxPollAttempts: 2,
    );

    final transcript = await transcriber.transcribe(payload);

    expect(transcript, '买鸡蛋');
  });

  test('throws when LAS poll reports failed status', () async {
    var callCount = 0;
    final mockClient = MockClient((request) async {
      callCount += 1;
      if (callCount == 1) {
        return http.Response(
          '{"metadata":{"task_id":"task-2","task_status":"ACCEPTED","business_code":"0","error_msg":""}}',
          200,
        );
      }
      return http.Response(
        '{"metadata":{"task_id":"task-2","task_status":"FAILED","business_code":"0","error_msg":"engine error"}}',
        200,
      );
    });

    final transcriber = DoubaoVoiceTranscriber(
      httpClient: mockClient,
      baseUrl: 'https://operator.example',
      apiKey: 'test-key',
      model: 'bigmodel',
      pollInterval: Duration.zero,
      maxPollAttempts: 2,
    );

    await expectLater(
      () => transcriber.transcribe(payload),
      throwsA(isA<VoiceTranscriptionException>()),
    );
  });

  test('throws when LAS returns invalid json', () async {
    final mockClient = MockClient((request) async {
      return http.Response.bytes(
        utf8.encode('not json'),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final transcriber = DoubaoVoiceTranscriber(
      httpClient: mockClient,
      baseUrl: 'https://operator.example',
      apiKey: 'test-key',
      model: 'bigmodel',
      pollInterval: Duration.zero,
      maxPollAttempts: 1,
    );

    await expectLater(
      () => transcriber.transcribe(payload),
      throwsA(isA<VoiceTranscriptionException>()),
    );
  });

  test('throws timeout when task keeps running', () async {
    final mockClient = MockClient((request) async {
      if (request.url.path.endsWith('/submit')) {
        return http.Response(
          '{"metadata":{"task_id":"task-timeout","task_status":"ACCEPTED","business_code":"0","error_msg":""}}',
          200,
        );
      }
      return http.Response(
        '{"metadata":{"task_id":"task-timeout","task_status":"RUNNING","business_code":"0","error_msg":""}}',
        200,
      );
    });

    final transcriber = DoubaoVoiceTranscriber(
      httpClient: mockClient,
      baseUrl: 'https://operator.example',
      apiKey: 'test-key',
      model: 'bigmodel',
      pollInterval: Duration.zero,
      maxPollAttempts: 2,
    );

    await expectLater(
      () => transcriber.transcribe(payload),
      throwsA(
        isA<VoiceTranscriptionException>().having(
          (e) => e.message,
          'message',
          contains('timeout'),
        ),
      ),
    );
  });

  test('throws when submit business code is not zero', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        '{"metadata":{"task_id":"task-biz","task_status":"ACCEPTED","business_code":"1001","error_msg":"invalid auth"}}',
        200,
      );
    });

    final transcriber = DoubaoVoiceTranscriber(
      httpClient: mockClient,
      baseUrl: 'https://operator.example',
      apiKey: 'test-key',
      model: 'bigmodel',
      pollInterval: Duration.zero,
      maxPollAttempts: 1,
    );

    await expectLater(
      () => transcriber.transcribe(payload),
      throwsA(
        isA<VoiceTranscriptionException>().having(
          (e) => e.message,
          'message',
          contains('invalid auth'),
        ),
      ),
    );
  });
}
