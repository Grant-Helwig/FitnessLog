//class object for saving workout history
import '../database/workout_database.dart';

class WorkoutHistory {
  int id = -1;
  late String workoutName;
  late int workoutType;
  late String date;
  late double weight;
  late String duration;
  late double distance;
  late double calories;
  late double heartRate;
  late int sets;
  late int reps;
  late int workoutId;

  WorkoutHistory();

  WorkoutHistory.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    workoutName = map[columnWorkoutName];
    workoutType = map[columnWorkoutType];
    date = map[columnDate];
    weight = map[columnWeight];
    duration = map[columnDuration];
    distance = map[columnDistance];
    calories = map[columnCalories];
    heartRate = map[columnHeartRate];
    sets = map[columnSets];
    reps = map[columnReps];
    workoutId = map[columnWorkoutId];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnWorkoutName: workoutName,
      columnWorkoutType:workoutType,
      columnDate: date,
      columnWeight: weight,
      columnDuration: duration,
      columnDistance: distance,
      columnCalories: calories,
      columnHeartRate: heartRate,
      columnSets: sets,
      columnReps: reps,
      columnWorkoutId: workoutId
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }
}