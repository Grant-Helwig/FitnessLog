// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'workout_history_bloc.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$WorkoutHistoryEvent {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTimeRange initialDateRange, Workout? workout)
        started,
    required TResult Function(DateTimeRange dateRange) updateDateRange,
    required TResult Function(Routine routine) updateRoutine,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTimeRange initialDateRange, Workout? workout)?
        started,
    TResult? Function(DateTimeRange dateRange)? updateDateRange,
    TResult? Function(Routine routine)? updateRoutine,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTimeRange initialDateRange, Workout? workout)? started,
    TResult Function(DateTimeRange dateRange)? updateDateRange,
    TResult Function(Routine routine)? updateRoutine,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(UpdateDateRange value) updateDateRange,
    required TResult Function(UpdateRoutine value) updateRoutine,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(UpdateDateRange value)? updateDateRange,
    TResult? Function(UpdateRoutine value)? updateRoutine,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(UpdateDateRange value)? updateDateRange,
    TResult Function(UpdateRoutine value)? updateRoutine,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutHistoryEventCopyWith<$Res> {
  factory $WorkoutHistoryEventCopyWith(
          WorkoutHistoryEvent value, $Res Function(WorkoutHistoryEvent) then) =
      _$WorkoutHistoryEventCopyWithImpl<$Res, WorkoutHistoryEvent>;
}

/// @nodoc
class _$WorkoutHistoryEventCopyWithImpl<$Res, $Val extends WorkoutHistoryEvent>
    implements $WorkoutHistoryEventCopyWith<$Res> {
  _$WorkoutHistoryEventCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$_StartedCopyWith<$Res> {
  factory _$$_StartedCopyWith(
          _$_Started value, $Res Function(_$_Started) then) =
      __$$_StartedCopyWithImpl<$Res>;
  @useResult
  $Res call({DateTimeRange initialDateRange, Workout? workout});
}

/// @nodoc
class __$$_StartedCopyWithImpl<$Res>
    extends _$WorkoutHistoryEventCopyWithImpl<$Res, _$_Started>
    implements _$$_StartedCopyWith<$Res> {
  __$$_StartedCopyWithImpl(_$_Started _value, $Res Function(_$_Started) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? initialDateRange = null,
    Object? workout = freezed,
  }) {
    return _then(_$_Started(
      null == initialDateRange
          ? _value.initialDateRange
          : initialDateRange // ignore: cast_nullable_to_non_nullable
              as DateTimeRange,
      freezed == workout
          ? _value.workout
          : workout // ignore: cast_nullable_to_non_nullable
              as Workout?,
    ));
  }
}

/// @nodoc

class _$_Started implements _Started {
  const _$_Started(this.initialDateRange, this.workout);

  @override
  final DateTimeRange initialDateRange;
  @override
  final Workout? workout;

  @override
  String toString() {
    return 'WorkoutHistoryEvent.started(initialDateRange: $initialDateRange, workout: $workout)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_Started &&
            (identical(other.initialDateRange, initialDateRange) ||
                other.initialDateRange == initialDateRange) &&
            (identical(other.workout, workout) || other.workout == workout));
  }

  @override
  int get hashCode => Object.hash(runtimeType, initialDateRange, workout);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_StartedCopyWith<_$_Started> get copyWith =>
      __$$_StartedCopyWithImpl<_$_Started>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTimeRange initialDateRange, Workout? workout)
        started,
    required TResult Function(DateTimeRange dateRange) updateDateRange,
    required TResult Function(Routine routine) updateRoutine,
  }) {
    return started(initialDateRange, workout);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTimeRange initialDateRange, Workout? workout)?
        started,
    TResult? Function(DateTimeRange dateRange)? updateDateRange,
    TResult? Function(Routine routine)? updateRoutine,
  }) {
    return started?.call(initialDateRange, workout);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTimeRange initialDateRange, Workout? workout)? started,
    TResult Function(DateTimeRange dateRange)? updateDateRange,
    TResult Function(Routine routine)? updateRoutine,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(initialDateRange, workout);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(UpdateDateRange value) updateDateRange,
    required TResult Function(UpdateRoutine value) updateRoutine,
  }) {
    return started(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(UpdateDateRange value)? updateDateRange,
    TResult? Function(UpdateRoutine value)? updateRoutine,
  }) {
    return started?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(UpdateDateRange value)? updateDateRange,
    TResult Function(UpdateRoutine value)? updateRoutine,
    required TResult orElse(),
  }) {
    if (started != null) {
      return started(this);
    }
    return orElse();
  }
}

abstract class _Started implements WorkoutHistoryEvent {
  const factory _Started(
          final DateTimeRange initialDateRange, final Workout? workout) =
      _$_Started;

  DateTimeRange get initialDateRange;
  Workout? get workout;
  @JsonKey(ignore: true)
  _$$_StartedCopyWith<_$_Started> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateDateRangeCopyWith<$Res> {
  factory _$$UpdateDateRangeCopyWith(
          _$UpdateDateRange value, $Res Function(_$UpdateDateRange) then) =
      __$$UpdateDateRangeCopyWithImpl<$Res>;
  @useResult
  $Res call({DateTimeRange dateRange});
}

/// @nodoc
class __$$UpdateDateRangeCopyWithImpl<$Res>
    extends _$WorkoutHistoryEventCopyWithImpl<$Res, _$UpdateDateRange>
    implements _$$UpdateDateRangeCopyWith<$Res> {
  __$$UpdateDateRangeCopyWithImpl(
      _$UpdateDateRange _value, $Res Function(_$UpdateDateRange) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateRange = null,
  }) {
    return _then(_$UpdateDateRange(
      null == dateRange
          ? _value.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as DateTimeRange,
    ));
  }
}

/// @nodoc

class _$UpdateDateRange implements UpdateDateRange {
  const _$UpdateDateRange(this.dateRange);

  @override
  final DateTimeRange dateRange;

  @override
  String toString() {
    return 'WorkoutHistoryEvent.updateDateRange(dateRange: $dateRange)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateDateRange &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange));
  }

  @override
  int get hashCode => Object.hash(runtimeType, dateRange);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateDateRangeCopyWith<_$UpdateDateRange> get copyWith =>
      __$$UpdateDateRangeCopyWithImpl<_$UpdateDateRange>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTimeRange initialDateRange, Workout? workout)
        started,
    required TResult Function(DateTimeRange dateRange) updateDateRange,
    required TResult Function(Routine routine) updateRoutine,
  }) {
    return updateDateRange(dateRange);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTimeRange initialDateRange, Workout? workout)?
        started,
    TResult? Function(DateTimeRange dateRange)? updateDateRange,
    TResult? Function(Routine routine)? updateRoutine,
  }) {
    return updateDateRange?.call(dateRange);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTimeRange initialDateRange, Workout? workout)? started,
    TResult Function(DateTimeRange dateRange)? updateDateRange,
    TResult Function(Routine routine)? updateRoutine,
    required TResult orElse(),
  }) {
    if (updateDateRange != null) {
      return updateDateRange(dateRange);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(UpdateDateRange value) updateDateRange,
    required TResult Function(UpdateRoutine value) updateRoutine,
  }) {
    return updateDateRange(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(UpdateDateRange value)? updateDateRange,
    TResult? Function(UpdateRoutine value)? updateRoutine,
  }) {
    return updateDateRange?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(UpdateDateRange value)? updateDateRange,
    TResult Function(UpdateRoutine value)? updateRoutine,
    required TResult orElse(),
  }) {
    if (updateDateRange != null) {
      return updateDateRange(this);
    }
    return orElse();
  }
}

abstract class UpdateDateRange implements WorkoutHistoryEvent {
  const factory UpdateDateRange(final DateTimeRange dateRange) =
      _$UpdateDateRange;

  DateTimeRange get dateRange;
  @JsonKey(ignore: true)
  _$$UpdateDateRangeCopyWith<_$UpdateDateRange> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$UpdateRoutineCopyWith<$Res> {
  factory _$$UpdateRoutineCopyWith(
          _$UpdateRoutine value, $Res Function(_$UpdateRoutine) then) =
      __$$UpdateRoutineCopyWithImpl<$Res>;
  @useResult
  $Res call({Routine routine});
}

/// @nodoc
class __$$UpdateRoutineCopyWithImpl<$Res>
    extends _$WorkoutHistoryEventCopyWithImpl<$Res, _$UpdateRoutine>
    implements _$$UpdateRoutineCopyWith<$Res> {
  __$$UpdateRoutineCopyWithImpl(
      _$UpdateRoutine _value, $Res Function(_$UpdateRoutine) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? routine = null,
  }) {
    return _then(_$UpdateRoutine(
      null == routine
          ? _value.routine
          : routine // ignore: cast_nullable_to_non_nullable
              as Routine,
    ));
  }
}

/// @nodoc

class _$UpdateRoutine implements UpdateRoutine {
  const _$UpdateRoutine(this.routine);

  @override
  final Routine routine;

  @override
  String toString() {
    return 'WorkoutHistoryEvent.updateRoutine(routine: $routine)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UpdateRoutine &&
            (identical(other.routine, routine) || other.routine == routine));
  }

  @override
  int get hashCode => Object.hash(runtimeType, routine);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UpdateRoutineCopyWith<_$UpdateRoutine> get copyWith =>
      __$$UpdateRoutineCopyWithImpl<_$UpdateRoutine>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(DateTimeRange initialDateRange, Workout? workout)
        started,
    required TResult Function(DateTimeRange dateRange) updateDateRange,
    required TResult Function(Routine routine) updateRoutine,
  }) {
    return updateRoutine(routine);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(DateTimeRange initialDateRange, Workout? workout)?
        started,
    TResult? Function(DateTimeRange dateRange)? updateDateRange,
    TResult? Function(Routine routine)? updateRoutine,
  }) {
    return updateRoutine?.call(routine);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(DateTimeRange initialDateRange, Workout? workout)? started,
    TResult Function(DateTimeRange dateRange)? updateDateRange,
    TResult Function(Routine routine)? updateRoutine,
    required TResult orElse(),
  }) {
    if (updateRoutine != null) {
      return updateRoutine(routine);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(_Started value) started,
    required TResult Function(UpdateDateRange value) updateDateRange,
    required TResult Function(UpdateRoutine value) updateRoutine,
  }) {
    return updateRoutine(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(_Started value)? started,
    TResult? Function(UpdateDateRange value)? updateDateRange,
    TResult? Function(UpdateRoutine value)? updateRoutine,
  }) {
    return updateRoutine?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(_Started value)? started,
    TResult Function(UpdateDateRange value)? updateDateRange,
    TResult Function(UpdateRoutine value)? updateRoutine,
    required TResult orElse(),
  }) {
    if (updateRoutine != null) {
      return updateRoutine(this);
    }
    return orElse();
  }
}

abstract class UpdateRoutine implements WorkoutHistoryEvent {
  const factory UpdateRoutine(final Routine routine) = _$UpdateRoutine;

  Routine get routine;
  @JsonKey(ignore: true)
  _$$UpdateRoutineCopyWith<_$UpdateRoutine> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
mixin _$WorkoutHistoryState {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)?
        loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)?
        loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Initial value) initial,
    required TResult Function(Loaded value) loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Initial value)? initial,
    TResult? Function(Loaded value)? loaded,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Initial value)? initial,
    TResult Function(Loaded value)? loaded,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $WorkoutHistoryStateCopyWith<$Res> {
  factory $WorkoutHistoryStateCopyWith(
          WorkoutHistoryState value, $Res Function(WorkoutHistoryState) then) =
      _$WorkoutHistoryStateCopyWithImpl<$Res, WorkoutHistoryState>;
}

/// @nodoc
class _$WorkoutHistoryStateCopyWithImpl<$Res, $Val extends WorkoutHistoryState>
    implements $WorkoutHistoryStateCopyWith<$Res> {
  _$WorkoutHistoryStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$InitialCopyWith<$Res> {
  factory _$$InitialCopyWith(_$Initial value, $Res Function(_$Initial) then) =
      __$$InitialCopyWithImpl<$Res>;
}

/// @nodoc
class __$$InitialCopyWithImpl<$Res>
    extends _$WorkoutHistoryStateCopyWithImpl<$Res, _$Initial>
    implements _$$InitialCopyWith<$Res> {
  __$$InitialCopyWithImpl(_$Initial _value, $Res Function(_$Initial) _then)
      : super(_value, _then);
}

/// @nodoc

class _$Initial implements Initial {
  const _$Initial();

  @override
  String toString() {
    return 'WorkoutHistoryState.initial()';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$Initial);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)
        loaded,
  }) {
    return initial();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)?
        loaded,
  }) {
    return initial?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)?
        loaded,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Initial value) initial,
    required TResult Function(Loaded value) loaded,
  }) {
    return initial(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Initial value)? initial,
    TResult? Function(Loaded value)? loaded,
  }) {
    return initial?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Initial value)? initial,
    TResult Function(Loaded value)? loaded,
    required TResult orElse(),
  }) {
    if (initial != null) {
      return initial(this);
    }
    return orElse();
  }
}

abstract class Initial implements WorkoutHistoryState {
  const factory Initial() = _$Initial;
}

/// @nodoc
abstract class _$$LoadedCopyWith<$Res> {
  factory _$$LoadedCopyWith(_$Loaded value, $Res Function(_$Loaded) then) =
      __$$LoadedCopyWithImpl<$Res>;
  @useResult
  $Res call(
      {DateTimeRange dateRange,
      List<Routine>? routines,
      Routine? selectedRoutine,
      List<WorkoutHistory> workoutHistory});
}

/// @nodoc
class __$$LoadedCopyWithImpl<$Res>
    extends _$WorkoutHistoryStateCopyWithImpl<$Res, _$Loaded>
    implements _$$LoadedCopyWith<$Res> {
  __$$LoadedCopyWithImpl(_$Loaded _value, $Res Function(_$Loaded) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dateRange = null,
    Object? routines = freezed,
    Object? selectedRoutine = freezed,
    Object? workoutHistory = null,
  }) {
    return _then(_$Loaded(
      null == dateRange
          ? _value.dateRange
          : dateRange // ignore: cast_nullable_to_non_nullable
              as DateTimeRange,
      freezed == routines
          ? _value._routines
          : routines // ignore: cast_nullable_to_non_nullable
              as List<Routine>?,
      freezed == selectedRoutine
          ? _value.selectedRoutine
          : selectedRoutine // ignore: cast_nullable_to_non_nullable
              as Routine?,
      null == workoutHistory
          ? _value._workoutHistory
          : workoutHistory // ignore: cast_nullable_to_non_nullable
              as List<WorkoutHistory>,
    ));
  }
}

/// @nodoc

class _$Loaded implements Loaded {
  const _$Loaded(this.dateRange, final List<Routine>? routines,
      this.selectedRoutine, final List<WorkoutHistory> workoutHistory)
      : _routines = routines,
        _workoutHistory = workoutHistory;

  @override
  final DateTimeRange dateRange;
  final List<Routine>? _routines;
  @override
  List<Routine>? get routines {
    final value = _routines;
    if (value == null) return null;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(value);
  }

  @override
  final Routine? selectedRoutine;
  final List<WorkoutHistory> _workoutHistory;
  @override
  List<WorkoutHistory> get workoutHistory {
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_workoutHistory);
  }

  @override
  String toString() {
    return 'WorkoutHistoryState.loaded(dateRange: $dateRange, routines: $routines, selectedRoutine: $selectedRoutine, workoutHistory: $workoutHistory)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$Loaded &&
            (identical(other.dateRange, dateRange) ||
                other.dateRange == dateRange) &&
            const DeepCollectionEquality().equals(other._routines, _routines) &&
            (identical(other.selectedRoutine, selectedRoutine) ||
                other.selectedRoutine == selectedRoutine) &&
            const DeepCollectionEquality()
                .equals(other._workoutHistory, _workoutHistory));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      dateRange,
      const DeepCollectionEquality().hash(_routines),
      selectedRoutine,
      const DeepCollectionEquality().hash(_workoutHistory));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$LoadedCopyWith<_$Loaded> get copyWith =>
      __$$LoadedCopyWithImpl<_$Loaded>(this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function() initial,
    required TResult Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)
        loaded,
  }) {
    return loaded(dateRange, routines, selectedRoutine, workoutHistory);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function()? initial,
    TResult? Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)?
        loaded,
  }) {
    return loaded?.call(dateRange, routines, selectedRoutine, workoutHistory);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function()? initial,
    TResult Function(DateTimeRange dateRange, List<Routine>? routines,
            Routine? selectedRoutine, List<WorkoutHistory> workoutHistory)?
        loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(dateRange, routines, selectedRoutine, workoutHistory);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(Initial value) initial,
    required TResult Function(Loaded value) loaded,
  }) {
    return loaded(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(Initial value)? initial,
    TResult? Function(Loaded value)? loaded,
  }) {
    return loaded?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(Initial value)? initial,
    TResult Function(Loaded value)? loaded,
    required TResult orElse(),
  }) {
    if (loaded != null) {
      return loaded(this);
    }
    return orElse();
  }
}

abstract class Loaded implements WorkoutHistoryState {
  const factory Loaded(
      final DateTimeRange dateRange,
      final List<Routine>? routines,
      final Routine? selectedRoutine,
      final List<WorkoutHistory> workoutHistory) = _$Loaded;

  DateTimeRange get dateRange;
  List<Routine>? get routines;
  Routine? get selectedRoutine;
  List<WorkoutHistory> get workoutHistory;
  @JsonKey(ignore: true)
  _$$LoadedCopyWith<_$Loaded> get copyWith =>
      throw _privateConstructorUsedError;
}
