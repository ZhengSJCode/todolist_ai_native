import 'package:flutter/material.dart';

import '../app.dart';

class TodoBottomNavBar extends StatelessWidget {
  const TodoBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onSelected,
    required this.onAddPressed,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onSelected;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: SizedBox(
        height: 78,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              top: 22,
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Color(0xFFF1EBFF),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x12000000),
                      blurRadius: 20,
                      offset: Offset(0, -6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    _NavItem(
                      key: const Key('nav-home'),
                      semanticLabel: 'Home',
                      icon: Icons.home_rounded,
                      selected: currentTab == AppTab.home,
                      onTap: () => onSelected(AppTab.home),
                    ),
                    _NavItem(
                      key: const Key('nav-calendar'),
                      semanticLabel: 'Calendar',
                      icon: Icons.calendar_today_rounded,
                      selected: currentTab == AppTab.calendar,
                      onTap: () => onSelected(AppTab.calendar),
                    ),
                    const Spacer(),
                    _NavItem(
                      key: const Key('nav-voice-kanban'),
                      semanticLabel: 'Voice Kanban',
                      icon: Icons.list_alt,
                      selected: currentTab == AppTab.voiceKanban,
                      onTap: () => onSelected(AppTab.voiceKanban),
                    ),
                    _NavItem(
                      key: const Key('nav-documents'),
                      semanticLabel: 'Documents',
                      icon: Icons.description_outlined,
                      selected: currentTab == AppTab.documents,
                      onTap: () => onSelected(AppTab.documents),
                    ),
                    _NavItem(
                      key: const Key('nav-profile'),
                      semanticLabel: 'Profile',
                      icon: Icons.group_outlined,
                      selected: currentTab == AppTab.profile,
                      onTap: () => onSelected(AppTab.profile),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Center(
                child: GestureDetector(
                  onTap: onAddPressed,
                  child: Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF7D4CFF), Color(0xFF5F33E1)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color(0x555F33E1),
                          blurRadius: 16,
                          offset: Offset(0, 8),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.add, color: Colors.white, size: 30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    super.key,
    required this.semanticLabel,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String semanticLabel;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF5F33E1) : const Color(0xFF9C8FE8);

    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(top: 18),
        child: InkWell(
          onTap: onTap,
          child: Semantics(
            label: semanticLabel,
            button: true,
            child: Icon(icon, size: 22, color: color),
          ),
        ),
      ),
    );
  }
}
