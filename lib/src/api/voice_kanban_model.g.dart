// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'voice_kanban_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ParsedDraftImpl _$$ParsedDraftImplFromJson(Map<String, dynamic> json) =>
    _$ParsedDraftImpl(
      type: $enumDecode(_$ParsedItemTypeEnumMap, json['type']),
      content: json['content'] as String,
      title: json['title'] as String?,
      value: json['value'] as num?,
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$$ParsedDraftImplToJson(_$ParsedDraftImpl instance) =>
    <String, dynamic>{
      'type': _$ParsedItemTypeEnumMap[instance.type]!,
      'content': instance.content,
      'title': instance.title,
      'value': instance.value,
      'unit': instance.unit,
    };

const _$ParsedItemTypeEnumMap = {
  ParsedItemType.task: 'task',
  ParsedItemType.metric: 'metric',
  ParsedItemType.note: 'note',
};

_$RawEntryImpl _$$RawEntryImplFromJson(Map<String, dynamic> json) =>
    _$RawEntryImpl(
      id: json['id'] as String,
      sourceType: json['sourceType'] as String,
      rawText: json['rawText'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$RawEntryImplToJson(_$RawEntryImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'sourceType': instance.sourceType,
      'rawText': instance.rawText,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$ParsedItemImpl _$$ParsedItemImplFromJson(Map<String, dynamic> json) =>
    _$ParsedItemImpl(
      id: json['id'] as String,
      rawEntryId: json['rawEntryId'] as String,
      type: $enumDecode(_$ParsedItemTypeEnumMap, json['type']),
      content: json['content'] as String,
      title: json['title'] as String?,
      value: json['value'] as num?,
      unit: json['unit'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$$ParsedItemImplToJson(_$ParsedItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'rawEntryId': instance.rawEntryId,
      'type': _$ParsedItemTypeEnumMap[instance.type]!,
      'content': instance.content,
      'title': instance.title,
      'value': instance.value,
      'unit': instance.unit,
      'createdAt': instance.createdAt.toIso8601String(),
    };

_$CreateEntryResponseImpl _$$CreateEntryResponseImplFromJson(
  Map<String, dynamic> json,
) => _$CreateEntryResponseImpl(
  rawEntry: RawEntry.fromJson(json['rawEntry'] as Map<String, dynamic>),
  items: (json['items'] as List<dynamic>)
      .map((e) => ParsedItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$$CreateEntryResponseImplToJson(
  _$CreateEntryResponseImpl instance,
) => <String, dynamic>{'rawEntry': instance.rawEntry, 'items': instance.items};
