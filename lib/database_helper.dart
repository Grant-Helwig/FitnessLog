import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String columnId = '_id';
//workout history columns
const String tableWorkoutHistory = 'WorkoutHistory';
const String columnWorkoutName = 'workoutName';
const String columnWorkoutType = 'workoutType';
const String columnDate = 'date';
const String columnWeight = 'weight';
const String columnTimer = 'timer';
const String columnDistance = 'distance';
const String columnCalories = 'calories';
const String columnHeartRate = 'heartRate';
const String columnSets = 'sets';
const String columnReps = 'reps';
const String columnWorkoutId = 'workoutId';
//workout columns
const String tableWorkout = 'Workout';
const String columnName = 'name';
const String columnType = 'type';
//workout routine columns
const String tableRoutine = 'Routine';
//workout routine entry columns
const String tableRoutineEntry = "RoutineEntry";
const String columnRoutineId = 'routineId';
const String columnOrder = "entryOrder";

//class object for saving workout history
class WorkoutHistory {
  int id = -1;
  late String workoutName;
  late int workoutType;
  late String date;
  late double weight;
  late double timer;
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
    timer = map[columnTimer];
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
      columnTimer: timer,
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


//class object for saving workouts
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
}

enum WorkoutType {
  strength,
  cardio,
  both
}

//class object for saving workout routines
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

//class object for each entry in a routine with a saved order
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

// data model class

// singleton class to manage the database for all objects
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

  //this needs to be enabled for foreign keys to work
  _onConfigure(Database db) async{
    await db.execute("PRAGMA foreign_keys = ON");
  }

  // SQL string to create the database, make sure type is first
  Future _onCreate(Database db, int version) async {
    await db.execute("PRAGMA foreign_keys = ON");
    await db.execute('''
              CREATE TABLE $tableWorkout (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnType INTEGER NOT NULL
              )
              ''');

    await db.execute('''
              CREATE TABLE $tableWorkoutHistory (
                $columnId INTEGER PRIMARY KEY,
                $columnWorkoutName TEXT NOT NULL,
                $columnWorkoutType INTEGER NOT NULL,
                $columnWorkoutId INTEGER NOT NULL,
                $columnDate TEXT NOT NULL,
                $columnWeight DOUBLE NOT NULL,
                $columnTimer DOUBLE NOT NULL,
                $columnDistance DOUBLE NOT NULL,
                $columnCalories DOUBLE NOT NULL,
                $columnHeartRate DOUBLE NOT NULL,
                $columnSets INTEGER NOT NULL,
                $columnReps INTEGER NOT NULL,
                FOREIGN KEY($columnWorkoutId) REFERENCES $tableWorkout($columnId)
              )
              ''');

    await db.execute('''
              CREATE TABLE $tableRoutine (
                $columnId INTEGER PRIMARY KEY,
                $columnName TEXT NOT NULL,
                $columnDate TEXT NOT NULL
               
              )
              ''');

    await db.execute('''
              CREATE TABLE $tableRoutineEntry (
                $columnId INTEGER PRIMARY KEY,
                $columnWorkoutName TEXT NOT NULL,
                $columnOrder INTEGER NOT NULL,
                $columnWorkoutId INTEGER NOT NULL,
                $columnWorkoutType INTEGER NOT NULL,
                $columnRoutineId INTEGER NOT NULL,
                FOREIGN KEY($columnWorkoutId) REFERENCES $tableWorkout($columnId),
                FOREIGN KEY($columnRoutineId) REFERENCES $tableRoutine($columnId)
              )
              ''');
  }

  // Database helper methods
  Future<int> insertWorkoutHistory(WorkoutHistory workoutHistory) async {
    Database? db = await database;
    int id = await db!.insert(tableWorkoutHistory, workoutHistory.toMap());
    return id;
  }

  Future<int> insertWorkout(Workout workout) async {
    Database? db = await database;
    int id = await db!.insert(tableWorkout, workout.toMap());
    return id;
  }

  Future<int> insertRoutine(Routine routine) async {
    Database? db = await database;
    int id = await db!.insert(tableRoutine, routine.toMap());
    return id;
  }

  Future<int> insertRoutineEntry(RoutineEntry routineEntry) async {
    Database? db = await database;
    int id = await db!.insert(tableRoutineEntry, routineEntry.toMap());
    return id;
  }

  Future<WorkoutHistory?> queryWorkoutHistory(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkoutHistory,
        columns: [
          columnId,
          columnWorkoutName,
          columnWorkoutType,
          columnDate,
          columnWeight,
          columnTimer,
          columnDistance,
          columnCalories,
          columnHeartRate,
          columnSets,
          columnReps,
          columnWorkoutId
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return WorkoutHistory.fromMap(maps.first);
    }
    return null;
  }

  Future<Workout?> queryWorkout(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkout,
        columns: [
          columnId,
          columnName,
          columnType
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Workout.fromMap(maps.first);
    }
    return null;
  }

  Future<Routine?> queryRoutine(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableRoutine,
        columns: [
          columnId,
          columnName,
          columnDate
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Routine.fromMap(maps.first);
    }
    return null;
  }

  Future<RoutineEntry?> queryRoutineEntry(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableRoutine,
        columns: [
          columnId,
          columnWorkoutName,
          columnWorkoutId,
          columnWorkoutType,
          columnRoutineId,
          columnOrder
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      return RoutineEntry.fromMap(maps.first);
    }
    return null;
  }

  Future<List<WorkoutHistory>?> queryWorkoutHistoryByWorkout(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkoutHistory,
        columns: [
          columnId,
          columnWorkoutName,
          columnWorkoutType,
          columnDate,
          columnWeight,
          columnTimer,
          columnDistance,
          columnCalories,
          columnHeartRate,
          columnSets,
          columnReps,
          columnWorkoutId
        ],
        where: '$columnWorkoutId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      List<WorkoutHistory> history = [];
      maps.forEach((map) => history.add(WorkoutHistory.fromMap(map)));
      return history;
    }
    return null;
  }

  Future<List<WorkoutHistory>?> queryAllWorkoutHistory() async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkoutHistory);
    if (maps.isNotEmpty) {
      List<WorkoutHistory> history = [];
      maps.forEach((map) => history.add(WorkoutHistory.fromMap(map)));
      return history;
    }
    return null;
  }

  Future<List<Workout>?> queryAllWorkouts() async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkout);
    if (maps.isNotEmpty) {
      List<Workout> workouts = [];
      maps.forEach((map) => workouts.add(Workout.fromMap(map)));
      return workouts;
    }
    return null;
  }

  Future<List<Routine>?> queryAllRoutines() async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableRoutine);
    if (maps.isNotEmpty) {
      List<Routine> routines = [];
      maps.forEach((map) => routines.add(Routine.fromMap(map)));
      return routines;
    }
    return null;
  }

  Future<List<RoutineEntry>?> queryRoutineEntriesByRoutine(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableRoutineEntry,
        columns: [
          columnId,
          columnWorkoutName,
          columnWorkoutId,
          columnWorkoutType,
          columnRoutineId,
          columnOrder
        ],
        where: '$columnRoutineId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      List<RoutineEntry> entries = [];
      maps.forEach((map) => entries.add(RoutineEntry.fromMap(map)));
      return entries;
    }
    return null;
  }

  Future<List<RoutineEntry>?> queryRoutineEntriesByWorkout(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableRoutineEntry,
        columns: [
          columnId,
          columnWorkoutName,
          columnWorkoutId,
          columnWorkoutType,
          columnRoutineId,
          columnOrder
        ],
        where: '$columnWorkoutId = ?',
        whereArgs: [id]);
    if (maps.isNotEmpty) {
      List<RoutineEntry> entries = [];
      maps.forEach((map) => entries.add(RoutineEntry.fromMap(map)));
      return entries;
    }
    return null;
  }

  Future<bool> queryHasWorkouts() async{
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkout);
    return maps.isNotEmpty;
  }

  Future<int> deleteWorkoutHistory(int id) async {
    Database? db = await database;
    return await db!
        .delete(tableWorkoutHistory, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteWorkout(int id) async {
    Database? db = await database;
    return await db!
        .delete(tableWorkout, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteRoutine(int id) async {
    Database? db = await database;
    return await db!
        .delete(tableRoutine, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> deleteRoutineEntry(int id) async {
    Database? db = await database;
    return await db!
        .delete(tableRoutineEntry, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> updateWorkoutHistory(WorkoutHistory workout) async {
    Database? db = await database;
    return await db!.update(tableWorkoutHistory, workout.toMap(),
        where: '$columnId = ?', whereArgs: [workout.id]);
  }

  Future<int> updateWorkout(Workout workout) async {
    Database? db = await database;
    return await db!.update(tableWorkout, workout.toMap(),
        where: '$columnId = ?', whereArgs: [workout.id]);
  }

  Future<int> updateRoutine(Routine routine) async {
    Database? db = await database;
    return await db!.update(tableRoutine, routine.toMap(),
        where: '$columnId = ?', whereArgs: [routine.id]);
  }

  Future<int> updateRoutineEntry(RoutineEntry routineEntry) async {
    Database? db = await database;
    return await db!.update(tableRoutineEntry, routineEntry.toMap(),
        where: '$columnId = ?', whereArgs: [routineEntry.id]);
  }
}