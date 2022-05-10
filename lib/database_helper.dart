import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String columnId = '_id';
//workout columns
const String tableWorkoutHistory = 'WorkoutHistory';
const String columnWorkoutName = 'workoutName';
const String columnWorkoutType = 'workoutType';
const String columnDate = 'date';
const String columnWeight = 'weight';
const String columnTimer = 'timer';
const String columnSets = 'sets';
const String columnReps = 'reps';
const String columnTypeId = 'typeId';
//type columns
const String tableWorkout = 'Workout';
const String columnName = 'name';
const String columnType = 'type';

//class object for saving workout routines
class WorkoutHistory {
  int id = -1;
  late String workoutName;
  late int workoutType;
  late String date;
  late double weight;
  late double timer;
  late int sets;
  late int reps;
  late int typeId;

  WorkoutHistory();

  WorkoutHistory.fromMap(Map<dynamic, dynamic> map) {
    id = map[columnId];
    workoutName = map[columnWorkoutName];
    workoutType = map[columnWorkoutType];
    date = map[columnDate];
    weight = map[columnWeight];
    timer = map[columnTimer];
    sets = map[columnSets];
    reps = map[columnReps];
    typeId = map[columnTypeId];
  }

  // convenience method to create a Map from this Word object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      columnWorkoutName: workoutName,
      columnWorkoutType:workoutType,
      columnDate: date,
      columnWeight: weight,
      columnTimer: timer,
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


//class object for saving workout types
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

  // convenience method to create a Map from this Word object
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
                $columnTypeId INTEGER NOT NULL,
                $columnDate TEXT NOT NULL,
                $columnWeight DOUBLE NOT NULL,
                $columnTimer DOUBLE NOT NULL,
                $columnSets INTEGER NOT NULL,
                $columnReps INTEGER NOT NULL,
                FOREIGN KEY($columnTypeId) REFERENCES $tableWorkout($columnId)
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
          columnSets,
          columnReps,
          columnTypeId
        ],
        where: '$columnId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
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
    if (maps.length > 0) {
      return Workout.fromMap(maps.first);
    }
    return null;
  }

  Future<List<WorkoutHistory>?> queryWorkoutHistoryByType(int id) async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkoutHistory,
        columns: [
          columnId,
          columnWorkoutName,
          columnWorkoutType,
          columnDate,
          columnWeight,
          columnTimer,
          columnSets,
          columnReps,
          columnTypeId
        ],
        where: '$columnTypeId = ?',
        whereArgs: [id]);
    if (maps.length > 0) {
      List<WorkoutHistory> history = [];
      maps.forEach((map) => history.add(WorkoutHistory.fromMap(map)));
      return history;
    }
    return null;
  }

  Future<List<WorkoutHistory>?> queryAllWorkoutHistory() async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkoutHistory);
    if (maps.length > 0) {
      List<WorkoutHistory> history = [];
      maps.forEach((map) => history.add(WorkoutHistory.fromMap(map)));
      return history;
    }
    return null;
  }

  Future<List<Workout>?> queryAllWorkouts() async {
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkout);
    if (maps.length > 0) {
      List<Workout> workouts = [];
      maps.forEach((map) => workouts.add(Workout.fromMap(map)));
      return workouts;
    }
    return null;
  }

  Future<bool> queryHasWorkouts() async{
    Database? db = await database;
    List<Map> maps = await db!.query(tableWorkout);
    return maps.isNotEmpty;
  }

  bool queryWorkoutHasHistory(){
    return true;
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
}