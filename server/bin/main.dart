import 'dart:io';

import 'package:todolist_server/doubao_voice_transcriber.dart';
import 'package:todolist_server/server.dart';

void main() async {
  final server = await createServer(
    port: 9001,
    address: InternetAddress.anyIPv4,
    transcriber: DoubaoVoiceTranscriber.fromEnvironment(),
  );
  stdout.writeln(
    'Server running on http://${server.address.host}:${server.port}',
  );
}
