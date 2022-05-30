import 'package:hey_workout/model/workout_history.dart';

import '../database/workout_database.dart';

class WorkoutSet {
  int id = -1;
  late int workoutHistoryId;
  //late WorkoutHistory? workoutHistory;
  late int reps;
  late double weight;
  late int set;

  WorkoutSet();

  WorkoutSet.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    workoutHistoryId = map[columnWorkoutHistoryId];
    reps = map[columnReps];
    weight = map[columnWeight];
    set = map[columnSetOrder];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnWorkoutHistoryId: workoutHistoryId,
      columnReps: reps,
      columnWeight: weight,
      columnSetOrder: set,
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }
}
