import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../provider/project_provider.dart';
import '../widgets/task_group_tile.dart';

class ProjectsPage extends ConsumerWidget {
  const ProjectsPage({super.key, this.onAddProject, this.onOpenNotifications});

  final VoidCallback? onAddProject;
  final VoidCallback? onOpenNotifications;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projects = ref.watch(projectsProvider);

    return ListView(
      key: const Key('projects-list-view'),
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 8),
      children: [
        Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Projects',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF24252C),
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Everything you are actively planning right now.',
                    style: TextStyle(fontSize: 13, color: Color(0xFF6E6A7C)),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onOpenNotifications,
              icon: const Icon(Icons.notifications_none_rounded),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6D42F6), Color(0xFF5F33E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: const [
              BoxShadow(
                color: Color(0x145F33E1),
                blurRadius: 28,
                offset: Offset(0, 10),
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
                      'Build a new project space',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Start lightweight and keep planning inside the same flow.',
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: Color(0xE6FFFFFF),
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: onAddProject,
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF5F33E1),
                      ),
                      child: const Text('Add Project'),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 78,
                height: 78,
                decoration: const BoxDecoration(
                  color: Color(0x26FFFFFF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.layers_outlined,
                  color: Colors.white,
                  size: 38,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        _SectionHeader(count: projects.length),
        const SizedBox(height: 16),
        for (final project in projects) ...[
          Dismissible(
            key: Key(project.id),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) {
              ref.read(projectsProvider.notifier).deleteProject(project.id);
            },
            child: TaskGroupTile(
              title: project.name,
              subtitle: project.subtitle,
              progressLabel: project.progressLabel,
              icon: project.icon,
              iconBackground: project.iconBackground,
              accentColor: project.accentColor,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text(
          'Active Spaces',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w600),
        ),
        const SizedBox(width: 8),
        Container(
          width: 18,
          height: 18,
          decoration: const BoxDecoration(
            color: Color(0xFFEDE4FF),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$count',
            style: const TextStyle(fontSize: 11, color: Color(0xFF5F33E1)),
          ),
        ),
      ],
    );
  }
}
