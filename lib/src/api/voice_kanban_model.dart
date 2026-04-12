import 'package:freezed_annotation/freezed_annotation.dart';

part 'voice_kanban_model.freezed.dart';
part 'voice_kanban_model.g.dart';

enum ParsedItemType {
  task,
  metric,
  note,
}

@freezed
class ParsedDraft with _$ParsedDraft {
  const factory ParsedDraft({
    required ParsedItemType type,
    required String content,
    String? title,
    num? value,
    String? unit,
  }) = _ParsedDraft;

  factory ParsedDraft.fromJson(Map<String, dynamic> json) =>
      _$ParsedDraftFromJson(json);
}

@freezed
class RawEntry with _$RawEntry {
  const factory RawEntry({
    required String id,
    required String sourceType,
    required String rawText,
    required DateTime createdAt,
  }) = _RawEntry;

  factory RawEntry.fromJson(Map<String, dynamic> json) =>
      _$RawEntryFromJson(json);
}

@freezed
class ParsedItem with _$ParsedItem {
  const factory ParsedItem({
    required String id,
    required String rawEntryId,
    required ParsedItemType type,
    required String content,
    String? title,
    num? value,
    String? unit,
    required DateTime createdAt,
  }) = _ParsedItem;

  factory ParsedItem.fromJson(Map<String, dynamic> json) =>
      _$ParsedItemFromJson(json);
}

@freezed
class CreateEntryResponse with _$CreateEntryResponse {
  const factory CreateEntryResponse({
    required RawEntry rawEntry,
    required List<ParsedItem> items,
  }) = _CreateEntryResponse;

  factory CreateEntryResponse.fromJson(Map<String, dynamic> json) =>
      _$CreateEntryResponseFromJson(json);
}