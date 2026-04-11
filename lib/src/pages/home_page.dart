import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/project_provider.dart';
import '../widgets/project_progress_card.dart';
import '../widgets/task_group_tile.dart';

class HomePage extends ConsumerWidget {
  const HomePage({
    super.key,
    this.onOpenNotifications,
    this.onViewTasks,
    this.onOpenProjects,
  });

  final VoidCallback? onOpenNotifications;
  final VoidCallback? onViewTasks;
  final VoidCallback? onOpenProjects;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);
    final highlights = projects.take(2).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      children: [
        _HomeHeader(onOpenNotifications: onOpenNotifications),
        const SizedBox(height: 24),
        _HeroProgressCard(onViewTasks: onViewTasks),
        const SizedBox(height: 24),
        _SectionHeader(title: 'In Progress', count: '${highlights.length}'),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (var index = 0; index < highlights.length; index++) ...[
                ProjectProgressCard(
                  tag: highlights[index].tag,
                  title: highlights[index].name.replaceFirst(' app ', ' app\n'),
                  progress: highlights[index].progress,
                  progressLabel: highlights[index].progressLabel,
                  backgroundColor: highlights[index].backgroundColor,
                  accentColor: highlights[index].accentColor,
                  onTap: onOpenProjects,
                ),
                if (index < highlights.length - 1) const SizedBox(width: 16),
              ],
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader(title: 'Task Groups', count: '${projects.length}'),
        const SizedBox(height: 16),
        for (var index = 0; index < projects.length; index++) ...[
          TaskGroupTile(
            title: projects[index].tag,
            subtitle: projects[index].subtitle,
            progressLabel: projects[index].progressLabel,
            icon: projects[index].icon,
            iconBackground: projects[index].iconBackground,
            accentColor: projects[index].accentColor,
            onTap: onOpenProjects,
          ),
          if (index < projects.length - 1) const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({this.onOpenNotifications});

  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 23,
          backgroundColor: Color(0xFF1490D2),
          child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text('Hello!', style: TextStyle(fontSize: 14)),
              SizedBox(height: 2),
              Text(
                'Livia Vaccaro',
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: onOpenNotifications,
          child: Stack(
            children: const [
              Icon(Icons.notifications, color: Color(0xFF24252C)),
              Positioned(
                right: 0,
                top: 0,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Color(0xFF7D4CFF),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroProgressCard extends StatelessWidget {
  const _HeroProgressCard({this.onViewTasks});

  final VoidCallback? onViewTasks;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF6B3FF0), Color(0xFF5F33E1)],
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your today’s task\nalmost done!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: onViewTasks,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF5F33E1),
                  ),
                  child: const Text('View Task'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 96,
            height: 96,
            child: Stack(
              alignment: Alignment.center,
              children: const [
                CircularProgressIndicator(
                  value: 0.85,
                  strokeWidth: 7,
                  backgroundColor: Color(0x66FFFFFF),
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
                Text(
                  '85%',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.count});

  final String title;
  final String count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Color(0xFFEDE4FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            count,
            style: const TextStyle(fontSize: 11, color: Color(0xFF5F33E1)),
          ),
        ),
      ],
    );
  }
}
