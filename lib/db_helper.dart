import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:passwordreminder/models/notification.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';
import 'models/reminder.dart';

class DbHelper {
  static final DbHelper _instance = new DbHelper.internal();

  factory DbHelper() => _instance;

  static Database _db;

  openDB() async {
    var database = openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE notifications( id INTEGER PRIMARY KEY, reminderId INTEGER, day TEXT, hour INTEGER, min INTEGER, reminding TEXT);");
        return db.execute(
            "CREATE TABLE passwords( id INTEGER PRIMARY KEY, name TEXT, userName TEXT, passwordHash TEXT, time TEXT, remindingTimeOfTheDayHour INTEGER, remindingTimeOfTheDayMin INTEGER);");
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

    int _reminderId = await db.insert(
      passwords,
      _reminder.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    _reminder.id = _reminderId;

    switch (_reminder.time) {
      case reminding_time.daily:
        addNotifDaily(_reminder, db);
        break;

      case reminding_time.tryweekly:
        addNotifWeekly(_reminder, db, reminding_time.tryweekly, Day.Monday);
        addNotifWeekly(_reminder, db, reminding_time.tryweekly, Day.Thursday);
        addNotifWeekly(_reminder, db, reminding_time.tryweekly, Day.Sunday);
        break;

      case reminding_time.biweekly:
        addNotifWeekly(_reminder, db, reminding_time.biweekly, Day.Monday);
        addNotifWeekly(_reminder, db, reminding_time.biweekly, Day.Friday);
        break;

      case reminding_time.weekly:
        addNotifWeekly(_reminder, db, reminding_time.weekly, Day.Monday);
        break;

      // case reminding_time.bimonthly:
      //   addBimonthlyNotif(_reminder, db);
      //   break;
      // case reminding_time.monthly:
      //   addNotifMonthly(_reminder, db);
      //   break;

      // case reminding_time.spaced_repetaion:
      //   // TODO SpacedRepetation
      //   // GetIt.instance.get(instanceName: REMINDER_SERVICE).spacedNotif(
      //   //     _reminder.remindingTimeOfTheDayHour,
      //   //     _reminder.remindingTimeOfTheDayMin,
      //   //     _reminder.id.toString());
      //   break;
    }
  }

  addNotifDaily(
    Reminder _reminder,
    Database db,
  ) async {
    Notification notification = Notification(
        reminding: reminding_time.daily,
        hour: _reminder.remindingTimeOfTheDayHour,
        min: _reminder.remindingTimeOfTheDayMin,
        reminderId: _reminder.id);
    int id = await db.insert(notifications, notification.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    GetIt.instance.get(instanceName: REMINDER_SERVICE).dailyNotif(
        id,
        _reminder.remindingTimeOfTheDayHour,
        _reminder.remindingTimeOfTheDayMin);
  }

  addNotifWeekly(
      Reminder _reminder, Database db, reminding_time time, Day day) async {
    Notification notification = Notification(
        reminding: time,
        hour: _reminder.remindingTimeOfTheDayHour,
        min: _reminder.remindingTimeOfTheDayMin,
        day: day.toString(),
        reminderId: _reminder.id);

    int id = await db.insert(notifications, notification.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);

    GetIt.instance.get(instanceName: REMINDER_SERVICE).weeklyNotif(id,
        _reminder.remindingTimeOfTheDayHour, _reminder.remindingTimeOfTheDayMin,
        day: day);
  }

  Future<void> deleteReminder(int id) async {
    final db = await getdb;

    Reminder reminder = Reminder.fromMap(
        (await db.query(passwords, where: "id = ?", whereArgs: [id]))[0]);

    Batch batch = db.batch();

    (await db.query(notifications,
            where: "reminderId = ?", whereArgs: [reminder.id]))
        .forEach((notif) {
      Notification notification = Notification.fromMap(notif);
      GetIt.instance
          .get(instanceName: REMINDER_SERVICE)
          .deleteNotif(notification.id);
      batch.delete(notifications,
          where: "id == ?", whereArgs: [notification.id]);
    });
    batch.delete(passwords, where: "id == ?", whereArgs: [reminder.id]);
    await batch.commit();
  }

  Future<void> deleteNotification(int id) async {
    final db = await getdb;
    db.delete(notifications, where: "id == ?", whereArgs: [id]);
  }

  Future<Reminder> getReminder(int id) async {
    final Database db = await getdb;
    return Reminder.fromMap(
        (await db.query(passwords, where: "id = ?", whereArgs: [id]))[0]);
  }

  Future<List<Map<String, dynamic>>> getNotificationByReminder(
    int reminderId,
  ) async {
    final Database db = await getdb;
    return (await db.query(notifications,
        where: "reminderId = ?", whereArgs: [reminderId]));
  }

  Future<Notification> getNotification(
    int id,
  ) async {
    final Database db = await getdb;
    return Notification.fromMap(
        (await db.query(notifications, where: "id = ?", whereArgs: [id]))[0]);
  }

  Future<List<Reminder>> getReminders() async {
    final Database db = await getdb;
    List<Map<String, dynamic>> maps;
    maps = await db.query(passwords);

    return List.generate(maps.length, (i) {
      return Reminder.fromMap(maps[i]);
    });
  }

  Future<void> clearTable() async {
    final db = await getdb;
    await db.delete(passwords);
  }

  Future<void> editReminder(Reminder _reminder) async {
    await deleteReminder(_reminder.id);
    await insertReminder(_reminder);
  }

  Future close() async {
    var dbClient = await getdb;
    return dbClient.close();
  }
}
