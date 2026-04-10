// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$todoApiClientHash() => r'4802523570a52697c0aed6eb022096bab17146a2';

/// Provides the singleton [TodoApiClient].
///
/// Copied from [todoApiClient].
@ProviderFor(todoApiClient)
final todoApiClientProvider = AutoDisposeProvider<TodoApiClient>.internal(
  todoApiClient,
  name: r'todoApiClientProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$todoApiClientHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef TodoApiClientRef = AutoDisposeProviderRef<TodoApiClient>;
String _$todoListHash() => r'78f7e2287c6fd9ce53044d9cdfe28bcd23f8af9a';

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
