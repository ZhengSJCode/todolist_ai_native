import 'package:flutter/material.dart';

import '../widgets/task_detail_card.dart';

class TodayTasksPage extends StatelessWidget {
  const TodayTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      children: const [
        _TodayHeader(),
        SizedBox(height: 24),
        _DateChipsRow(),
        SizedBox(height: 20),
        _FilterRow(),
        SizedBox(height: 28),
        TaskDetailCard(
          category: 'Grocery shopping app design',
          title: 'Market Research',
          time: '10:00 AM',
          status: 'Done',
          icon: Icons.work_outline_rounded,
          iconBackground: Color(0xFFFFE4F2),
          statusBackground: Color(0xFFEDE8FF),
          statusColor: Color(0xFF5F33E1),
        ),
        SizedBox(height: 16),
        TaskDetailCard(
          category: 'Grocery shopping app design',
          title: 'Competitive Analysis',
          time: '12:00 PM',
          status: 'In Progress',
          icon: Icons.work_outline_rounded,
          iconBackground: Color(0xFFFFE4F2),
          statusBackground: Color(0xFFFFE9E1),
          statusColor: Color(0xFFFF7D53),
        ),
        SizedBox(height: 16),
        TaskDetailCard(
          category: 'Uber Eats redesign challange',
          title: 'Create Low-fidelity Wireframe',
          time: '07:00 PM',
          status: 'To-do',
          icon: Icons.sell_outlined,
          iconBackground: Color(0xFFEDE4FF),
          statusBackground: Color(0xFFE3F2FF),
          statusColor: Color(0xFF0087FF),
        ),
        SizedBox(height: 16),
        TaskDetailCard(
          category: 'About design sprint',
          title: 'How to pitch a Design Sprint',
          time: '09:00 PM',
          status: 'To-do',
          icon: Icons.menu_book_outlined,
          iconBackground: Color(0xFFFFE6D4),
          statusBackground: Color(0xFFE3F2FF),
          statusColor: Color(0xFF0087FF),
        ),
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
          'Today’s Tasks',
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
                Text(
                  entry.$1,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : const Color(0xFF24252C),
                  ),
                ),
                Text(
                  entry.$2,
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : const Color(0xFF24252C),
                  ),
                ),
                Text(
                  entry.$3,
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.white : const Color(0xFF24252C),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    final filters = const [
      ('All', true),
      ('To do', false),
      ('In Progress', false),
      ('Completed', false),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in filters) ...[
            Container(
              decoration: BoxDecoration(
                color: filter.$2
                    ? const Color(0xFF5F33E1)
                    : const Color(0xFFF1EBFF),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              child: Text(
                filter.$1,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: filter.$2 ? FontWeight.w600 : FontWeight.w400,
                  color: filter.$2 ? Colors.white : const Color(0xFF5F33E1),
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
