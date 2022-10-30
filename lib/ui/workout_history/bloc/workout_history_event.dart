part of 'workout_history_bloc.dart';

@freezed
class WorkoutHistoryEvent with _$WorkoutHistoryEvent {
  const factory WorkoutHistoryEvent.started(
      DateTimeRange initialDateRange, Workout? workout) = _Started;
  const factory WorkoutHistoryEvent.updateDateRange(
    DateTimeRange dateRange,
  ) = UpdateDateRange;
  const factory WorkoutHistoryEvent.updateRoutine(
    Routine routine,
  ) = UpdateRoutine;
}
