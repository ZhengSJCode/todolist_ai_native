// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$ProjectSummary {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get tag => throw _privateConstructorUsedError;
  int get taskCount => throw _privateConstructorUsedError;
  double get progress => throw _privateConstructorUsedError;
  Color get accentColor => throw _privateConstructorUsedError;
  Color get backgroundColor => throw _privateConstructorUsedError;
  Color get iconBackground => throw _privateConstructorUsedError;
  IconData get icon => throw _privateConstructorUsedError;

  /// Create a copy of ProjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProjectSummaryCopyWith<ProjectSummary> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProjectSummaryCopyWith<$Res> {
  factory $ProjectSummaryCopyWith(
    ProjectSummary value,
    $Res Function(ProjectSummary) then,
  ) = _$ProjectSummaryCopyWithImpl<$Res, ProjectSummary>;
  @useResult
  $Res call({
    String id,
    String name,
    String tag,
    int taskCount,
    double progress,
    Color accentColor,
    Color backgroundColor,
    Color iconBackground,
    IconData icon,
  });
}

/// @nodoc
class _$ProjectSummaryCopyWithImpl<$Res, $Val extends ProjectSummary>
    implements $ProjectSummaryCopyWith<$Res> {
  _$ProjectSummaryCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ProjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tag = null,
    Object? taskCount = null,
    Object? progress = null,
    Object? accentColor = null,
    Object? backgroundColor = null,
    Object? iconBackground = null,
    Object? icon = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            tag: null == tag
                ? _value.tag
                : tag // ignore: cast_nullable_to_non_nullable
                      as String,
            taskCount: null == taskCount
                ? _value.taskCount
                : taskCount // ignore: cast_nullable_to_non_nullable
                      as int,
            progress: null == progress
                ? _value.progress
                : progress // ignore: cast_nullable_to_non_nullable
                      as double,
            accentColor: null == accentColor
                ? _value.accentColor
                : accentColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            backgroundColor: null == backgroundColor
                ? _value.backgroundColor
                : backgroundColor // ignore: cast_nullable_to_non_nullable
                      as Color,
            iconBackground: null == iconBackground
                ? _value.iconBackground
                : iconBackground // ignore: cast_nullable_to_non_nullable
                      as Color,
            icon: null == icon
                ? _value.icon
                : icon // ignore: cast_nullable_to_non_nullable
                      as IconData,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$ProjectSummaryImplCopyWith<$Res>
    implements $ProjectSummaryCopyWith<$Res> {
  factory _$$ProjectSummaryImplCopyWith(
    _$ProjectSummaryImpl value,
    $Res Function(_$ProjectSummaryImpl) then,
  ) = __$$ProjectSummaryImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String tag,
    int taskCount,
    double progress,
    Color accentColor,
    Color backgroundColor,
    Color iconBackground,
    IconData icon,
  });
}

/// @nodoc
class __$$ProjectSummaryImplCopyWithImpl<$Res>
    extends _$ProjectSummaryCopyWithImpl<$Res, _$ProjectSummaryImpl>
    implements _$$ProjectSummaryImplCopyWith<$Res> {
  __$$ProjectSummaryImplCopyWithImpl(
    _$ProjectSummaryImpl _value,
    $Res Function(_$ProjectSummaryImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of ProjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? tag = null,
    Object? taskCount = null,
    Object? progress = null,
    Object? accentColor = null,
    Object? backgroundColor = null,
    Object? iconBackground = null,
    Object? icon = null,
  }) {
    return _then(
      _$ProjectSummaryImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        tag: null == tag
            ? _value.tag
            : tag // ignore: cast_nullable_to_non_nullable
                  as String,
        taskCount: null == taskCount
            ? _value.taskCount
            : taskCount // ignore: cast_nullable_to_non_nullable
                  as int,
        progress: null == progress
            ? _value.progress
            : progress // ignore: cast_nullable_to_non_nullable
                  as double,
        accentColor: null == accentColor
            ? _value.accentColor
            : accentColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        backgroundColor: null == backgroundColor
            ? _value.backgroundColor
            : backgroundColor // ignore: cast_nullable_to_non_nullable
                  as Color,
        iconBackground: null == iconBackground
            ? _value.iconBackground
            : iconBackground // ignore: cast_nullable_to_non_nullable
                  as Color,
        icon: null == icon
            ? _value.icon
            : icon // ignore: cast_nullable_to_non_nullable
                  as IconData,
      ),
    );
  }
}

/// @nodoc

class _$ProjectSummaryImpl implements _ProjectSummary {
  const _$ProjectSummaryImpl({
    required this.id,
    required this.name,
    required this.tag,
    required this.taskCount,
    required this.progress,
    required this.accentColor,
    required this.backgroundColor,
    required this.iconBackground,
    required this.icon,
  });

  @override
  final String id;
  @override
  final String name;
  @override
  final String tag;
  @override
  final int taskCount;
  @override
  final double progress;
  @override
  final Color accentColor;
  @override
  final Color backgroundColor;
  @override
  final Color iconBackground;
  @override
  final IconData icon;

  @override
  String toString() {
    return 'ProjectSummary(id: $id, name: $name, tag: $tag, taskCount: $taskCount, progress: $progress, accentColor: $accentColor, backgroundColor: $backgroundColor, iconBackground: $iconBackground, icon: $icon)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProjectSummaryImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.tag, tag) || other.tag == tag) &&
            (identical(other.taskCount, taskCount) ||
                other.taskCount == taskCount) &&
            (identical(other.progress, progress) ||
                other.progress == progress) &&
            (identical(other.accentColor, accentColor) ||
                other.accentColor == accentColor) &&
            (identical(other.backgroundColor, backgroundColor) ||
                other.backgroundColor == backgroundColor) &&
            (identical(other.iconBackground, iconBackground) ||
                other.iconBackground == iconBackground) &&
            (identical(other.icon, icon) || other.icon == icon));
  }

  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    tag,
    taskCount,
    progress,
    accentColor,
    backgroundColor,
    iconBackground,
    icon,
  );

  /// Create a copy of ProjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProjectSummaryImplCopyWith<_$ProjectSummaryImpl> get copyWith =>
      __$$ProjectSummaryImplCopyWithImpl<_$ProjectSummaryImpl>(
        this,
        _$identity,
      );
}

abstract class _ProjectSummary implements ProjectSummary {
  const factory _ProjectSummary({
    required final String id,
    required final String name,
    required final String tag,
    required final int taskCount,
    required final double progress,
    required final Color accentColor,
    required final Color backgroundColor,
    required final Color iconBackground,
    required final IconData icon,
  }) = _$ProjectSummaryImpl;

  @override
  String get id;
  @override
  String get name;
  @override
  String get tag;
  @override
  int get taskCount;
  @override
  double get progress;
  @override
  Color get accentColor;
  @override
  Color get backgroundColor;
  @override
  Color get iconBackground;
  @override
  IconData get icon;

  /// Create a copy of ProjectSummary
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProjectSummaryImplCopyWith<_$ProjectSummaryImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
