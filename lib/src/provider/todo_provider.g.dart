// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todoRepositoryHash() => r'b8fe7d5689c17b5d507ea2e2aeb97cb9ebf0d00e';

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
String _$todoListHash() => r'01a23ce0cb97ab9e2a5f8d72a948ac76c4f12d59';

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
