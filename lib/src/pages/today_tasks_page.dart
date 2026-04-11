import 'package:flutter/material.dart';

import '../widgets/task_detail_card.dart';

enum _TaskFilter { all, todo, inProgress, completed }

/// Static mock data for today's tasks display (Figma 101:265).
const _kTasks = [
  (
    category: 'Grocery shopping app design',
    title: 'Market Research',
    time: '10:00 AM',
    status: 'Done',
    icon: Icons.work_outline_rounded,
    iconBackground: Color(0xFFFFE4F2),
    statusBackground: Color(0xFFEDE8FF),
    statusColor: Color(0xFF5F33E1),
  ),
  (
    category: 'Grocery shopping app design',
    title: 'Competitive Analysis',
    time: '12:00 PM',
    status: 'In Progress',
    icon: Icons.work_outline_rounded,
    iconBackground: Color(0xFFFFE4F2),
    statusBackground: Color(0xFFFFE9E1),
    statusColor: Color(0xFFFF7D53),
  ),
  (
    category: 'Uber Eats redesign challange',
    title: 'Create Low-fidelity Wireframe',
    time: '07:00 PM',
    status: 'To-do',
    icon: Icons.sell_outlined,
    iconBackground: Color(0xFFEDE4FF),
    statusBackground: Color(0xFFE3F2FF),
    statusColor: Color(0xFF0087FF),
  ),
  (
    category: 'About design sprint',
    title: 'How to pitch a Design Sprint',
    time: '09:00 PM',
    status: 'To-do',
    icon: Icons.menu_book_outlined,
    iconBackground: Color(0xFFFFE6D4),
    statusBackground: Color(0xFFE3F2FF),
    statusColor: Color(0xFF0087FF),
  ),
];

bool _matchFilter(_TaskFilter filter, String status) {
  return switch (filter) {
    _TaskFilter.all => true,
    _TaskFilter.todo => status == 'To-do',
    _TaskFilter.inProgress => status == 'In Progress',
    _TaskFilter.completed => status == 'Done',
  };
}

class TodayTasksPage extends StatefulWidget {
  const TodayTasksPage({super.key});

  @override
  State<TodayTasksPage> createState() => _TodayTasksPageState();
}

class _TodayTasksPageState extends State<TodayTasksPage> {
  _TaskFilter _filter = _TaskFilter.all;

  @override
  Widget build(BuildContext context) {
    final visible = _kTasks.where((t) => _matchFilter(_filter, t.status)).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      children: [
        const _TodayHeader(),
        const SizedBox(height: 24),
        const _DateChipsRow(),
        const SizedBox(height: 20),
        _FilterRow(
          current: _filter,
          onSelected: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 28),
        for (final t in visible) ...[
          TaskDetailCard(
            category: t.category,
            title: t.title,
            time: t.time,
            status: t.status,
            icon: t.icon,
            iconBackground: t.iconBackground,
            statusBackground: t.statusBackground,
            statusColor: t.statusColor,
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Icon(Icons.arrow_back, color: Color(0xFF24252C)),
        Spacer(),
        Text(
          'Today\u2019s Tasks',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        Spacer(),
        Icon(Icons.notifications, color: Color(0xFF24252C)),
      ],
    );
  }
}

class _DateChipsRow extends StatelessWidget {
  const _DateChipsRow();

  @override
  Widget build(BuildContext context) {
    final dates = const [
      ('May', '23', 'Fri', false),
      ('May', '24', 'Sat', false),
      ('May', '25', 'Sun', true),
      ('May', '26', 'Mon', false),
      ('May', '27', 'Tue', false),
    ];

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final entry = dates[index];
          final isSelected = entry.$4;
          return Container(
            width: 64,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF5F33E1) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: isSelected
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x12000000),
                        blurRadius: 24,
                        offset: Offset(0, 4),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(entry.$1,
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : const Color(0xFF24252C))),
                Text(entry.$2,
                    style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : const Color(0xFF24252C))),
                Text(entry.$3,
                    style: TextStyle(
                        fontSize: 11,
                        color: isSelected ? Colors.white : const Color(0xFF24252C))),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow({required this.current, required this.onSelected});

  final _TaskFilter current;
  final ValueChanged<_TaskFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    final chips = [
      ('All', _TaskFilter.all, const Key('filter-all')),
      ('To do', _TaskFilter.todo, const Key('filter-todo')),
      ('In Progress', _TaskFilter.inProgress, const Key('filter-in-progress')),
      ('Completed', _TaskFilter.completed, const Key('filter-completed')),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final chip in chips) ...[
            GestureDetector(
              key: chip.$3,
              onTap: () => onSelected(chip.$2),
              child: Container(
                decoration: BoxDecoration(
                  color: current == chip.$2
                      ? const Color(0xFF5F33E1)
                      : const Color(0xFFF1EBFF),                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                child: Text(
                  chip.$1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: current == chip.$2 ? FontWeight.w600 : FontWeight.w400,
                    color: current == chip.$2 ? Colors.white : const Color(0xFF5F33E1),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
        ],
      ),
    );
  }
}
