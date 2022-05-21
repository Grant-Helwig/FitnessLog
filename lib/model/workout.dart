import '../database/workout_database.dart';

class Workout {
  int id = -1;
  late String name;
  late int type;

  Workout();

  Workout.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    type = map[columnType];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnType: type
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }

  //helper method to display strings for each workout type
  String workoutTypeString(WorkoutType category){
    switch (category) {
      case WorkoutType.strength:
        return "Strength";
      case WorkoutType.cardio:
        return "Cardio";
      case WorkoutType.both:
        return "Strength & Cardio";
    }
  }
}

enum WorkoutType {
  strength,
  cardio,
  both
}
