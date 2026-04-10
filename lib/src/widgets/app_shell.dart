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
      body: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.white),
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
            SafeArea(child: current.body),
          ],
        ),
      ),
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
