import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/app.dart';

export 'src/app.dart' show MyApp;

void main() {
  runApp(const ProviderScope(child: MyApp()));
}
