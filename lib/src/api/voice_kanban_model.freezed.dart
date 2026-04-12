// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'voice_kanban_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

ParsedDraft _$ParsedDraftFromJson(Map<String, dynamic> json) {
  return _ParsedDraft.fromJson(json);
}

/// @nodoc
mixin _$ParsedDraft {
  ParsedItemType get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  num? get value => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;

  /// Serializes this ParsedDraft to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParsedDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParsedDraftCopyWith<ParsedDraft> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParsedDraftCopyWith<$Res> {
  factory $ParsedDraftCopyWith(
    ParsedDraft value,
    $Res Function(ParsedDraft) then,
  ) = _$ParsedDraftCopyWithImpl<$Res, ParsedDraft>;
  @useResult
  $Res call({
    ParsedItemType type,
    String content,
    String? title,
    num? value,
    String? unit,
  });
}

/// @nodoc
class _$ParsedDraftCopyWithImpl<$Res, $Val extends ParsedDraft>
    implements $ParsedDraftCopyWith<$Res> {
  _$ParsedDraftCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParsedDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? content = null,
    Object? title = freezed,
    Object? value = freezed,
    Object? unit = freezed,
  }) {
    return _then(
      _value.copyWith(
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ParsedItemType,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as num?,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParsedDraftImplCopyWith<$Res>
    implements $ParsedDraftCopyWith<$Res> {
  factory _$$ParsedDraftImplCopyWith(
    _$ParsedDraftImpl value,
    $Res Function(_$ParsedDraftImpl) then,
  ) = __$$ParsedDraftImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    ParsedItemType type,
    String content,
    String? title,
    num? value,
    String? unit,
  });
}

/// @nodoc
class __$$ParsedDraftImplCopyWithImpl<$Res>
    extends _$ParsedDraftCopyWithImpl<$Res, _$ParsedDraftImpl>
    implements _$$ParsedDraftImplCopyWith<$Res> {
  __$$ParsedDraftImplCopyWithImpl(
    _$ParsedDraftImpl _value,
    $Res Function(_$ParsedDraftImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParsedDraft
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? type = null,
    Object? content = null,
    Object? title = freezed,
    Object? value = freezed,
    Object? unit = freezed,
  }) {
    return _then(
      _$ParsedDraftImpl(
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ParsedItemType,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as num?,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParsedDraftImpl implements _ParsedDraft {
  const _$ParsedDraftImpl({
    required this.type,
    required this.content,
    this.title,
    this.value,
    this.unit,
  });

  factory _$ParsedDraftImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParsedDraftImplFromJson(json);

  @override
  final ParsedItemType type;
  @override
  final String content;
  @override
  final String? title;
  @override
  final num? value;
  @override
  final String? unit;

  @override
  String toString() {
    return 'ParsedDraft(type: $type, content: $content, title: $title, value: $value, unit: $unit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParsedDraftImpl &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, type, content, title, value, unit);

  /// Create a copy of ParsedDraft
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParsedDraftImplCopyWith<_$ParsedDraftImpl> get copyWith =>
      __$$ParsedDraftImplCopyWithImpl<_$ParsedDraftImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParsedDraftImplToJson(this);
  }
}

abstract class _ParsedDraft implements ParsedDraft {
  const factory _ParsedDraft({
    required final ParsedItemType type,
    required final String content,
    final String? title,
    final num? value,
    final String? unit,
  }) = _$ParsedDraftImpl;

  factory _ParsedDraft.fromJson(Map<String, dynamic> json) =
      _$ParsedDraftImpl.fromJson;

  @override
  ParsedItemType get type;
  @override
  String get content;
  @override
  String? get title;
  @override
  num? get value;
  @override
  String? get unit;

  /// Create a copy of ParsedDraft
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParsedDraftImplCopyWith<_$ParsedDraftImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RawEntry _$RawEntryFromJson(Map<String, dynamic> json) {
  return _RawEntry.fromJson(json);
}

/// @nodoc
mixin _$RawEntry {
  String get id => throw _privateConstructorUsedError;
  String get sourceType => throw _privateConstructorUsedError;
  String get rawText => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this RawEntry to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of RawEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $RawEntryCopyWith<RawEntry> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RawEntryCopyWith<$Res> {
  factory $RawEntryCopyWith(RawEntry value, $Res Function(RawEntry) then) =
      _$RawEntryCopyWithImpl<$Res, RawEntry>;
  @useResult
  $Res call({String id, String sourceType, String rawText, DateTime createdAt});
}

/// @nodoc
class _$RawEntryCopyWithImpl<$Res, $Val extends RawEntry>
    implements $RawEntryCopyWith<$Res> {
  _$RawEntryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of RawEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceType = null,
    Object? rawText = null,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            sourceType: null == sourceType
                ? _value.sourceType
                : sourceType // ignore: cast_nullable_to_non_nullable
                      as String,
            rawText: null == rawText
                ? _value.rawText
                : rawText // ignore: cast_nullable_to_non_nullable
                      as String,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$RawEntryImplCopyWith<$Res>
    implements $RawEntryCopyWith<$Res> {
  factory _$$RawEntryImplCopyWith(
    _$RawEntryImpl value,
    $Res Function(_$RawEntryImpl) then,
  ) = __$$RawEntryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String id, String sourceType, String rawText, DateTime createdAt});
}

/// @nodoc
class __$$RawEntryImplCopyWithImpl<$Res>
    extends _$RawEntryCopyWithImpl<$Res, _$RawEntryImpl>
    implements _$$RawEntryImplCopyWith<$Res> {
  __$$RawEntryImplCopyWithImpl(
    _$RawEntryImpl _value,
    $Res Function(_$RawEntryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of RawEntry
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? sourceType = null,
    Object? rawText = null,
    Object? createdAt = null,
  }) {
    return _then(
      _$RawEntryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        sourceType: null == sourceType
            ? _value.sourceType
            : sourceType // ignore: cast_nullable_to_non_nullable
                  as String,
        rawText: null == rawText
            ? _value.rawText
            : rawText // ignore: cast_nullable_to_non_nullable
                  as String,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$RawEntryImpl implements _RawEntry {
  const _$RawEntryImpl({
    required this.id,
    required this.sourceType,
    required this.rawText,
    required this.createdAt,
  });

  factory _$RawEntryImpl.fromJson(Map<String, dynamic> json) =>
      _$$RawEntryImplFromJson(json);

  @override
  final String id;
  @override
  final String sourceType;
  @override
  final String rawText;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'RawEntry(id: $id, sourceType: $sourceType, rawText: $rawText, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RawEntryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.sourceType, sourceType) ||
                other.sourceType == sourceType) &&
            (identical(other.rawText, rawText) || other.rawText == rawText) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, sourceType, rawText, createdAt);

  /// Create a copy of RawEntry
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$RawEntryImplCopyWith<_$RawEntryImpl> get copyWith =>
      __$$RawEntryImplCopyWithImpl<_$RawEntryImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RawEntryImplToJson(this);
  }
}

abstract class _RawEntry implements RawEntry {
  const factory _RawEntry({
    required final String id,
    required final String sourceType,
    required final String rawText,
    required final DateTime createdAt,
  }) = _$RawEntryImpl;

  factory _RawEntry.fromJson(Map<String, dynamic> json) =
      _$RawEntryImpl.fromJson;

  @override
  String get id;
  @override
  String get sourceType;
  @override
  String get rawText;
  @override
  DateTime get createdAt;

  /// Create a copy of RawEntry
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$RawEntryImplCopyWith<_$RawEntryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

ParsedItem _$ParsedItemFromJson(Map<String, dynamic> json) {
  return _ParsedItem.fromJson(json);
}

/// @nodoc
mixin _$ParsedItem {
  String get id => throw _privateConstructorUsedError;
  String get rawEntryId => throw _privateConstructorUsedError;
  ParsedItemType get type => throw _privateConstructorUsedError;
  String get content => throw _privateConstructorUsedError;
  String? get title => throw _privateConstructorUsedError;
  num? get value => throw _privateConstructorUsedError;
  String? get unit => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ParsedItem to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ParsedItemCopyWith<ParsedItem> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ParsedItemCopyWith<$Res> {
  factory $ParsedItemCopyWith(
    ParsedItem value,
    $Res Function(ParsedItem) then,
  ) = _$ParsedItemCopyWithImpl<$Res, ParsedItem>;
  @useResult
  $Res call({
    String id,
    String rawEntryId,
    ParsedItemType type,
    String content,
    String? title,
    num? value,
    String? unit,
    DateTime createdAt,
  });
}

/// @nodoc
class _$ParsedItemCopyWithImpl<$Res, $Val extends ParsedItem>
    implements $ParsedItemCopyWith<$Res> {
  _$ParsedItemCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rawEntryId = null,
    Object? type = null,
    Object? content = null,
    Object? title = freezed,
    Object? value = freezed,
    Object? unit = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            rawEntryId: null == rawEntryId
                ? _value.rawEntryId
                : rawEntryId // ignore: cast_nullable_to_non_nullable
                      as String,
            type: null == type
                ? _value.type
                : type // ignore: cast_nullable_to_non_nullable
                      as ParsedItemType,
            content: null == content
                ? _value.content
                : content // ignore: cast_nullable_to_non_nullable
                      as String,
            title: freezed == title
                ? _value.title
                : title // ignore: cast_nullable_to_non_nullable
                      as String?,
            value: freezed == value
                ? _value.value
                : value // ignore: cast_nullable_to_non_nullable
                      as num?,
            unit: freezed == unit
                ? _value.unit
                : unit // ignore: cast_nullable_to_non_nullable
                      as String?,
            createdAt: null == createdAt
                ? _value.createdAt
                : createdAt // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ParsedItemImplCopyWith<$Res>
    implements $ParsedItemCopyWith<$Res> {
  factory _$$ParsedItemImplCopyWith(
    _$ParsedItemImpl value,
    $Res Function(_$ParsedItemImpl) then,
  ) = __$$ParsedItemImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String rawEntryId,
    ParsedItemType type,
    String content,
    String? title,
    num? value,
    String? unit,
    DateTime createdAt,
  });
}

/// @nodoc
class __$$ParsedItemImplCopyWithImpl<$Res>
    extends _$ParsedItemCopyWithImpl<$Res, _$ParsedItemImpl>
    implements _$$ParsedItemImplCopyWith<$Res> {
  __$$ParsedItemImplCopyWithImpl(
    _$ParsedItemImpl _value,
    $Res Function(_$ParsedItemImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? rawEntryId = null,
    Object? type = null,
    Object? content = null,
    Object? title = freezed,
    Object? value = freezed,
    Object? unit = freezed,
    Object? createdAt = null,
  }) {
    return _then(
      _$ParsedItemImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        rawEntryId: null == rawEntryId
            ? _value.rawEntryId
            : rawEntryId // ignore: cast_nullable_to_non_nullable
                  as String,
        type: null == type
            ? _value.type
            : type // ignore: cast_nullable_to_non_nullable
                  as ParsedItemType,
        content: null == content
            ? _value.content
            : content // ignore: cast_nullable_to_non_nullable
                  as String,
        title: freezed == title
            ? _value.title
            : title // ignore: cast_nullable_to_non_nullable
                  as String?,
        value: freezed == value
            ? _value.value
            : value // ignore: cast_nullable_to_non_nullable
                  as num?,
        unit: freezed == unit
            ? _value.unit
            : unit // ignore: cast_nullable_to_non_nullable
                  as String?,
        createdAt: null == createdAt
            ? _value.createdAt
            : createdAt // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$ParsedItemImpl implements _ParsedItem {
  const _$ParsedItemImpl({
    required this.id,
    required this.rawEntryId,
    required this.type,
    required this.content,
    this.title,
    this.value,
    this.unit,
    required this.createdAt,
  });

  factory _$ParsedItemImpl.fromJson(Map<String, dynamic> json) =>
      _$$ParsedItemImplFromJson(json);

  @override
  final String id;
  @override
  final String rawEntryId;
  @override
  final ParsedItemType type;
  @override
  final String content;
  @override
  final String? title;
  @override
  final num? value;
  @override
  final String? unit;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'ParsedItem(id: $id, rawEntryId: $rawEntryId, type: $type, content: $content, title: $title, value: $value, unit: $unit, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ParsedItemImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.rawEntryId, rawEntryId) ||
                other.rawEntryId == rawEntryId) &&
            (identical(other.type, type) || other.type == type) &&
            (identical(other.content, content) || other.content == content) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.unit, unit) || other.unit == unit) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    rawEntryId,
    type,
    content,
    title,
    value,
    unit,
    createdAt,
  );

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ParsedItemImplCopyWith<_$ParsedItemImpl> get copyWith =>
      __$$ParsedItemImplCopyWithImpl<_$ParsedItemImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ParsedItemImplToJson(this);
  }
}

abstract class _ParsedItem implements ParsedItem {
  const factory _ParsedItem({
    required final String id,
    required final String rawEntryId,
    required final ParsedItemType type,
    required final String content,
    final String? title,
    final num? value,
    final String? unit,
    required final DateTime createdAt,
  }) = _$ParsedItemImpl;

  factory _ParsedItem.fromJson(Map<String, dynamic> json) =
      _$ParsedItemImpl.fromJson;

  @override
  String get id;
  @override
  String get rawEntryId;
  @override
  ParsedItemType get type;
  @override
  String get content;
  @override
  String? get title;
  @override
  num? get value;
  @override
  String? get unit;
  @override
  DateTime get createdAt;

  /// Create a copy of ParsedItem
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ParsedItemImplCopyWith<_$ParsedItemImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

CreateEntryResponse _$CreateEntryResponseFromJson(Map<String, dynamic> json) {
  return _CreateEntryResponse.fromJson(json);
}

/// @nodoc
mixin _$CreateEntryResponse {
  RawEntry get rawEntry => throw _privateConstructorUsedError;
  List<ParsedItem> get items => throw _privateConstructorUsedError;

  /// Serializes this CreateEntryResponse to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of CreateEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CreateEntryResponseCopyWith<CreateEntryResponse> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CreateEntryResponseCopyWith<$Res> {
  factory $CreateEntryResponseCopyWith(
    CreateEntryResponse value,
    $Res Function(CreateEntryResponse) then,
  ) = _$CreateEntryResponseCopyWithImpl<$Res, CreateEntryResponse>;
  @useResult
  $Res call({RawEntry rawEntry, List<ParsedItem> items});

  $RawEntryCopyWith<$Res> get rawEntry;
}

/// @nodoc
class _$CreateEntryResponseCopyWithImpl<$Res, $Val extends CreateEntryResponse>
    implements $CreateEntryResponseCopyWith<$Res> {
  _$CreateEntryResponseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of CreateEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rawEntry = null, Object? items = null}) {
    return _then(
      _value.copyWith(
            rawEntry: null == rawEntry
                ? _value.rawEntry
                : rawEntry // ignore: cast_nullable_to_non_nullable
                      as RawEntry,
            items: null == items
                ? _value.items
                : items // ignore: cast_nullable_to_non_nullable
                      as List<ParsedItem>,
          )
          as $Val,
    );
  }

  /// Create a copy of CreateEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $RawEntryCopyWith<$Res> get rawEntry {
    return $RawEntryCopyWith<$Res>(_value.rawEntry, (value) {
      return _then(_value.copyWith(rawEntry: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$CreateEntryResponseImplCopyWith<$Res>
    implements $CreateEntryResponseCopyWith<$Res> {
  factory _$$CreateEntryResponseImplCopyWith(
    _$CreateEntryResponseImpl value,
    $Res Function(_$CreateEntryResponseImpl) then,
  ) = __$$CreateEntryResponseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({RawEntry rawEntry, List<ParsedItem> items});

  @override
  $RawEntryCopyWith<$Res> get rawEntry;
}

/// @nodoc
class __$$CreateEntryResponseImplCopyWithImpl<$Res>
    extends _$CreateEntryResponseCopyWithImpl<$Res, _$CreateEntryResponseImpl>
    implements _$$CreateEntryResponseImplCopyWith<$Res> {
  __$$CreateEntryResponseImplCopyWithImpl(
    _$CreateEntryResponseImpl _value,
    $Res Function(_$CreateEntryResponseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of CreateEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? rawEntry = null, Object? items = null}) {
    return _then(
      _$CreateEntryResponseImpl(
        rawEntry: null == rawEntry
            ? _value.rawEntry
            : rawEntry // ignore: cast_nullable_to_non_nullable
                  as RawEntry,
        items: null == items
            ? _value._items
            : items // ignore: cast_nullable_to_non_nullable
                  as List<ParsedItem>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CreateEntryResponseImpl implements _CreateEntryResponse {
  const _$CreateEntryResponseImpl({
    required this.rawEntry,
    required final List<ParsedItem> items,
  }) : _items = items;

  factory _$CreateEntryResponseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CreateEntryResponseImplFromJson(json);

  @override
  final RawEntry rawEntry;
  final List<ParsedItem> _items;
  @override
  List<ParsedItem> get items {
    if (_items is EqualUnmodifiableListView) return _items;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_items);
  }

  @override
  String toString() {
    return 'CreateEntryResponse(rawEntry: $rawEntry, items: $items)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CreateEntryResponseImpl &&
            (identical(other.rawEntry, rawEntry) ||
                other.rawEntry == rawEntry) &&
            const DeepCollectionEquality().equals(other._items, _items));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    rawEntry,
    const DeepCollectionEquality().hash(_items),
  );

  /// Create a copy of CreateEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CreateEntryResponseImplCopyWith<_$CreateEntryResponseImpl> get copyWith =>
      __$$CreateEntryResponseImplCopyWithImpl<_$CreateEntryResponseImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$CreateEntryResponseImplToJson(this);
  }
}

abstract class _CreateEntryResponse implements CreateEntryResponse {
  const factory _CreateEntryResponse({
    required final RawEntry rawEntry,
    required final List<ParsedItem> items,
  }) = _$CreateEntryResponseImpl;

  factory _CreateEntryResponse.fromJson(Map<String, dynamic> json) =
      _$CreateEntryResponseImpl.fromJson;

  @override
  RawEntry get rawEntry;
  @override
  List<ParsedItem> get items;

  /// Create a copy of CreateEntryResponse
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CreateEntryResponseImplCopyWith<_$CreateEntryResponseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
