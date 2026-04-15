import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'voice_transcriber.dart';

class DoubaoVoiceTranscriber implements VoiceTranscriber {
  DoubaoVoiceTranscriber({
    http.Client? httpClient,
    required String baseUrl,
    required String apiKey,
    required String model,
    this.pollInterval = const Duration(milliseconds: 800),
    this.maxPollAttempts = 30,
  }) : _client = httpClient ?? http.Client(),
       _baseUrl = baseUrl,
       _apiKey = apiKey,
       _model = model;

  factory DoubaoVoiceTranscriber.fromEnvironment({http.Client? httpClient}) {
    final baseUrl =
        Platform.environment['LAS_BASE_URL'] ??
        'https://operator.las.cn-beijing.volces.com';
    final apiKey = Platform.environment['LAS_API_KEY'];
    final model = Platform.environment['LAS_MODEL_NAME'] ?? 'bigmodel';

    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('LAS_API_KEY is required');
    }

    return DoubaoVoiceTranscriber(
      httpClient: httpClient,
      baseUrl: baseUrl,
      apiKey: apiKey,
      model: model,
    );
  }

  final http.Client _client;
  final String _baseUrl;
  final String _apiKey;
  final String _model;
  final Duration pollInterval;
  final int maxPollAttempts;

  @override
  Future<String> transcribe(VoiceAudioPayload payload) async {
    final taskId = await _submit(payload);
    return _pollUntilCompleted(taskId);
  }

  Future<String> _submit(VoiceAudioPayload payload) async {
    final response = await _postJson(
      path: '/api/v1/submit',
      body: {
        'operator_id': 'las_asr',
        'operator_version': 'v2',
        'data': {
          'audio': {
            // LAS Operator accepts structured audio object.
            // Use inline base64 payload to avoid requiring external file hosting.
            'data': base64Encode(payload.bytes),
            'format': _normalizeFormat(payload.format),
          },
          'request': {'model_name': _model},
        },
      },
    );
    if (response.statusCode != 200) {
      throw VoiceTranscriptionException(
        'LAS submit failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = _decodeBody(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw VoiceTranscriptionException('LAS submit response is invalid');
    }

    final metadata = decoded['metadata'];
    if (metadata is! Map<String, dynamic>) {
      throw VoiceTranscriptionException('LAS submit response missing metadata');
    }
    final taskId = (metadata['task_id'] as String?)?.trim() ?? '';
    if (taskId.isEmpty) {
      throw VoiceTranscriptionException('LAS submit response missing task_id');
    }
    final businessCode = (metadata['business_code'] as String?)?.trim() ?? '0';
    if (businessCode != '0') {
      final errorMessage =
          (metadata['error_msg'] as String?)?.trim() ?? 'Unknown LAS error';
      throw VoiceTranscriptionException('LAS submit failed: $errorMessage');
    }
    return taskId;
  }

  Future<String> _pollUntilCompleted(String taskId) async {
    for (var i = 0; i < maxPollAttempts; i++) {
      if (i > 0) {
        await Future<void>.delayed(pollInterval);
      }

      final response = await _postJson(
        path: '/api/v1/poll',
        body: {
          'operator_id': 'las_asr',
          'operator_version': 'v2',
          'task_id': taskId,
        },
      );
      if (response.statusCode != 200) {
        throw VoiceTranscriptionException(
          'LAS poll failed: ${response.statusCode} ${response.body}',
        );
      }

      final decoded = _decodeBody(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw VoiceTranscriptionException('LAS poll response is invalid');
      }

      final metadata = decoded['metadata'];
      if (metadata is! Map<String, dynamic>) {
        throw VoiceTranscriptionException('LAS poll response missing metadata');
      }
      final status = (metadata['task_status'] as String?)?.trim() ?? '';
      final businessCode = (metadata['business_code'] as String?)?.trim() ?? '0';
      if (businessCode != '0') {
        final errorMessage =
            (metadata['error_msg'] as String?)?.trim() ??
            'Unknown LAS task error';
        throw VoiceTranscriptionException('LAS poll failed: $errorMessage');
      }

      if (status == 'COMPLETED') {
        final data = decoded['data'];
        if (data is! Map<String, dynamic>) {
          throw VoiceTranscriptionException('LAS completed response missing data');
        }
        final result = data['result'];
        if (result is! Map<String, dynamic>) {
          throw VoiceTranscriptionException(
            'LAS completed response missing result',
          );
        }
        final transcript = (result['text'] as String?)?.trim() ?? '';
        if (transcript.isEmpty) {
          throw VoiceTranscriptionException('LAS returned empty text');
        }
        return transcript;
      }

      if (status == 'FAILED' || status == 'CANCELED') {
        final errorMessage =
            (metadata['error_msg'] as String?)?.trim() ?? 'LAS task failed';
        throw VoiceTranscriptionException(errorMessage);
      }

      if (status != 'ACCEPTED' && status != 'RUNNING') {
        throw VoiceTranscriptionException('LAS unknown task status: $status');
      }
    }

    throw VoiceTranscriptionException('LAS poll timeout for task: $taskId');
  }

  Future<http.Response> _postJson({
    required String path,
    required Map<String, Object?> body,
  }) async {
    final url = Uri.parse('$_baseUrl$path');
    try {
      return await _client.post(
        url,
        headers: {
          'content-type': 'application/json',
          'authorization': _apiKey,
        },
        body: jsonEncode(body),
      );
    } catch (error) {
      throw VoiceTranscriptionException('LAS request failed: $error');
    }
  }

  String _normalizeFormat(String rawFormat) {
    if (rawFormat == 'pcm_s16le') {
      return 'pcm';
    }
    return rawFormat;
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (error) {
      throw VoiceTranscriptionException(
        'LAS response parse failed: $error',
      );
    }
  }
}
