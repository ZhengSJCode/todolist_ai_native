import 'dart:io';

import 'package:todolist_server/server.dart';

void main() async {
  final server = await createServer(port: 9001);
  stdout.writeln('Server running on http://192.168.67.235:${server.port}');
}
