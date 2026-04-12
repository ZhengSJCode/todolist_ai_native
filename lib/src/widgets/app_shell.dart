import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';
import '../pages/add_project_page.dart';
import '../pages/home_page.dart';
import '../pages/live_todos_page.dart';
import '../pages/projects_page.dart';
import '../pages/today_tasks_page.dart';
import '../pages/voice_kanban_page.dart';
import '../provider/project_provider.dart';
import 'bottom_nav_bar.dart';
import 'notifications_sheet.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({super.key});

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> {
  AppTab _currentTab = AppTab.home;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(color: Color(0xFFFCFBFF)),
        child: Stack(
          children: [
            const _ScreenGlow(
              alignment: Alignment(-1.08, -0.7),
              color: Color(0x228FE7FF),
              size: 220,
            ),
            const _ScreenGlow(
              alignment: Alignment(1.15, -0.85),
              color: Color(0x1FFFF0A6),
              size: 210,
            ),
            const _ScreenGlow(
              alignment: Alignment(-0.95, 0.95),
              color: Color(0x188FD8FF),
              size: 240,
            ),
            SafeArea(child: _buildCurrentScreen()),
          ],
        ),
      ),
      bottomNavigationBar: TodoBottomNavBar(
        currentTab: _currentTab,
        onAddPressed: _openAddProject,
        onSelected: (tab) {
          setState(() {
            _currentTab = tab;
          });
        },
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentTab) {
      case AppTab.home:
        return HomePage(
          onOpenNotifications: _openNotifications,
          onViewTasks: () => _selectTab(AppTab.calendar),
          onOpenProjects: () => _selectTab(AppTab.documents),
        );
      case AppTab.calendar:
        return TodayTasksPage(
          onBack: () => _selectTab(AppTab.home),
          onOpenNotifications: _openNotifications,
        );
      case AppTab.documents:
        return ProjectsPage(
          onAddProject: _openAddProject,
          onOpenNotifications: _openNotifications,
        );
      case AppTab.profile:
        return LiveTodosPage(onOpenNotifications: _openNotifications);
      case AppTab.voiceKanban:
        return const VoiceKanbanPage();
    }
  }

  void _selectTab(AppTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  Future<void> _openAddProject() async {
    final result = await Navigator.of(context).push<AddProjectResult>(
      MaterialPageRoute(builder: (_) => const AddProjectPage()),
    );
    if (!mounted || result == null) {
      return;
    }

    ref
        .read(projectsProvider.notifier)
        .addProject(name: result.name, accentColor: result.color);
    _selectTab(AppTab.documents);
  }

  void _openNotifications() {
    showNotificationsSheet(context);
  }
}

class _ScreenGlow extends StatelessWidget {
  const _ScreenGlow({
    required this.alignment,
    required this.color,
    required this.size,
  });

  final Alignment alignment;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(colors: [color, Colors.transparent]),
          ),
        ),
      ),
    );
  }
}
