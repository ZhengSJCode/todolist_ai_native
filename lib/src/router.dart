import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/lets_start_page.dart';
import 'widgets/app_shell.dart';

/// Route path constants.
abstract final class ScreenPaths {
  static const start = '/start';
  static const home = '/home';
}

/// Builds the app router.
///
/// [startAtHome] skips the onboarding screen — useful in tests.
GoRouter buildAppRouter({bool startAtHome = false}) {
  return GoRouter(
    initialLocation: startAtHome ? ScreenPaths.home : ScreenPaths.start,
    routes: [
      GoRoute(
        path: ScreenPaths.start,
        builder: (context, state) => LetsStartPage(
          onStart: () => context.go(ScreenPaths.home),
        ),
      ),
      GoRoute(
        path: ScreenPaths.home,
        builder: (context, state) => const AppShell(),
      ),
    ],
  );
}

/// A [ProviderScope]-aware [MaterialApp] pre-wired with the app router.
class TodoApp extends ConsumerWidget {
  const TodoApp({super.key, this.startAtHome = false});

  final bool startAtHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      routerConfig: buildAppRouter(startAtHome: startAtHome),
    );
  }
}
