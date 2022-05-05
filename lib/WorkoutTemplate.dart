import 'dart:developer';
import 'dart:io';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

const String tableWorkoutType = 'WorkoutType';
const String columnId = '_id';
const String columnType = 'type';
const String columnWeightRequired = 'weightRequired';

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
class DatabaseHelperType {
  // This is the actual database filename that is saved in the docs directory.
  static const _databaseName = "MyDatabase2.db";
  // Increment this version when you need to change the schema.
  static const _databaseVersion = 1;

  // Make this a singleton class.
  DatabaseHelperType._privateConstructor();
  static final DatabaseHelperType instance = DatabaseHelperType._privateConstructor();

  // Only allow a single open connection to the database.
  static Database? _database;
  Future<Database?> get database async {
    _database ??= await _initDatabase();
    return _database;
  }

  // open the database
  _initDatabase() async {
    log("init the type db");
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
        version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL string to create the database
  Future _onCreate(Database db, int version) async {
    await db.execute('''
              CREATE TABLE $tableWorkoutType (
                $columnId INTEGER PRIMARY KEY,
                $columnType TEXT NOT NULL,
                $columnWeightRequired INTEGER NOT NULL
              )
              ''');
  }

  // Database helper methods:

  Future<int> insert(WorkoutType workoutType) async {
    Database? db = await database;
    int id = await db!.insert(tableWorkoutType, workoutType.toMap());
    return id;
  }

  Future<WorkoutType?> queryWorkout(int id) async {
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

  Future<List<WorkoutType>?> queryAllWorkouts() async {
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
        .delete(tableWorkoutType, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<int> update(WorkoutType workout) async {
    Database? db = await database;
    return await db!.update(tableWorkoutType, workout.toMap(),
        where: '$columnId = ?', whereArgs: [workout.id]);
  }
}