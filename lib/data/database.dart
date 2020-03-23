import 'dart:async';

import 'package:path/path.dart';
import 'package:pushup_counter/model/day.dart';
import 'package:pushup_counter/model/set.dart';
import 'package:sqflite/sqflite.dart';
import "package:collection/collection.dart";

// based on: https://flutter.dev/docs/cookbook/persistence/sqlite#1-add-the-dependencies
const String database_name = "pushups.db";

const String reps_tablename = "reps";

const String CREATE_REPS = """
CREATE TABLE $reps_tablename(
  id INTEGER PRIMARY KEY,
  timestamp INTEGER NOT NULL,
  reps INTEGER NOT NULL,
  type INTEGER
);

CREATE INDEX reps_index_timestamp on $reps_tablename (timestamp);
""";

class DBProvider {
  /// empty constructor
  DBProvider._();

  /// Inernal database instance
  static Database _database;

  /// Create static instance of DB
  static final DBProvider db = DBProvider._();

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await setup();
    return _database;
  }

  setup() async {
    String path = "./";
    try {
      await getDatabasesPath();
    } catch (er) {
      print(er);
    }

    return openDatabase(join(path, database_name), onCreate: (db, version) {
      return db.execute(CREATE_REPS);
    }, version: 1);
  }

  Future<int> addPushupSet(int numberOfReps, dynamic setType) async {
    Database db = await database;

    PushupSet newSet = new PushupSet(
        reps: numberOfReps, timestamp: DateTime.now(), type: null);

    newSet.id = await db.insert(reps_tablename, newSet.toMap());
    return await getTodaysTally();
  }

  Future<int> getTodaysTally() async {
    DateTime now = DateTime.now();
    int start =
        new DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
    int finish =
        new DateTime(now.year, now.month, now.day + 1).millisecondsSinceEpoch;

    Database db = await database;
    List<Map<String, dynamic>> fields = await db.query(
      reps_tablename,
      columns: ["sum(reps) as s"],
      where: "? <= timestamp and timestamp < ?",
      whereArgs: [start, finish],
    );
    if (fields.length == 0) {
      return 0;
    }
    return fields[0]["s"] ?? 0;
  }

  Future<List<Day>> getLastNDays(int days) async {
    DateTime now = DateTime.now();
    int start = now.subtract(Duration(days: days)).millisecondsSinceEpoch;
    Database db = await database;
    List<Map<String, dynamic>> fields = await db.query(
      reps_tablename,
      where: "? <= timestamp",
      whereArgs: [start],
    );

    List<PushupSet> sets = fields.map((row) => PushupSet.fromMap(row)).toList();

    Map<DateTime, List<PushupSet>> grouped = groupBy(
        sets,
        (PushupSet obj) => new DateTime(
            obj.timestamp.year, obj.timestamp.month, obj.timestamp.day));

    return grouped.keys
        .map((day) => new Day(
              reps: grouped[day]
                  .map((pushup) => pushup.reps)
                  .reduce((a, b) => a + b),
              date: day,
            ))
        .toList();
  }
}
