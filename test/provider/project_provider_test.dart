import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todolist_ai_native/src/provider/project_provider.dart';

void main() {
  group('ProjectsNotifier', () {
    group('updateProject', () {
      test('updates project name when provided', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(projectsProvider.notifier);

        // Add a project first
        notifier.addProject(name: 'Original Name', accentColor: Colors.blue);

        final projects = container.read(projectsProvider);
        final projectId = projects.first.id;

        // Update
        notifier.updateProject(id: projectId, name: 'Updated Name');

        final updated = container.read(projectsProvider);
        expect(updated.first.name, 'Updated Name');
      });

      test('updates project accent color when provided', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(projectsProvider.notifier);

        notifier.addProject(name: 'Test', accentColor: Colors.blue);
        final projectId = container.read(projectsProvider).first.id;

        final newColor = Colors.red;
        notifier.updateProject(id: projectId, accentColor: newColor);

        final updated = container.read(projectsProvider);
        expect(updated.first.accentColor, newColor);
      });

      test('updates both name and color', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(projectsProvider.notifier);

        notifier.addProject(name: 'Original', accentColor: Colors.blue);
        final projectId = container.read(projectsProvider).first.id;

        notifier.updateProject(
          id: projectId,
          name: 'Updated',
          accentColor: Colors.green,
        );

        final updated = container.read(projectsProvider);
        expect(updated.first.name, 'Updated');
        expect(updated.first.accentColor, Colors.green);
      });

      test('does nothing when project id not found', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(projectsProvider.notifier);

        notifier.addProject(name: 'Test', accentColor: Colors.blue);

        // Try to update with non-existent ID
        notifier.updateProject(id: 'non-existent-id', name: 'New Name');

        final projects = container.read(projectsProvider);
        // Should have 5 projects: 4 initial + 1 newly added
        expect(projects, hasLength(5));
        // Find the 'Test' project and verify it hasn't changed
        final testProject = projects.firstWhere((p) => p.name == 'Test');
        expect(testProject.name, 'Test');
      });
    });

    group('deleteProject', () {
      test('removes project by id', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(projectsProvider.notifier);

        notifier.addProject(name: 'Project 1', accentColor: Colors.blue);
        notifier.addProject(name: 'Project 2', accentColor: Colors.red);

        final projects = container.read(projectsProvider);
        // Should have 6 projects: 4 initial + 2 newly added
        expect(projects, hasLength(6));

        final projectId = projects[4].id; // The first added project (Project 1)

        notifier.deleteProject(projectId);

        final remaining = container.read(projectsProvider);
        expect(remaining, hasLength(5));
        // The remaining projects should not include 'Project 1'
        expect(remaining.any((p) => p.name == 'Project 1'), isFalse);
      });

      test('handles deleting non-existent id gracefully', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(projectsProvider.notifier);

        notifier.addProject(name: 'Test', accentColor: Colors.blue);

        // Delete with non-existent ID should not throw
        notifier.deleteProject('non-existent-id');

        final projects = container.read(projectsProvider);
        // Should still have 5 projects: 4 initial + 1 newly added
        expect(projects, hasLength(5));
      });

      test('removes all projects when multiple deleted', () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(projectsProvider.notifier);

        notifier.addProject(name: 'P1', accentColor: Colors.blue);
        final p1Id = container.read(projectsProvider)[4].id;
        notifier.addProject(name: 'P2', accentColor: Colors.red);
        final p2Id = container.read(projectsProvider)[5].id;
        notifier.addProject(name: 'P3', accentColor: Colors.green);
        final p3Id = container.read(projectsProvider)[6].id;

        notifier.deleteProject(p1Id);
        expect(container.read(projectsProvider), hasLength(6));

        notifier.deleteProject(p2Id);
        expect(container.read(projectsProvider), hasLength(5));

        notifier.deleteProject(p3Id);
        expect(container.read(projectsProvider), hasLength(4));
      });
    });
  });
}
