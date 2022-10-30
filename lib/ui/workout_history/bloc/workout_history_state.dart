part of 'workout_history_bloc.dart';

@freezed
class WorkoutHistoryState with _$WorkoutHistoryState {
  const factory WorkoutHistoryState.initial() = Initial;
  const factory WorkoutHistoryState.loaded(
    DateTimeRange dateRange,
    List<Routine> routines,
    Routine selectedRoutine,
    List<WorkoutHistory> workoutHistory,
  ) = Loaded;
}
