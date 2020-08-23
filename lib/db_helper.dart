import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'models/reminder.dart';

class DbHelper {
  static final DbHelper _instance = new DbHelper.internal();

  factory DbHelper() => _instance;

  static Database _db;
  final String passwords = "passwords";

  openDB() async {
    var database = openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: (db, version) {
        return db.execute(
            "CREATE TABLE passwords( id INTEGER PRIMARY KEY, name TEXT, userName TEXT, passwordHash TEXT, time TEXT CHECK( pType IN ('daily','tryweekly','biweekly', 'weekly', 'bimonthly', 'monthly', 'spaced_repetaion') ), remindingTimeOfTheDayHour INTEGER, remindingTimeOfTheDayMin INTEGER);");
      },
      version: 1,
    );
    return database;
  }

  DbHelper.internal();

  Future<Database> get getdb async {
    if (_db != null) {
      return _db;
    }
    _db = await openDB();

    return _db;
  }

  Future<void> insertReminder(Reminder _reminder) async {
    final Database db = await getdb;

    await db.insert(
      passwords,
      _reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Future<bool> hasFeeditem(CRssFeedItem item, String dbName) async {
  //   final Database db = await getdb;
  //   return (await db.query(dbName,
  //               where: "title = ? AND pubDate = ?",
  //               whereArgs: [item.title, item.pubDate]))
  //           .length !=
  //       0;
  // }

  Future<List<Reminder>> getReminders() async {
    final Database db = await getdb;
    List<Map<String, dynamic>> maps;
    maps = await db.query(passwords);

    return List.generate(maps.length, (i) {
      return Reminder(
          id: maps[i]['id'],
          name: maps[i]['name'],
          userName: maps[i]['userName'],
          passwordHash: maps[i]['passwordHash']);
    });
  }

  Future<void> deleteReminder(int _id) async {
    final db = await getdb;

    await db.delete(
      passwords,
      where: "id = ?",
      whereArgs: [_id],
    );
  }

  // Future<void> deleteCat(
  //     String name, String catDb, String feedsDb, String feedsItemdb) async {
  //   final db = await getdb;

  //   Batch batch = db.batch();
  //   batch.delete(feedsDb, where: "catgry == ?", whereArgs: [name]);
  //   batch.delete(
  //     feedsItemdb,
  //     where: "catgry = ?",
  //     whereArgs: [
  //       name,
  //     ],
  //   );
  //   batch.delete(
  //     catDb,
  //     where: "name = ?",
  //     whereArgs: [name],
  //   );
  //   await batch.commit();
  // }

  Future<void> clearTable() async {
    final db = await getdb;
    await db.delete(passwords);
  }

  Future<void> editReminder(Reminder _reminder) async {
    final db = await getdb;

    await db.update(
      passwords,
      _reminder.toMap(),
      where: "id = ?",
      whereArgs: [_reminder.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future close() async {
    var dbClient = await getdb;
    return dbClient.close();
  }
}
