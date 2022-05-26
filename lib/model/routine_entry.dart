import '../database/workout_database.dart';

class RoutineEntry {
  int id = -1;
  late String workoutName;
  late int workoutId;
  late int workoutType;
  late int routineId;
  late int order;

  RoutineEntry();

  RoutineEntry.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    workoutName = map[columnWorkoutName];
    workoutId = map[columnWorkoutId];
    workoutType = map[columnWorkoutType];
    routineId = map[columnRoutineId];
    order = map[columnOrder];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnWorkoutName: workoutName,
      columnWorkoutId: workoutId,
      columnWorkoutType: workoutType,
      columnRoutineId: routineId,
      columnOrder: order
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }
}