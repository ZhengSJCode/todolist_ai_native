// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todoRepositoryHash() => r'4b4b3423e828a7df0ef2758fb5d3b477a47b0bbf';

/// Provides the todo repository abstraction.
///
/// Copied from [todoRepository].
@ProviderFor(todoRepository)
final todoRepositoryProvider = AutoDisposeProvider<TodoRepository>.internal(
  todoRepository,
  name: r'todoRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todoRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodoRepositoryRef = AutoDisposeProviderRef<TodoRepository>;
String _$currentProjectIdHash() => r'07bebd4b6eee9766bbe17ba8047e248ae9f4fcee';

/// Provider for tracking the currently selected project ID.
/// Returns null when no project is selected (show all todos).
///
/// Copied from [currentProjectId].
@ProviderFor(currentProjectId)
final currentProjectIdProvider = AutoDisposeProvider<String?>.internal(
  currentProjectId,
  name: r'currentProjectIdProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentProjectIdHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentProjectIdRef = AutoDisposeProviderRef<String?>;
String _$todoListHash() => r'2700ccd275220085909070591db129a243204b11';

/// AsyncNotifier that owns the todo list state.
///
/// Copied from [TodoList].
@ProviderFor(TodoList)
final todoListProvider =
    AutoDisposeAsyncNotifierProvider<TodoList, List<TodoModel>>.internal(
      TodoList.new,
      name: r'todoListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$todoListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$TodoList = AutoDisposeAsyncNotifier<List<TodoModel>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
