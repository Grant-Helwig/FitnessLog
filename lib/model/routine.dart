import '../database/workout_database.dart';

class Routine {
  int id = -1;
  late String name;
  late String date;

  Routine();

  Routine.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    name = map[columnName];
    date = map[columnDate];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnName: name,
      columnDate: date
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }
}