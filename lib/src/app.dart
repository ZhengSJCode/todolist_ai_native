import 'package:flutter/material.dart';

import 'pages/home_page.dart';
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
  return const {
    AppTab.home: AppScreenConfig(body: HomePage(), label: 'Home'),
    AppTab.calendar: AppScreenConfig(body: TodayTasksPage(), label: 'Calendar'),
    AppTab.add: AppScreenConfig(body: HomePage(), label: 'Add'),
    AppTab.documents: AppScreenConfig(body: HomePage(), label: 'Documents'),
    AppTab.profile: AppScreenConfig(body: HomePage(), label: 'Profile'),
  };
}
