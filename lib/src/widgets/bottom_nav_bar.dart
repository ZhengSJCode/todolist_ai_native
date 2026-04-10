import 'package:flutter/material.dart';

import '../app.dart';

class TodoBottomNavBar extends StatelessWidget {
  const TodoBottomNavBar({
    super.key,
    required this.currentTab,
    required this.onSelected,
  });

  final AppTab currentTab;
  final ValueChanged<AppTab> onSelected;

  @override
  Widget build(BuildContext context) {
    final items = <({AppTab tab, IconData icon, String label})>[
      (tab: AppTab.home, icon: Icons.home_rounded, label: 'Home'),
      (
        tab: AppTab.calendar,
        icon: Icons.calendar_today_rounded,
        label: 'Calendar',
      ),
      (tab: AppTab.add, icon: Icons.add_circle_outline_rounded, label: 'Add'),
      (
        tab: AppTab.documents,
        icon: Icons.description_outlined,
        label: 'Documents',
      ),
      (tab: AppTab.profile, icon: Icons.group_outlined, label: 'Profile'),
    ];

    return DecoratedBox(
      decoration: const BoxDecoration(
        color: Color(0xFFF1EBFF),
        boxShadow: [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 20,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              for (final item in items)
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => onSelected(item.tab),
                    style: TextButton.styleFrom(
                      foregroundColor: currentTab == item.tab
                          ? const Color(0xFF5F33E1)
                          : const Color(0xFF9C8FE8),
                    ),
                    icon: Icon(item.icon, size: 20),
                    label: Text(item.label, overflow: TextOverflow.ellipsis),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
