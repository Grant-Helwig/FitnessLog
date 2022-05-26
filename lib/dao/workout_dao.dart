import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:developer';

import '../database/workout_database.dart';
import '../model/routine.dart';
import '../model/routine_entry.dart';
import '../model/weight.dart';
import '../model/workout.dart';
import '../model/workout_history.dart';



class WorkoutDao {
  final dbHelper = DatabaseHelper.instance;

  saveWorkout(Workout workout) async {

    int id = await dbHelper.insertWorkout(workout);
    workout.id = id;

    log('inserted row: $id');
  }

  deleteWorkout(int _id) async {
    

    int id = await dbHelper.deleteWorkout(_id);

    log('deleted row: $id');
  }

  updateWorkout(Workout workout) async {
    
    log('updating row: ${workout.id.toString()}');
    int id = await dbHelper.updateWorkout(workout);

    log('updated row: $id');
  }

  Future<bool> workoutNameExists(String name) async {
    
    List<Workout>? workouts = await dbHelper.queryAllWorkouts();
    if (workouts != null) {
      for (var workout in workouts) {
        if (workout.name.toLowerCase() == name.toLowerCase()) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  Future<bool> routineNameExists(String name) async {
    
    List<Routine>? routines = await dbHelper.queryAllRoutines();
    if (routines != null) {
      for (var routine in routines) {
        if (routine.name.toLowerCase() == name.toLowerCase()) {
          return true;
        }
      }
      return false;
    } else {
      return false;
    }
  }

  Future<Workout?> readWorkout(int rowId) async {
    
    Workout? workout = await dbHelper.queryWorkout(rowId);
    if (workout == null) {
      log('read row $rowId: empty');
      return null;
    } else {
      log('read row $rowId: ${workout.name}');
      return workout;
    }
  }

  Future<List<Workout>?> readAllWorkouts() async {
    
    List<Workout>? workouts = await dbHelper.queryAllWorkouts();
    if (workouts == null) {
      log('read row empty');
      return null;
    } else {
      workouts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return workouts;
    }
  }

  Future<List<Workout>?> readAllWorkoutsNameSearch(String search) async {
    
    List<Workout>? workouts = await dbHelper.queryAllWorkouts();
    if (workouts == null) {
      log('read row empty');
      return null;
    } else {
      List<Workout> filteredWorkouts =
      workouts.where((element) => element.name.toLowerCase().contains(search)).toList();
      filteredWorkouts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return filteredWorkouts;
    }
  }

  saveRoutine(Routine routine) async {
    int id = await dbHelper.insertRoutine(routine);
    routine.id = id;

    log('inserted row: $id');
  }

  deleteRoutine(int _id) async {
    

    int id = await dbHelper.deleteRoutine(_id);

    log('deleted row: $id');
  }

  updateRoutine(Routine routine) async {
    
    log('updating row: ${routine.id.toString()}');
    int id = await dbHelper.updateRoutine(routine);

    log('updated row: $id');
  }

  Future<List<Routine>?> readAllRoutines() async {
    
    List<Routine>? routines = await dbHelper.queryAllRoutines();
    if (routines == null) {
      log('read row empty');
      return null;
    } else {
      routines.sort((a, b) => a.name.compareTo(b.name));
      return routines;
    }
  }

  saveRoutineEntry(RoutineEntry routineEntry) async {
    
    int id = await dbHelper.insertRoutineEntry(routineEntry);
    routineEntry.id = id;

    log('inserted row: $id');
  }

  deleteRoutineEntry(int _id) async {
    

    int id = await dbHelper.deleteRoutineEntry(_id);

    log('deleted row: $id');
  }

  updateRoutineEntry(RoutineEntry routineEntry) async {
    
    log('updating row: ${routineEntry.id.toString()}');
    int id = await dbHelper.updateRoutineEntry(routineEntry);

    log('updated row: $id');
  }

  Future<List<RoutineEntry>?> routineEntryByRoutine(int id) async {
    
    List<RoutineEntry>? workouts = await dbHelper.queryRoutineEntriesByRoutine(id);
    if (workouts == null) {
      log('read row $id: empty');
      return null;
    } else {
      workouts.sort((a, b) => a.order.compareTo(b.order));
      return workouts;
    }
  }

  Future<List<RoutineEntry>?> routineEntryByWorkout(int id) async {
    
    List<RoutineEntry>? workouts = await dbHelper.queryRoutineEntriesByWorkout(id);
    if (workouts == null) {
      log('read row $id: empty');
      return null;
    } else {
      workouts.sort((a, b) => a.order.compareTo(b.order));
      return workouts;
    }
  }

  Future<List<Workout>?> workoutsByRoutine(int id) async {
    
    List<RoutineEntry>? entries = await dbHelper.queryRoutineEntriesByRoutine(id);
    if (entries == null) {
      log('read row $id: empty');
      return null;
    } else {
      entries.sort((a, b) => a.order.compareTo(b.order));
      List<Workout>? workouts = [];
      for (var element in entries) {
        workouts.add((await readWorkout(element.workoutId))!);
      }
      return workouts;
    }
  }

  Future<List<Workout>?> readAllWorkoutsDropdown() async {
    
    int rowId = 1;
    List<Workout>? workouts = await dbHelper.queryAllWorkouts();
    if (workouts == null) {
      log('read row $rowId: empty');
      return null;
    } else {
      Workout add = Workout();
      add.id = -1;
      add.name = "All";
      add.type = 1;
      workouts.sort((a, b) => a.name.compareTo(b.name));
      workouts.insert(0, add);
      return workouts;
    }
  }

  Future<List<Routine>?> readAllRoutinesDropdown() async {
    
    int rowId = 1;
    List<Routine>? routines = await dbHelper.queryAllRoutines();
    if (routines == null) {
      log('read row $rowId: empty');
      return null;
    } else {
      Routine add = Routine();
      add.id = -1;
      add.name = "All";
      add.date = DateTime.now().toString();
      routines.sort((a, b) => a.name.compareTo(b.name));
      routines.insert(0, add);
      return routines;
    }
  }

  saveWorkoutHistory(WorkoutHistory workoutHistory) async {

    int id = await dbHelper.insertWorkoutHistory(workoutHistory);
    workoutHistory.id = id;

    log('inserted row: $id');
  }

  deleteWorkoutHistory(int _id) async {
    

    int id = await dbHelper.deleteWorkoutHistory(_id);

    log('deleted row: $id');
  }

  updateWorkoutHistory(WorkoutHistory workoutHistory) async {
    
    log('updating row: ${workoutHistory.id.toString()}');
    int id = await dbHelper.updateWorkoutHistory(workoutHistory);

    log('updated row: $id');
  }

  Future<List<WorkoutHistory>?> readAllWorkoutHistory() async {
    
    int rowId = 1;
    List<WorkoutHistory>? workouts = await dbHelper.queryAllWorkoutHistory();
    if (workouts == null) {
      log('read row $rowId: empty');
      return null;
    } else {
      workouts.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return workouts;
    }
  }

  Future<List<WorkoutHistory>?> workoutHistoryByWorkout(int id) async {
    
    List<WorkoutHistory>? workouts =
    await dbHelper.queryWorkoutHistoryByWorkout(id);
    if (workouts == null) {
      log('read row $id: empty');
      return null;
    } else {
      workouts.sort((a, b) {
        return a.date.compareTo(b.date);
      });
      return workouts;
    }
  }

  Future<WorkoutHistory?> mostRecentWorkoutHistoryByWorkout(int id) async {
    
    List<WorkoutHistory>? workouts =
    await dbHelper.queryWorkoutHistoryByWorkout(id);
    if (workouts == null) {
      log('read row $id: empty');
      return null;
    } else {
      workouts.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return workouts[0];
    }
  }

  Future<List<WorkoutHistory>?> workoutHistoryByWorkoutAndDates(
      int id, DateTimeRange range) async {
    
    List<WorkoutHistory>? workouts =
    await dbHelper.queryWorkoutHistoryByWorkout(id);
    if (workouts == null) {
      log('read row $id: empty');
      return null;
    } else {
      List<WorkoutHistory>? workoutsInRange = [];
      log(workouts.length.toString());
      for (var value in workouts) {
        DateTime curDay = DateTime.parse(value.date);
        if (range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
            datesEqual(range.start, curDay) ||
            datesEqual(range.end, curDay)) {
          workoutsInRange.add(value);
        } else {
          log("skipped ${value.workoutName} from ${value.date}");
        }
      }
      workoutsInRange.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return workoutsInRange;
    }
  }

  Future<List<WorkoutHistory>?> workoutHistoryByDates(
      DateTimeRange range) async {
    
    List<WorkoutHistory>? workouts = await dbHelper.queryAllWorkoutHistory();
    if (workouts == null) {
      return null;
    } else {
      List<WorkoutHistory>? workoutsInRange = [];
      for (var value in workouts) {
        DateTime curDay = DateTime.parse(value.date);
        if (range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
            datesEqual(range.start, curDay) ||
            datesEqual(range.end, curDay)) {
          workoutsInRange.add(value);
        }
      }
      workoutsInRange.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return workoutsInRange;
    }
  }

  Future<List<WorkoutHistory>?> workoutHistoryByRoutineAndDates(
      int id, DateTimeRange range) async {
    
    List<Workout>? workouts = await workoutsByRoutine(id);

    List<WorkoutHistory>? allWorkoutHistory = [];

    if (workouts == null) {
      log('read row $id: empty');
      return null;
    } else {
      for (var workout in workouts) {
        List<WorkoutHistory>? tempHistory =
        await workoutHistoryByWorkoutAndDates(workout.id, range);
        if (tempHistory != null) {
          allWorkoutHistory.addAll(tempHistory);
        }
      }
    }

    if (allWorkoutHistory.isEmpty) {
      log('read row $id: empty');
      return null;
    } else {
      List<WorkoutHistory>? workoutsInRange = [];
      for (var value in allWorkoutHistory) {
        DateTime curDay = DateTime.parse(value.date);
        if (range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
            datesEqual(range.start, curDay) ||
            datesEqual(range.end, curDay)) {
          workoutsInRange.add(value);
        } else {
          log("skipped ${value.workoutName} from ${value.date}");
        }
      }
      workoutsInRange.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return workoutsInRange;
    }
  }

  Future<List<WorkoutHistory>?> updateWorkoutHistoryByWorkout(
      int id, String workoutName) async {
    
    List<WorkoutHistory>? workouts =
    await dbHelper.queryWorkoutHistoryByWorkout(id);
    if (workouts == null) {
      return null;
    } else {
      for (var element in workouts) {
        var tempWorkout = element;
        tempWorkout.workoutName = workoutName;
        int id = await dbHelper.updateWorkoutHistory(tempWorkout);
        log('update row $id');
      }
      return workouts;
    }
  }

  Future<List<RoutineEntry>?> updateRoutineEntryByWorkout(
      int id, int workoutType, String workoutName) async {
    
    List<RoutineEntry>? entries =
    await dbHelper.queryRoutineEntriesByWorkout(id);
    if (entries == null) {
      return null;
    } else {
      for (var element in entries) {
        var tempEntry = element;
        tempEntry.workoutName = workoutName;
        tempEntry.workoutType = workoutType;
        int id = await dbHelper.updateRoutineEntry(tempEntry);
        log('update row $id');
      }
      return entries;
    }
  }

  saveWeight(Weight weight) async {

    int id = await dbHelper.insertWeight(weight);
    weight.id = id;

    log('inserted row: $id');
  }

  deleteWeight(int _id) async {


    int id = await dbHelper.deleteWeight(_id);

    log('deleted row: $id');
  }

  updateWeight(Weight weight) async {

    log('updating row: ${weight.id.toString()}');
    int id = await dbHelper.updateWeight(weight);

    log('updated row: $id');
  }

  Future<List<Weight>?> readAllWeights() async {

    List<Weight>? weights = await dbHelper.queryAllWeights();
    if (weights == null) {
      log('read row empty');
      return null;
    } else {
      weights.sort((a, b) => a.date.compareTo(b.date));
      return weights;
    }
  }

  Future<List<Weight>?> weightsByDates(
      DateTimeRange range) async {

    List<Weight>? weights = await dbHelper.queryAllWeights();
    if (weights == null) {
      return null;
    } else {
      List<Weight>? weightsInRange = [];
      for (var value in weights) {
        DateTime curDay = DateTime.parse(value.date);
        if (range.start.isBefore(curDay) && range.end.isAfter(curDay) ||
            datesEqual(range.start, curDay) ||
            datesEqual(range.end, curDay)) {
          weightsInRange.add(value);
        }
      }
      weightsInRange.sort((a, b) {
        return b.date.compareTo(a.date);
      });
      return weightsInRange;
    }
  }

  bool datesEqual(DateTime one, DateTime two) {
    return one.year == two.year && one.month == two.month && one.day == two.day;
  }
}