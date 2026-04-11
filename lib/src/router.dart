import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'pages/live_todos_page.dart';
import 'pages/lets_start_page.dart';
import 'pages/projects_page.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

abstract final class ScreenPaths {
  static const start = '/start';
  static const home = '/home';
  static const tasks = '/tasks';
  static const projects = '/projects';
}

GoRouter buildAppRouter({bool startAtHome = false}) {
  return GoRouter(
    initialLocation: startAtHome ? ScreenPaths.home : ScreenPaths.start,
    routes: [
      GoRoute(
        path: ScreenPaths.start,
        builder: (context, state) =>
            LetsStartPage(onStart: () => context.go(ScreenPaths.home)),
      ),
      GoRoute(
        path: ScreenPaths.home,
        builder: (context, state) => const AppShell(),
      ),
      GoRoute(
        path: ScreenPaths.tasks,
        builder: (context, state) =>
            const Scaffold(body: SafeArea(child: LiveTodosPage())),
      ),
      GoRoute(
        path: ScreenPaths.projects,
        builder: (context, state) =>
            const Scaffold(body: SafeArea(child: ProjectsPage())),
      ),
    ],
  );
}

class TodoApp extends ConsumerWidget {
  const TodoApp({super.key, this.startAtHome = false});

  final bool startAtHome;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: buildAppTheme(),
      routerConfig: buildAppRouter(startAtHome: startAtHome),
    );
  }
}
