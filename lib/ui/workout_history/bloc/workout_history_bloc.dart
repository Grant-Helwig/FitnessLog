import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hey_workout/model/routine.dart';
import 'package:hey_workout/model/workout.dart';
import 'package:hey_workout/model/workout_history.dart';
import 'package:hey_workout/repository/workout_repository.dart';

part 'workout_history_event.dart';
part 'workout_history_state.dart';
part 'workout_history_bloc.freezed.dart';

class WorkoutHistoryBloc
    extends Bloc<WorkoutHistoryEvent, WorkoutHistoryState> {
  WorkoutHistoryBloc() : super(const Initial()) {
    on<WorkoutHistoryEvent>((event, emit) async {
      await event.when(
        started: ((DateTimeRange initialDateRange, Workout? workout) async {
          this.workout = workout;
          List<WorkoutHistory>? _workoutHistory;
          if (workout != null) {
            _workoutHistory = await repo.workoutHistoryByWorkoutAndDates(
              workout.id,
              initialDateRange,
            );
          } else {
            _workoutHistory =
                await repo.workoutHistoryByDates(initialDateRange);
          }

          final _routineDropdown = await repo.readAllRoutinesDropdown();
          emit(WorkoutHistoryState.loaded(initialDateRange, _routineDropdown!,
              _routineDropdown[0], _workoutHistory ?? []));
        }),
        updateDateRange: (
          DateTimeRange newDateRange,
        ) async {
          await state.maybeWhen(
              loaded:
                  (dateRange, routines, selectedRoutine, workoutHistory) async {
                if (newDateRange != dateRange) {
                  List<WorkoutHistory>? _workoutHistory;
                  if (selectedRoutine.id == -1) {
                    if (workout != null) {
                      _workoutHistory =
                          await repo.workoutHistoryByWorkoutAndDates(
                        workout!.id,
                        newDateRange,
                      );
                    } else {
                      _workoutHistory =
                          await repo.workoutHistoryByDates(newDateRange);
                    }
                  } else {
                    _workoutHistory =
                        await repo.workoutHistoryByRoutineAndDates(
                            selectedRoutine.id, newDateRange);
                  }
                  emit(WorkoutHistoryState.loaded(newDateRange, routines,
                      selectedRoutine, _workoutHistory ?? []));
                }
              },
              orElse: (() {}));
        },
        updateRoutine: (routine) async {
          await state.maybeWhen(
              loaded:
                  (dateRange, routines, selectedRoutine, workoutHistory) async {
                if (routine.id != selectedRoutine.id) {
                  List<WorkoutHistory>? _workoutHistory;
                  if (routine.id == -1) {
                    _workoutHistory =
                        await repo.workoutHistoryByDates(dateRange);
                  } else {
                    _workoutHistory = await repo
                        .workoutHistoryByRoutineAndDates(routine.id, dateRange);
                  }
                  emit(WorkoutHistoryState.loaded(
                      dateRange, routines, routine, _workoutHistory ?? []));
                }
              },
              orElse: (() {}));
        },
      );
    });
  }
  WorkoutRepository repo = WorkoutRepository();
  Workout? workout;
}