import 'dart:io';

import 'package:todolist_server/server.dart';

void main() async {
  final server = await createServer(port: 9001, address: InternetAddress.anyIPv4);
  stdout.writeln('Server running on http://${server.address.host}:${server.port}');
}
