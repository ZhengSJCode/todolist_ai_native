import 'dart:convert';

import 'package:http/http.dart' as http;

import '../audio/recorded_audio_clip.dart';
import 'todo_api_client.dart' show ApiException;
import 'voice_transcription_client.dart';

class HttpVoiceTranscriptionClient implements VoiceTranscriptionClient {
  HttpVoiceTranscriptionClient({http.Client? httpClient, String? baseUrl})
    : _client = httpClient ?? http.Client(),
      _base = baseUrl ?? 'http://192.168.67.235:9001';

  final http.Client _client;
  final String _base;

  @override
  Future<String> transcribe(RecordedAudioClip clip) async {
    final response = await _client.post(
      Uri.parse('$_base/voice/transcribe'),
      headers: {
        'content-type': 'application/octet-stream',
        'x-audio-format': clip.format,
        'x-sample-rate': '${clip.sampleRateHz}',
        'x-file-name': clip.fileName,
      },
      body: clip.bytes,
    );

    if (response.statusCode != 200) {
      var message = response.body;
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        message = decoded['error'] as String? ?? response.body;
      } catch (_) {}
      throw ApiException(response.statusCode, message);
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final transcript = (data['transcript'] as String?)?.trim() ?? '';
    if (transcript.isEmpty) {
      throw const ApiException(500, 'Missing transcript in response');
    }
    return transcript;
  }
}
