import 'lib/server.dart';

void main() async {
  final server = await createServer(port: 8080);
  print('Server running on http://localhost:${server.port}');
}
