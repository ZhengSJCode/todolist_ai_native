import 'dart:typed_data';

class RecordedAudioClip {
  const RecordedAudioClip({
    required this.bytes,
    required this.fileName,
    required this.format,
    required this.sampleRateHz,
  });

  final Uint8List bytes;
  final String fileName;
  final String format;
  final int sampleRateHz;
}
