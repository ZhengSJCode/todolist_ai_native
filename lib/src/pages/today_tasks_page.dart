import 'package:flutter/material.dart';

import '../api/todo_model.dart';
import 'task_details_page.dart';
import '../widgets/task_detail_card.dart';

enum _TaskFilter { all, todo, inProgress, completed }

class _UiTask {
  const _UiTask({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.time,
    required this.day,
    required this.status,
    required this.icon,
    required this.iconBackground,
    required this.statusBackground,
    required this.statusColor,
  });

  final String id;
  final String category;
  final String title;
  final String description;
  final String time;
  final String day;
  final String status;
  final IconData icon;
  final Color iconBackground;
  final Color statusBackground;
  final Color statusColor;

  bool get completed => status == 'Done';

  _UiTask copyWith({
    String? status,
    Color? statusBackground,
    Color? statusColor,
  }) {
    return _UiTask(
      id: id,
      category: category,
      title: title,
      description: description,
      time: time,
      day: day,
      status: status ?? this.status,
      icon: icon,
      iconBackground: iconBackground,
      statusBackground: statusBackground ?? this.statusBackground,
      statusColor: statusColor ?? this.statusColor,
    );
  }
}

final _kSeedTasks = <_UiTask>[
  const _UiTask(
    id: 'research',
    category: 'Grocery shopping app design',
    title: 'Market Research',
    description: 'Review product patterns and gather benchmark references.',
    time: '10:00 AM',
    day: '25',
    status: 'Done',
    icon: Icons.work_outline_rounded,
    iconBackground: Color(0xFFFFE4F2),
    statusBackground: Color(0xFFEDE8FF),
    statusColor: Color(0xFF5F33E1),
  ),
  const _UiTask(
    id: 'analysis',
    category: 'Grocery shopping app design',
    title: 'Competitive Analysis',
    description: 'Compare top checkout flows and summarize usability gaps.',
    time: '12:00 PM',
    day: '25',
    status: 'In Progress',
    icon: Icons.work_outline_rounded,
    iconBackground: Color(0xFFFFE4F2),
    statusBackground: Color(0xFFFFE9E1),
    statusColor: Color(0xFFFF7D53),
  ),
  const _UiTask(
    id: 'wireframe',
    category: 'Uber Eats redesign challange',
    title: 'Create Low-fidelity Wireframe',
    description: 'Sketch the ordering path and map the user’s first run.',
    time: '07:00 PM',
    day: '25',
    status: 'To-do',
    icon: Icons.sell_outlined,
    iconBackground: Color(0xFFEDE4FF),
    statusBackground: Color(0xFFE3F2FF),
    statusColor: Color(0xFF0087FF),
  ),
  const _UiTask(
    id: 'pitch',
    category: 'About design sprint',
    title: 'How to pitch a Design Sprint',
    description: 'Prepare a short outline for the workshop kickoff.',
    time: '09:00 PM',
    day: '26',
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
  const TodayTasksPage({super.key, this.onBack, this.onOpenNotifications});

  final VoidCallback? onBack;
  final VoidCallback? onOpenNotifications;

  @override
  State<TodayTasksPage> createState() => _TodayTasksPageState();
}

class _TodayTasksPageState extends State<TodayTasksPage> {
  _TaskFilter _filter = _TaskFilter.all;
  String _selectedDay = '25';
  late final List<_UiTask> _tasks = [..._kSeedTasks];

  @override
  Widget build(BuildContext context) {
    final visible = _tasks
        .where((t) => t.day == _selectedDay)
        .where((t) => _matchFilter(_filter, t.status))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      children: [
        _TodayHeader(
          onBack: widget.onBack,
          onOpenNotifications: widget.onOpenNotifications,
        ),
        const SizedBox(height: 24),
        _DateChipsRow(
          selectedDay: _selectedDay,
          onSelected: (day) => setState(() => _selectedDay = day),
        ),
        const SizedBox(height: 20),
        _FilterRow(
          current: _filter,
          onSelected: (f) => setState(() => _filter = f),
        ),
        const SizedBox(height: 28),
        if (visible.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0D000000),
                  blurRadius: 24,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: const Text(
              'Nothing is scheduled for this filter yet.',
              style: TextStyle(fontSize: 14, color: Color(0xFF6E6A7C)),
            ),
          ),
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
            onTap: () => _openTaskDetails(t),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Future<void> _openTaskDetails(_UiTask task) async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => TaskDetailsPage(
          todo: TodoModel(
            id: task.id,
            title: task.title,
            description: task.description,
            completed: task.completed,
          ),
          onToggleComplete: () {
            setState(() {
              final index = _tasks.indexWhere((item) => item.id == task.id);
              if (index == -1) {
                return;
              }
              final isDone = !_tasks[index].completed;
              _tasks[index] = _tasks[index].copyWith(
                status: isDone ? 'Done' : 'To-do',
                statusBackground: isDone
                    ? const Color(0xFFEDE8FF)
                    : const Color(0xFFE3F2FF),
                statusColor: isDone
                    ? const Color(0xFF5F33E1)
                    : const Color(0xFF0087FF),
              );
            });
            Navigator.of(context).pop();
          },
          onDelete: () {
            setState(() {
              _tasks.removeWhere((item) => item.id == task.id);
            });
            Navigator.of(context).pop();
          },
        ),
      ),
    );
  }
}

class _TodayHeader extends StatelessWidget {
  const _TodayHeader({this.onBack, this.onOpenNotifications});

  final VoidCallback? onBack;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 44,
          child: IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, color: Color(0xFF24252C)),
          ),
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Today\u2019s Tasks',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        SizedBox(
          width: 44,
          child: IconButton(
            onPressed: onOpenNotifications,
            icon: const Icon(Icons.notifications, color: Color(0xFF24252C)),
          ),
        ),
      ],
    );
  }
}

class _DateChipsRow extends StatelessWidget {
  const _DateChipsRow({required this.selectedDay, required this.onSelected});

  final String selectedDay;
  final ValueChanged<String> onSelected;

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
          final isSelected = selectedDay == entry.$2;
          return GestureDetector(
            onTap: () => onSelected(entry.$2),
            child: Container(
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
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                  Text(
                    entry.$2,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                  Text(
                    entry.$3,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? Colors.white
                          : const Color(0xFF24252C),
                    ),
                  ),
                ],
              ),
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
                      : const Color(0xFFF1EBFF),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 10,
                ),
                child: Text(
                  chip.$1,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: current == chip.$2
                        ? FontWeight.w600
                        : FontWeight.w400,
                    color: current == chip.$2
                        ? Colors.white
                        : const Color(0xFF5F33E1),
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
