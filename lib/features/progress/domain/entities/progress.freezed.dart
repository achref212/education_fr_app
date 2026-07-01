// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'progress.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$Progress {
  List<String> get lessonsCompleted => throw _privateConstructorUsedError;
  Map<String, List<int>> get quizScores => throw _privateConstructorUsedError;
  Map<String, List<int>> get exerciseScores =>
      throw _privateConstructorUsedError;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ProgressCopyWith<Progress> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ProgressCopyWith<$Res> {
  factory $ProgressCopyWith(Progress value, $Res Function(Progress) then) =
      _$ProgressCopyWithImpl<$Res, Progress>;
  @useResult
  $Res call(
      {List<String> lessonsCompleted,
      Map<String, List<int>> quizScores,
      Map<String, List<int>> exerciseScores});
}

/// @nodoc
class _$ProgressCopyWithImpl<$Res, $Val extends Progress>
    implements $ProgressCopyWith<$Res> {
  _$ProgressCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lessonsCompleted = null,
    Object? quizScores = null,
    Object? exerciseScores = null,
  }) {
    return _then(_value.copyWith(
      lessonsCompleted: null == lessonsCompleted
          ? _value.lessonsCompleted
          : lessonsCompleted // ignore: cast_nullable_to_non_nullable
              as List<String>,
      quizScores: null == quizScores
          ? _value.quizScores
          : quizScores // ignore: cast_nullable_to_non_nullable
              as Map<String, List<int>>,
      exerciseScores: null == exerciseScores
          ? _value.exerciseScores
          : exerciseScores // ignore: cast_nullable_to_non_nullable
              as Map<String, List<int>>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ProgressImplCopyWith<$Res>
    implements $ProgressCopyWith<$Res> {
  factory _$$ProgressImplCopyWith(
          _$ProgressImpl value, $Res Function(_$ProgressImpl) then) =
      __$$ProgressImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<String> lessonsCompleted,
      Map<String, List<int>> quizScores,
      Map<String, List<int>> exerciseScores});
}

/// @nodoc
class __$$ProgressImplCopyWithImpl<$Res>
    extends _$ProgressCopyWithImpl<$Res, _$ProgressImpl>
    implements _$$ProgressImplCopyWith<$Res> {
  __$$ProgressImplCopyWithImpl(
      _$ProgressImpl _value, $Res Function(_$ProgressImpl) _then)
      : super(_value, _then);

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? lessonsCompleted = null,
    Object? quizScores = null,
    Object? exerciseScores = null,
  }) {
    return _then(_$ProgressImpl(
      lessonsCompleted: null == lessonsCompleted
          ? _value._lessonsCompleted
          : lessonsCompleted // ignore: cast_nullable_to_non_nullable
              as List<String>,
      quizScores: null == quizScores
          ? _value._quizScores
          : quizScores // ignore: cast_nullable_to_non_nullable
              as Map<String, List<int>>,
      exerciseScores: null == exerciseScores
          ? _value._exerciseScores
          : exerciseScores // ignore: cast_nullable_to_non_nullable
              as Map<String, List<int>>,
    ));
  }
}

/// @nodoc

class _$ProgressImpl extends _Progress {
  const _$ProgressImpl(
      {final List<String> lessonsCompleted = const [],
      final Map<String, List<int>> quizScores = const {},
      final Map<String, List<int>> exerciseScores = const {}})
      : _lessonsCompleted = lessonsCompleted,
        _quizScores = quizScores,
        _exerciseScores = exerciseScores,
        super._();

  final List<String> _lessonsCompleted;
  @override
  @JsonKey()
  List<String> get lessonsCompleted {
    if (_lessonsCompleted is EqualUnmodifiableListView)
      return _lessonsCompleted;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_lessonsCompleted);
  }

  final Map<String, List<int>> _quizScores;
  @override
  @JsonKey()
  Map<String, List<int>> get quizScores {
    if (_quizScores is EqualUnmodifiableMapView) return _quizScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_quizScores);
  }

  final Map<String, List<int>> _exerciseScores;
  @override
  @JsonKey()
  Map<String, List<int>> get exerciseScores {
    if (_exerciseScores is EqualUnmodifiableMapView) return _exerciseScores;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_exerciseScores);
  }

  @override
  String toString() {
    return 'Progress(lessonsCompleted: $lessonsCompleted, quizScores: $quizScores, exerciseScores: $exerciseScores)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ProgressImpl &&
            const DeepCollectionEquality()
                .equals(other._lessonsCompleted, _lessonsCompleted) &&
            const DeepCollectionEquality()
                .equals(other._quizScores, _quizScores) &&
            const DeepCollectionEquality()
                .equals(other._exerciseScores, _exerciseScores));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_lessonsCompleted),
      const DeepCollectionEquality().hash(_quizScores),
      const DeepCollectionEquality().hash(_exerciseScores));

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ProgressImplCopyWith<_$ProgressImpl> get copyWith =>
      __$$ProgressImplCopyWithImpl<_$ProgressImpl>(this, _$identity);
}

abstract class _Progress extends Progress {
  const factory _Progress(
      {final List<String> lessonsCompleted,
      final Map<String, List<int>> quizScores,
      final Map<String, List<int>> exerciseScores}) = _$ProgressImpl;
  const _Progress._() : super._();

  @override
  List<String> get lessonsCompleted;
  @override
  Map<String, List<int>> get quizScores;
  @override
  Map<String, List<int>> get exerciseScores;

  /// Create a copy of Progress
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ProgressImplCopyWith<_$ProgressImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
