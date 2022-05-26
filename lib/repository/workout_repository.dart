import 'package:flutter/material.dart';
import 'package:hey_workout/dao/workout_dao.dart';

import '../model/routine.dart';
import '../model/routine_entry.dart';
import '../model/weight.dart';
import '../model/workout.dart';
import '../model/workout_history.dart';


//allows me to add a database layer later
class WorkoutRepository {
  final workoutDao = WorkoutDao();
  Future saveWorkout (Workout workout) => workoutDao.saveWorkout(workout);
  Future deleteWorkout (int _id) => workoutDao.deleteWorkout(_id);
  Future updateWorkout (Workout workout) => workoutDao.updateWorkout(workout);
  Future<bool> workoutNameExists (String workoutName) => workoutDao.workoutNameExists(workoutName);
  Future<bool>  routineNameExists (String workoutName) => workoutDao.routineNameExists(workoutName);
  Future<Workout?> readWorkout (int rowId) => workoutDao.readWorkout(rowId);
  Future<List<Workout>?> readAllWorkouts () => workoutDao.readAllWorkouts();
  Future<List<Workout>?> readAllWorkoutsByName (String workoutName) => workoutDao.readAllWorkoutsNameSearch(workoutName);
  Future<List<Workout>?> readAllWorkoutsByRoutine (int _id)  => workoutDao.workoutsByRoutine(_id);
  Future<List<Workout>?> readAllWorkoutsDropdown () => workoutDao.readAllWorkoutsDropdown();

  Future saveWorkoutHistory (WorkoutHistory workoutHistory) => workoutDao.saveWorkoutHistory(workoutHistory);
  Future deleteWorkoutHistory(int _id) => workoutDao.deleteWorkoutHistory(_id);
  Future updateWorkoutHistory(WorkoutHistory workoutHistory) => workoutDao.updateWorkoutHistory(workoutHistory);
  Future<List<WorkoutHistory>?> readAllWorkoutHistory () => workoutDao.readAllWorkoutHistory();
  Future<List<WorkoutHistory>?> workoutHistoryByWorkout (int _id) => workoutDao.workoutHistoryByWorkout(_id);
  Future<WorkoutHistory?> mostRecentWorkoutHistoryByWorkout (int _id) => workoutDao.mostRecentWorkoutHistoryByWorkout(_id);
  Future<List<WorkoutHistory>?> workoutHistoryByWorkoutAndDates (int _id, DateTimeRange range)
    => workoutDao.workoutHistoryByWorkoutAndDates(_id, range);
  Future<List<WorkoutHistory>?> workoutHistoryByDates (DateTimeRange range) => workoutDao.workoutHistoryByDates(range);
  Future<List<WorkoutHistory>?> workoutHistoryByRoutineAndDates (int _id, DateTimeRange range)
    => workoutDao.workoutHistoryByRoutineAndDates(_id, range);
  Future<List<WorkoutHistory>?> updateWorkoutHistoryByWorkout (int _id, String workoutName)
    => workoutDao.updateWorkoutHistoryByWorkout(_id, workoutName);

  Future saveRoutine (Routine routine) => workoutDao.saveRoutine(routine);
  Future deleteRoutine (int _id) => workoutDao.deleteRoutine(_id);
  Future updateRoutine (Routine routine) => workoutDao.updateRoutine(routine);
  Future<List<Routine>?> readAllRoutines () => workoutDao.readAllRoutines();
  Future<List<Routine>?> readAllRoutinesDropdown () => workoutDao.readAllRoutinesDropdown();

  Future saveRoutineEntry (RoutineEntry routineEntry) => workoutDao.saveRoutineEntry(routineEntry);
  Future deleteRoutineEntry (int _id) => workoutDao.deleteRoutineEntry(_id);
  Future updateRoutineEntry (RoutineEntry routineEntry) => workoutDao.updateRoutineEntry(routineEntry);
  Future<List<RoutineEntry>?> routineEntryByRoutine (int _id) => workoutDao.routineEntryByRoutine(_id);
  Future<List<RoutineEntry>?> routineEntryByWorkout (int _id) => workoutDao.routineEntryByWorkout(_id);
  Future<List<RoutineEntry>?> updateRoutineEntryByWorkout(int _id, int workoutType, String workoutName)
    => workoutDao.updateRoutineEntryByWorkout(_id, workoutType, workoutName);

  Future saveWeight (Weight weight) => workoutDao.saveWeight(weight);
  Future deleteWeight (int _id) => workoutDao.deleteWeight(_id);
  Future updateWeight (Weight weight) => workoutDao.updateWeight(weight);
  Future<List<Weight>?> readAllWeights() => workoutDao.readAllWeights();
  Future<List<Weight>?> readAllWeightsByDate(DateTimeRange range) => workoutDao.weightsByDates(range);
}