import 'package:hey_workout/model/workout_history.dart';

import '../database/workout_database.dart';

class Set {
  int id = -1;
  late int workoutHistoryId;
  //late WorkoutHistory? workoutHistory;
  late int reps;
  late int set;

  Set();

  Set.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    //workoutHistoryId = map[columnWorkoutHistoryId];
    reps = map[columnReps];
    set = map[columnSet];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      //columnWorkoutHistoryId: workoutHistoryId,
      columnReps: reps,
      columnSet: set,
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }
}
