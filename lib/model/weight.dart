import '../database/workout_database.dart';

class Weight {
  int id = -1;
  late double weight;
  late String date;

  Weight();

  Weight.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    weight = map[columnWeight];
    date = map[columnDate];
  }

  // convenience method to create a Map from this object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnWeight: weight,
      columnDate: date
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }
}
