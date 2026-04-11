import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'project_provider.freezed.dart';

/// Freezed data class for a project item.
@freezed
class ProjectSummary with _$ProjectSummary {
  const factory ProjectSummary({
    required String id,
    required String name,
    required String tag,
    required int taskCount,
    required double progress,
    required Color accentColor,
    required Color backgroundColor,
    required Color iconBackground,
    required IconData icon,
  }) = _ProjectSummary;

  // No need for fromJson since we don't serialize projects in this version
}

extension ProjectSummaryExtension on ProjectSummary {
  String get progressLabel => '${(progress * 100).round()}%';
  String get subtitle => '$taskCount Tasks';
}

final projectsProvider =
    NotifierProvider<ProjectsNotifier, List<ProjectSummary>>(
      ProjectsNotifier.new,
    );

class ProjectsNotifier extends Notifier<List<ProjectSummary>> {
  static const _icons = [
    Icons.work_outline_rounded,
    Icons.sell_outlined,
    Icons.menu_book_outlined,
    Icons.wb_sunny_outlined,
    Icons.auto_awesome_rounded,
    Icons.palette_outlined,
  ];

  @override
  List<ProjectSummary> build() {
    return const [
      ProjectSummary(
        id: 'office-project',
        name: 'Grocery shopping app design',
        tag: 'Office Project',
        taskCount: 23,
        progress: 0.70,
        accentColor: Color(0xFF0087FF),
        backgroundColor: Color(0xFFE7F3FF),
        iconBackground: Color(0xFFFFE4F2),
        icon: Icons.work_outline_rounded,
      ),
      ProjectSummary(
        id: 'personal-project',
        name: 'Uber Eats redesign challange',
        tag: 'Personal Project',
        taskCount: 30,
        progress: 0.52,
        accentColor: Color(0xFFFF7D53),
        backgroundColor: Color(0xFFFFE9E1),
        iconBackground: Color(0xFFEDE4FF),
        icon: Icons.sell_outlined,
      ),
      ProjectSummary(
        id: 'daily-study',
        name: 'Daily Study',
        tag: 'Learning Goal',
        taskCount: 30,
        progress: 0.87,
        accentColor: Color(0xFFFF8A3D),
        backgroundColor: Color(0xFFFFF0E4),
        iconBackground: Color(0xFFFFE6D4),
        icon: Icons.menu_book_outlined,
      ),
      ProjectSummary(
        id: 'wellness',
        name: 'Wellness Routine',
        tag: 'Personal Care',
        taskCount: 3,
        progress: 0.32,
        accentColor: Color(0xFFF0C400),
        backgroundColor: Color(0xFFFFF9DE),
        iconBackground: Color(0xFFFFF6D4),
        icon: Icons.wb_sunny_outlined,
      ),
    ];
  }

  void addProject({required String name, required Color accentColor}) {
    final nextIndex = state.length;
    final icon = _icons[nextIndex % _icons.length];
    final normalized = name.trim();
    if (normalized.isEmpty) {
      return;
    }

    state = [
      ...state,
      ProjectSummary(
        id: 'project-$nextIndex-${normalized.toLowerCase().replaceAll(' ', '-')}',
        name: normalized,
        tag: 'New Project',
        taskCount: 0,
        progress: 0.12,
        accentColor: accentColor,
        backgroundColor: _soften(accentColor, 0.84),
        iconBackground: _soften(accentColor, 0.72),
        icon: icon,
      ),
    ];
  }

  void updateProject({
    required String id,
    String? name,
    Color? accentColor,
  }) {
    final normalized = name?.trim();
    if (normalized != null && normalized.isEmpty) {
      return;
    }

    state = state
        .map(
          (project) => project.id == id
              ? project.copyWith(
                  name: normalized ?? project.name,
                  accentColor: accentColor ?? project.accentColor,
                  backgroundColor: accentColor != null
                      ? _soften(accentColor, 0.84)
                      : project.backgroundColor,
                  iconBackground: accentColor != null
                      ? _soften(accentColor, 0.72)
                      : project.iconBackground,
                )
              : project,
        )
        .toList();
  }

  void deleteProject(String id) {
    state = state.where((project) => project.id != id).toList();
  }

  Color _soften(Color color, double factor) {
    return Color.lerp(color, Colors.white, factor)!;
  }
}
