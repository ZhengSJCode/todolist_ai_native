import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'router.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ProviderScope(child: TodoApp(startAtHome: true));
  }
}

enum AppTab { home, calendar, documents, profile, voiceKanban }
