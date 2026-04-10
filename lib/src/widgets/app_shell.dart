import 'package:flutter/material.dart';

import '../app.dart';
import 'bottom_nav_bar.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  AppTab _currentTab = AppTab.home;
  late final Map<AppTab, AppScreenConfig> _screens = buildScreens();

  @override
  Widget build(BuildContext context) {
    final current = _screens[_currentTab]!;

    return Scaffold(
      body: SafeArea(child: current.body),
      bottomNavigationBar: TodoBottomNavBar(
        currentTab: _currentTab,
        onSelected: (tab) {
          setState(() {
            _currentTab = tab;
          });
        },
      ),
    );
  }
}
