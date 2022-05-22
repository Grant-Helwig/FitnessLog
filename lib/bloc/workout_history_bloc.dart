import 'package:flutter/material.dart';
import 'package:hey_workout/repository/workout_repository.dart';
import 'dart:async';
import '../model/routine.dart';
import '../model/workout.dart';
import '../model/workout_history.dart';

class WorkoutHistoryBloc {
  final repo = WorkoutRepository();

  final _workoutHistoryController = StreamController<List<WorkoutHistory>?>.broadcast();

  get workoutHistory => _workoutHistoryController.stream;

  WorkoutHistoryBloc() {
    getWorkoutHistory();
  }

  getWorkoutHistory() async {
    _workoutHistoryController.sink.add(await repo.readAllWorkoutHistory());
  }

  getWorkoutHistoryByDates(DateTimeRange range) async {
    _workoutHistoryController.sink.add(await repo.workoutHistoryByDates(range));
  }

  getWorkoutHistoryByRoutineAndDates(Routine routine, DateTimeRange range) async {
    _workoutHistoryController.sink.add(await repo.workoutHistoryByRoutineAndDates(routine.id, range));
  }

  getWorkoutHistoryByWorkoutAndDates(Workout workout, DateTimeRange range) async {
    _workoutHistoryController.sink.add(await repo.workoutHistoryByWorkoutAndDates(workout.id, range));
  }

  getWorkoutHistoryConditional({Routine? routine, DateTimeRange? range}) async {
    //if we have a range use range, if we have a routine use that too
    if(range != null){
      if(routine != null){
        getWorkoutHistoryByRoutineAndDates(routine, range);
      } else {
        getWorkoutHistoryByDates(range);
      }
    } else {
      getWorkoutHistory();
    }
  }

  addWorkoutHistory({required WorkoutHistory workoutHistory, Routine? routine, DateTimeRange? range}) async {
    await repo.saveWorkoutHistory(workoutHistory);
    getWorkoutHistoryConditional(routine: routine,range: range);
  }

  updateWorkoutHistory({required WorkoutHistory workoutHistory, Routine? routine, DateTimeRange? range}) async {
    await repo.updateWorkoutHistory(workoutHistory);
    getWorkoutHistoryConditional(routine: routine,range: range);
  }

  deleteWorkoutHistory({required WorkoutHistory workoutHistory, Routine? routine, DateTimeRange? range}) async {
    await repo.deleteWorkoutHistory(workoutHistory.id);
    getWorkoutHistoryConditional(routine: routine,range: range);
  }
}