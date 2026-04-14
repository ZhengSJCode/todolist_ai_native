import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'voice_transcriber.dart';

class DoubaoVoiceTranscriber implements VoiceTranscriber {
  DoubaoVoiceTranscriber({
    http.Client? httpClient,
    required String baseUrl,
    required String apiKey,
    required String model,
  }) : _client = httpClient ?? http.Client(),
       _baseUrl = baseUrl,
       _apiKey = apiKey,
       _model = model;

  factory DoubaoVoiceTranscriber.fromEnvironment({http.Client? httpClient}) {
    final baseUrl = Platform.environment['DOUBAO_ASR_BASE_URL'];
    final apiKey = Platform.environment['DOUBAO_API_KEY'];
    final model = Platform.environment['DOUBAO_ASR_MODEL'];

    if (baseUrl == null || baseUrl.isEmpty) {
      throw StateError('DOUBAO_ASR_BASE_URL is required');
    }
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('DOUBAO_API_KEY is required');
    }
    if (model == null || model.isEmpty) {
      throw StateError('DOUBAO_ASR_MODEL is required');
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

  @override
  Future<String> transcribe(VoiceAudioPayload payload) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/audio/transcriptions'),
    );
    request.headers['authorization'] = 'Bearer $_apiKey';
    request.fields['model'] = _model;
    request.fields['response_format'] = 'json';
    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        payload.bytes,
        filename: payload.fileName,
        contentType: MediaType('application', 'octet-stream'),
      ),
    );

    final response = await _sendRequest(request);
    if (response.statusCode != 200) {
      throw VoiceTranscriptionException(
        'Doubao ASR request failed: ${response.statusCode} ${response.body}',
      );
    }

    final decoded = _decodeBody(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw VoiceTranscriptionException('Doubao ASR returned empty text');
    }

    final transcript = (decoded['text'] as String?)?.trim() ?? '';
    if (transcript.isEmpty) {
      throw VoiceTranscriptionException('Doubao ASR returned empty text');
    }

    return transcript;
  }

  Future<http.Response> _sendRequest(http.MultipartRequest request) async {
    try {
      final streamedResponse = await _client.send(request);
      return http.Response.fromStream(streamedResponse);
    } catch (error) {
      if (error is VoiceTranscriptionException) rethrow;
      throw VoiceTranscriptionException('Doubao ASR request failed: $error');
    }
  }

  dynamic _decodeBody(String body) {
    try {
      return jsonDecode(body);
    } catch (error) {
      throw VoiceTranscriptionException(
        'Doubao ASR response parse failed: $error',
      );
    }
  }
}
