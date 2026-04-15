// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_kanban_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voiceKanbanApiClientHash() =>
    r'b965d09fe1b5060a9d629126e03c9ce2c6d84111';

/// See also [voiceKanbanApiClient].
@ProviderFor(voiceKanbanApiClient)
final voiceKanbanApiClientProvider =
    AutoDisposeProvider<VoiceKanbanApiClient>.internal(
      voiceKanbanApiClient,
      name: r'voiceKanbanApiClientProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voiceKanbanApiClientHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoiceKanbanApiClientRef = AutoDisposeProviderRef<VoiceKanbanApiClient>;
String _$voiceKanbanItemsHash() => r'5aa2e372b6e3554121bd81b58452a10683ce9362';

/// See also [VoiceKanbanItems].
@ProviderFor(VoiceKanbanItems)
final voiceKanbanItemsProvider =
    AutoDisposeAsyncNotifierProvider<
      VoiceKanbanItems,
      List<ParsedItem>
    >.internal(
      VoiceKanbanItems.new,
      name: r'voiceKanbanItemsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voiceKanbanItemsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VoiceKanbanItems = AutoDisposeAsyncNotifier<List<ParsedItem>>;
String _$voiceKanbanDraftsHash() => r'24e78b6cd50e9831d0d297f21a145992e5941603';

/// See also [VoiceKanbanDrafts].
@ProviderFor(VoiceKanbanDrafts)
final voiceKanbanDraftsProvider =
    AutoDisposeNotifierProvider<
      VoiceKanbanDrafts,
      AsyncValue<List<ParsedDraft>>
    >.internal(
      VoiceKanbanDrafts.new,
      name: r'voiceKanbanDraftsProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voiceKanbanDraftsHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VoiceKanbanDrafts =
    AutoDisposeNotifier<AsyncValue<List<ParsedDraft>>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
