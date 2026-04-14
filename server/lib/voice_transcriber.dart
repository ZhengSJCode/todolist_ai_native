class VoiceAudioPayload {
  const VoiceAudioPayload({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.format,
    required this.sampleRateHz,
  });

  final List<int> bytes;
  final String fileName;
  final String mimeType;
  final String format;
  final int sampleRateHz;
}

abstract interface class VoiceTranscriber {
  Future<String> transcribe(VoiceAudioPayload payload);
}

class VoiceTranscriptionException implements Exception {
  const VoiceTranscriptionException(this.message);

  final String message;

  @override
  String toString() => 'VoiceTranscriptionException($message)';
}
