import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String columnId = '_id';
//workout columns
const String tableWorkouts = 'Workouts';
const String columnRoutine = 'routine';
const String columnDate = 'date';
const String columnWeight = 'weight';
const String columnSets = 'sets';
const String columnReps = 'reps';
const String columnTypeId = 'typeId';
//type columns
const String tableWorkoutType = 'WorkoutType';
const String columnType = 'type';
const String columnWeightRequired = 'weightRequired';

class WorkoutRoutine {
  int id = -1;
  late String routine;
  late String date;
  late double weight;
  late int sets;
  late int reps;
  late int typeId;

  WorkoutRoutine();

  WorkoutRoutine.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    routine = map[columnRoutine];
    date = map[columnDate];
    weight = map[columnWeight];
    sets = map[columnSets];
    reps = map[columnReps];
    typeId = map[columnTypeId];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnRoutine: routine,
      columnDate: date,
      columnWeight: weight,
      columnSets: sets,
      columnReps: reps,
      columnTypeId: typeId
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }
}



class WorkoutType {
  int id = -1;
  late String type;
  late int weightRequired;

  WorkoutType();

  WorkoutType.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    type = map[columnType];
    weightRequired = map[columnWeightRequired];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnType: type,
      columnWeightRequired: weightRequired
    };
    if (id != -1) {
      map[columnId] = id;
    }
    return map;
  }
}
// data model class

// singleton class to manage the database
class DatabaseHelper {
  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = "MyDatabase.db";
  // Increment this version when you need to change the schema.
  static const _databaseVersion = 2;

  // Make this a singleton class.
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  Future<Database?> get database async {
    _database ??= await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    log("init the workout db");
    // The path_provider plugin gets the right directory for Android or iOS.
    Directory documentsDirectory;
    if (!kIsWeb) {
      documentsDirectory = await getApplicationDocumentsDirectory();
    } else {
      documentsDirectory = Directory.current;
    }

    String path = join(documentsDirectory.path, _databaseName);
    // Open the database. Can also add an onUpdate callback parameter.
    return await openDatabase(path,
        version: _databaseVersion,
        onConfigure: _onConfigure,
        onCreate: _onCreate);
  }
  _onConfigure(Database db) async{
    await db.execute("PRAGMA foreign_keys = ON");
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute("PRAGMA foreign_keys = ON");
    await db.execute('''
              CREATE TABLE $tableWorkoutType (
                $columnId INTEGER PRIMARY KEY,
                $columnType TEXT NOT NULL,
                $columnWeightRequired INTEGER NOT NULL
              )
              ''');

    await db.execute('''
              CREATE TABLE $tableWorkouts (
                $columnId INTEGER PRIMARY KEY,
                $columnRoutine TEXT NOT NULL,
                $columnDate TEXT NOT NULL,
                $columnWeight DOUBLE NOT NULL,
                $columnSets INTEGER NOT NULL,
                $columnReps INTEGER NOT NULL,
                $columnTypeId INTEGER NOT NULL,
                FOREIGN KEY($columnTypeId) REFERENCES $tableWorkoutType($columnId)
              )
              ''');

  }

  // Database helper methods:

  Future<int> insertWorkout(WorkoutRoutine workoutRoutine) async {
    Database? db = await database;
    int id = await db!.insert(tableWorkouts, workoutRoutine.toMap());
    return id;
  }

  Future<int> insertType(WorkoutType workoutType) async {
    Database? db = await database;
    int id = await db!.insert(tableWorkoutType, workoutType.toMap());
    return id;
  }

  Future<WorkoutRoutine?> queryWorkout(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkouts,
        columns: [
          columnId,
          columnRoutine,
          columnDate,
          columnWeight,
          columnSets,
          columnReps,
          columnTypeId
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return WorkoutRoutine.fromMap(maps.first);
    }
    return null;
  }

  Future<WorkoutType?> queryType(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkoutType,
        columns: [
          columnId,
          columnType,
          columnWeightRequired
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      return WorkoutType.fromMap(maps.first);
    }
    return null;
  }

  Future<List<WorkoutRoutine>?> queryAllWorkouts() async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkouts);
    if (maps.length > 0) {
      List<WorkoutRoutine> words = [];
      maps.forEach((map) => words.add(WorkoutRoutine.fromMap(map)));
      return words;
    }
    return null;
  }

  Future<List<WorkoutType>?> queryAllTypes() async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkoutType);
    if (maps.length > 0) {
      List<WorkoutType> words = [];
      maps.forEach((map) => words.add(WorkoutType.fromMap(map)));
      return words;
    }
    return null;
  }

  Future<int> deleteWorkout(int id) async {
    Database? db = await database;
    return await db!
        .delete(tableWorkouts, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteType(int id) async {
    Database? db = await database;
    return await db!
        .delete(tableWorkoutType, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateWorkout(WorkoutRoutine workout) async {
    Database? db = await database;
    return await db!.update(tableWorkouts, workout.toMap(),
        where: '$columnId = ?', whereArgs: [workout.id]);
  }

  Future<int> updateType(WorkoutType workout) async {
    Database? db = await database;
    return await db!.update(tableWorkoutType, workout.toMap(),
        where: '$columnId = ?', whereArgs: [workout.id]);
  }
}

// _save(String routine, DateTime date, int sets, int reps, double weight) async {
//   WorkoutRoutine workout = WorkoutRoutine();
//   workout.routine = routine;
//   workout.date = date.toString();
//   workout.sets = sets;
//   workout.reps = reps;
//   workout.weight = weight;
//
//   DatabaseHelper helper = DatabaseHelper.instance;
//
//   int id = await helper.insert(workout);
//   workout.id = id;
//
//   log('inserted row: $id');
// }
//
// _delete(int _id) async {
//   DatabaseHelper helper = DatabaseHelper.instance;
//
//   int id = await helper.deleteWorkout(_id);
//
//   log('deleted row: $id');
// }
//
// _read() async {
//   DatabaseHelper helper = DatabaseHelper.instance;
//   int rowId = 1;
//   WorkoutRoutine? workout = await helper.queryWorkout(rowId);
//   if (workout == null) {
//     log('read row $rowId: empty');
//     return null;
//   } else {
//     log('read row $rowId: ${workout.routine}');
//     return workout;
//   }
// }
//
// Future<List<WorkoutRoutine>?> _readAll() async {
//   DatabaseHelper helper = DatabaseHelper.instance;
//   int rowId = 1;
//   List<WorkoutRoutine>? workouts = await helper.queryAllWorkouts();
//   if (workouts == null) {
//     log('read row $rowId: empty');
//     return null;
//   } else {
//     log('read row $rowId: $workouts');
//     workouts.sort((a, b) {
//       return b.date.compareTo(a.date);
//     });
//     return workouts;
//   }
// }
//
// List<WorkoutRoutine>? _getAll() {
//   Future<List<WorkoutRoutine>?> workoutsFuture = _readAll();
//   List<WorkoutRoutine>? workouts;
//   workoutsFuture.then((value) {
//     if (value != null) value.forEach((item) => workouts!.add(item));
//   });
//   log(workouts!.length.toString());
//   return workouts == null ? [] : workouts;
// }
//
//
