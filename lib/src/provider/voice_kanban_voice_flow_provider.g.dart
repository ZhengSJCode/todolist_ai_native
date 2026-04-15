// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_kanban_voice_flow_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$voiceAudioRecorderHash() =>
    r'8587ce605ca88f3faca9d3b629e21200d1bfafe4';

/// See also [voiceAudioRecorder].
@ProviderFor(voiceAudioRecorder)
final voiceAudioRecorderProvider = Provider<VoiceAudioRecorder>.internal(
  voiceAudioRecorder,
  name: r'voiceAudioRecorderProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$voiceAudioRecorderHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoiceAudioRecorderRef = ProviderRef<VoiceAudioRecorder>;
String _$voiceTranscriptionClientHash() =>
    r'd2a30dafd9dbf63ec7fe31c6b7df6b21b5963e35';

/// See also [voiceTranscriptionClient].
@ProviderFor(voiceTranscriptionClient)
final voiceTranscriptionClientProvider =
    AutoDisposeProvider<VoiceTranscriptionClient>.internal(
      voiceTranscriptionClient,
      name: r'voiceTranscriptionClientProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voiceTranscriptionClientHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef VoiceTranscriptionClientRef =
    AutoDisposeProviderRef<VoiceTranscriptionClient>;
String _$voiceKanbanVoiceFlowHash() =>
    r'22fbcaa6cfdf6caed4946d4052194f99d4bb7c0b';

/// See also [VoiceKanbanVoiceFlow].
@ProviderFor(VoiceKanbanVoiceFlow)
final voiceKanbanVoiceFlowProvider =
    AutoDisposeNotifierProvider<
      VoiceKanbanVoiceFlow,
      VoiceCaptureState
    >.internal(
      VoiceKanbanVoiceFlow.new,
      name: r'voiceKanbanVoiceFlowProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$voiceKanbanVoiceFlowHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$VoiceKanbanVoiceFlow = AutoDisposeNotifier<VoiceCaptureState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
