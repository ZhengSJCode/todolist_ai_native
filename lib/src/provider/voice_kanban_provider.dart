import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../api/voice_kanban_api_client.dart';
import '../api/voice_kanban_model.dart';

part 'voice_kanban_provider.g.dart';

@riverpod
VoiceKanbanApiClient voiceKanbanApiClient(VoiceKanbanApiClientRef ref) {
  return VoiceKanbanApiClient();
}

@riverpod
class VoiceKanbanItems extends _$VoiceKanbanItems {
  @override
  Future<List<ParsedItem>> build() async {
    return ref.read(voiceKanbanApiClientProvider).listItems();
  }

  Future<void> fetchItems({ParsedItemType? type}) async {
    state = const AsyncValue.loading();
    try {
      final items = await ref.read(voiceKanbanApiClientProvider).listItems(type: type);
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createEntry(String rawText, {String sourceType = 'text'}) async {
    await ref.read(voiceKanbanApiClientProvider).createEntry(
      rawText,
      sourceType: sourceType,
    );
    await fetchItems();
  }
}

@riverpod
class VoiceKanbanDrafts extends _$VoiceKanbanDrafts {
  @override
  AsyncValue<List<ParsedDraft>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> parse(String rawText) async {
    if (rawText.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    try {
      final drafts = await ref.read(voiceKanbanApiClientProvider).parse(rawText);
      state = AsyncValue.data(drafts);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
