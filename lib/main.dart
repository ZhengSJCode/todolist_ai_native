import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/router.dart';

// Keep MyApp export for existing widget tests that use it directly.
export 'src/app.dart' show MyApp;

void main() {
  runApp(const ProviderScope(child: TodoApp()));
}
