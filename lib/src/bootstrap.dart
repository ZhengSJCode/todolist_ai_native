import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

Widget createAppRoot({bool startAtHome = false}) {
  return ProviderScope(child: TodoApp(startAtHome: startAtHome));
}
