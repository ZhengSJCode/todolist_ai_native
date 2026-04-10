import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pages/home_page.dart';
import 'pages/live_todos_page.dart';
import 'pages/today_tasks_page.dart';
import 'theme/app_theme.dart';
import 'widgets/app_shell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Todo List',
      theme: buildAppTheme(),
      home: const AppShell(),
    );
  }
}

enum AppTab { home, calendar, add, documents, profile }

final class AppScreenConfig {
  const AppScreenConfig({required this.body, required this.label});

  final Widget body;
  final String label;
}

Map<AppTab, AppScreenConfig> buildScreens() {
  return {
    AppTab.home: const AppScreenConfig(body: HomePage(), label: 'Home'),
    AppTab.calendar: const AppScreenConfig(body: TodayTasksPage(), label: 'Calendar'),
    AppTab.add: const AppScreenConfig(body: HomePage(), label: 'Add'),
    // LiveTodosPage uses Riverpod — wrap in a fresh ProviderScope so it
    // works whether or not the parent already has one.
    AppTab.documents: AppScreenConfig(
      body: const ProviderScope(child: LiveTodosPage()),
      label: 'Tasks',
    ),
    AppTab.profile: const AppScreenConfig(body: HomePage(), label: 'Profile'),
  };
}
