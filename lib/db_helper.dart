import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:passwordreminder/models/notification.dart';
import 'package:passwordreminder/reminder_service.dart';
import 'package:passwordreminder/utilities/utilities.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'constants.dart';
import 'models/reminder.dart';

// notif id's , def date and time;

class DbHelper {
  static final DbHelper _instance = new DbHelper.internal();

  factory DbHelper() => _instance;

  static Database _db;

  openDB() async {
    // CHECK( pType IN ('daily','tryweekly','biweekly', 'weekly', 'bimonthly', 'monthly', 'spaced_repetaion') )
    var database = openDatabase(
      join(await getDatabasesPath(), 'app_database.db'),
      onCreate: (db, version) {
        db.execute(
            "CREATE TABLE notifications( id INTEGER PRIMARY KEY, reminderId INTEGER, day TEXT, hour INTEGER, min INTEGER, reminding TEXT, dateTime TEXT);");
        return db.execute(
            "CREATE TABLE passwords( id INTEGER PRIMARY KEY, name TEXT, userName TEXT, passwordHash TEXT, time TEXT, remindingTimeOfTheDayHour INTEGER, remindingTimeOfTheDayMin INTEGER,);");
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
    int _reminderId = (await getReminder(_reminder.name))[0]['id'];
    int id;

    switch (_reminder.time) {
      case reminding_time.daily:
        Notification notification = Notification(
            reminding: reminding_time.daily,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminderId);
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        int id = (await getNotification(notification.reminderId))[0]['id'];
        GetIt.instance<ReminderServie>().dailyNotif(
            id,
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin);

        break;

      case reminding_time.tryweekly:
        Notification notification = Notification(
            reminding: reminding_time.tryweekly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            day: Day.Monday.toString(),
            reminderId: _reminderId);
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        id =
            (await getNotificationByDay(notification.reminderId, Day.Monday))[0]
                ['id'];

        GetIt.instance<ReminderServie>().weeklyNotif(
            id,
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin,
            day: Day.Monday);

        notification = Notification(
            reminding: reminding_time.tryweekly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminderId,
            day: Day.Thursday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        id = (await getNotificationByDay(
            notification.reminderId, Day.Thursday))[0]['id'];

        GetIt.instance<ReminderServie>().weeklyNotif(
            id,
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin,
            day: Day.Thursday);

        notification = Notification(
            reminding: reminding_time.tryweekly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminderId,
            day: Day.Sunday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        id =
            (await getNotificationByDay(notification.reminderId, Day.Sunday))[0]
                ['id'];

        GetIt.instance<ReminderServie>().weeklyNotif(
            id,
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin,
            day: Day.Thursday);

        break;

      case reminding_time.biweekly:
        Notification notification = Notification(
            reminding: reminding_time.biweekly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            day: Day.Monday.toString(),
            reminderId: _reminderId);
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        id =
            (await getNotificationByDay(notification.reminderId, Day.Monday))[0]
                ['id'];

        GetIt.instance<ReminderServie>().weeklyNotif(
            id,
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin,
            day: Day.Monday);

        notification = Notification(
            reminding: reminding_time.weekly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminderId,
            day: Day.Friday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        id =
            (await getNotificationByDay(notification.reminderId, Day.Friday))[0]
                ['id'];

        GetIt.instance<ReminderServie>().weeklyNotif(
            id,
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin,
            day: Day.Friday);
        break;

      case reminding_time.weekly:
        Notification notification = Notification(
            reminding: reminding_time.weekly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminderId,
            day: Day.Monday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        id =
            (await getNotificationByDay(notification.reminderId, Day.Monday))[0]
                ['id'];

        GetIt.instance<ReminderServie>().weeklyNotif(
            id,
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin);
        break;

      case reminding_time.bimonthly:

        // 1984–04–02 00:00:00.000
        DateTime now = DateTime.now();
        if (now.day > 15) {
          DateTime dateTime = DateTime.parse(
              "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          Notification notification = Notification(
              reminding: reminding_time.bimonthly,
              hour: _reminder.remindingTimeOfTheDayHour,
              min: _reminder.remindingTimeOfTheDayMin,
              reminderId: _reminderId,
              day: Day.Monday.toString());
          await db.insert(notifications, notification.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          int _id = (await getNotificationByDay(
              notification.reminderId, Day.Monday))[0]['id'];

          GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);

          dateTime = DateTime.parse(
              "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          notification = Notification(
              reminding: reminding_time.bimonthly,
              hour: _reminder.remindingTimeOfTheDayHour,
              min: _reminder.remindingTimeOfTheDayMin,
              reminderId: _reminderId,
              day: Day.Thursday.toString());
          await db.insert(notifications, notification.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          _id = (await getNotificationByDay(
              notification.reminderId, Day.Thursday))[0]['id'];
          dateTime = DateTime.parse(
              "${now.year}-${now.month + 1}-15 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
        } else if (now.day < 15 && now.day > 1) {
          DateTime dateTime = DateTime.parse(
              "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          Notification notification = Notification(
              reminding: reminding_time.bimonthly,
              hour: _reminder.remindingTimeOfTheDayHour,
              min: _reminder.remindingTimeOfTheDayMin,
              reminderId: _reminderId,
              day: Day.Monday.toString());
          await db.insert(notifications, notification.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          int _id = (await getNotificationByDay(
              notification.reminderId, Day.Monday))[0]['id'];

          GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);

          notification = Notification(
              reminding: reminding_time.bimonthly,
              hour: _reminder.remindingTimeOfTheDayHour,
              min: _reminder.remindingTimeOfTheDayMin,
              reminderId: _reminderId,
              day: Day.Thursday.toString());
          await db.insert(notifications, notification.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          _id = (await getNotificationByDay(
              notification.reminderId, Day.Thursday))[0]['id'];

          dateTime = DateTime.parse(
              "${now.year}-${now.month}-15 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
        } else {
          DateTime dateTime = DateTime.parse(
              "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          Notification notification = Notification(
              reminding: reminding_time.bimonthly,
              hour: _reminder.remindingTimeOfTheDayHour,
              min: _reminder.remindingTimeOfTheDayMin,
              reminderId: _reminderId,
              day: Day.Monday.toString());
          await db.insert(notifications, notification.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          int _id = (await getNotification(notification.reminderId))[0]['id'];

          GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
          dateTime = DateTime.parse(
              "${now.year}-${now.month}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);

          dateTime = DateTime.parse(
              "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          notification = Notification(
              reminding: reminding_time.bimonthly,
              hour: _reminder.remindingTimeOfTheDayHour,
              min: _reminder.remindingTimeOfTheDayMin,
              reminderId: _reminderId,
              day: Day.Monday.toString());
          await db.insert(notifications, notification.toMap(),
              conflictAlgorithm: ConflictAlgorithm.replace);
          _id = (await getNotification(notification.reminderId))[0]['id'];

          GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
          dateTime = DateTime.parse(
              "${now.year}-${now.month}-15 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
          GetIt.instance<ReminderServie>().launchDetails()(_id, dateTime);
        }

        break;
      case reminding_time.monthly:
        Notification notification = Notification(
            reminding: reminding_time.monthly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminderId,
            day: Day.Monday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        id =
            (await getNotificationByDay(notification.reminderId, Day.Monday))[0]
                ['id'];

        GetIt.instance<ReminderServie>().monthlyNotif(
            id,
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin);
        break;
      case reminding_time.spaced_repetaion:
        // TODO SpacedRepetation
        GetIt.instance<ReminderServie>().spacedNotif(
            _reminder.remindingTimeOfTheDayHour,
            _reminder.remindingTimeOfTheDayMin,
            _reminder.id.toString());
        break;
    }
  }

  updateRemindersForNextMonth() async {
    final db = await getdb;

    (await db.query(passwords,
            where: "time = ?",
            whereArgs: [reminding_time.monthly.toShortString()]))
        .forEach((element) async {
      Reminder _reminder = Reminder.fromMap(element);

      Notification notification = Notification(
          reminding: reminding_time.monthly,
          hour: _reminder.remindingTimeOfTheDayHour,
          min: _reminder.remindingTimeOfTheDayMin,
          reminderId: _reminder.id,
          day: Day.Monday.toString());
      await db.insert(notifications, notification.toMap(),
          conflictAlgorithm: ConflictAlgorithm.replace);
      int id = (await getNotification(notification.reminderId))[0]['id'];

      GetIt.instance<ReminderServie>().monthlyNotif(
          id,
          _reminder.remindingTimeOfTheDayHour,
          _reminder.remindingTimeOfTheDayMin);
    });

    (await db.query(passwords,
            where: "time = ?",
            whereArgs: [reminding_time.bimonthly.toShortString()]))
        .forEach((element) async {
      // 1984–04–02 00:00:00.000
      Reminder _reminder = Reminder.fromMap(element);

      DateTime now = DateTime.now();
      if (now.day > 15) {
        DateTime dateTime = DateTime.parse(
            "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
        Notification notification = Notification(
            reminding: reminding_time.bimonthly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminder.id,
            day: Day.Monday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        int _id = (await getNotification(notification.reminderId))[0]['id'];

        GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
        dateTime = DateTime.parse(
            "${now.year}-${now.month + 1}-15 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
        GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
      } else if (now.day < 15 && now.day > 1) {
        DateTime dateTime = DateTime.parse(
            "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
        Notification notification = Notification(
            reminding: reminding_time.bimonthly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminder.id,
            day: Day.Monday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        int _id = (await getNotification(notification.reminderId))[0]['id'];

        GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
        dateTime = DateTime.parse(
            "${now.year}-${now.month}-15 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
        GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
      } else {
        DateTime dateTime = DateTime.parse(
            "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
        Notification notification = Notification(
            reminding: reminding_time.bimonthly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminder.id,
            day: Day.Monday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        int _id = (await getNotification(notification.reminderId))[0]['id'];

        GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
        dateTime = DateTime.parse(
            "${now.year}-${now.month}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
        GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);

        dateTime = DateTime.parse(
            "${now.year}-${now.month + 1}-1 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
        notification = Notification(
            reminding: reminding_time.bimonthly,
            hour: _reminder.remindingTimeOfTheDayHour,
            min: _reminder.remindingTimeOfTheDayMin,
            reminderId: _reminder.id,
            day: Day.Monday.toString());
        await db.insert(notifications, notification.toMap(),
            conflictAlgorithm: ConflictAlgorithm.replace);
        _id = (await getNotification(notification.reminderId))[0]['id'];

        GetIt.instance<ReminderServie>().scheduleNotif(_id, dateTime);
        dateTime = DateTime.parse(
            "${now.year}-${now.month}-15 ${_reminder.remindingTimeOfTheDayHour}:${_reminder.remindingTimeOfTheDayMin}:00.000");
        GetIt.instance<ReminderServie>().launchDetails()(_id, dateTime);
      }
    });
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
      GetIt.instance<ReminderServie>().deleteNotif(notification.id);
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

  Future<void> deleteNotificationDaily() async {
    final db = await getdb;
    DateTime dateTime = DateTime.now();
    dateTime.subtract(new Duration(days: 1));
    db.delete(notifications,
        where: "dateTime < ?", whereArgs: [Utilities.formatDate(dateTime)]);
  }

  Future<List<Map<String, dynamic>>> getReminder(String name) async {
    final Database db = await getdb;
    return (await db.query(passwords, where: "name = ?", whereArgs: [name]));
  }

  Future<List<Map<String, dynamic>>> getNotification(
    int reminderId,
  ) async {
    final Database db = await getdb;
    return (await db.query(notifications,
        where: "reminderId = ?", whereArgs: [reminderId]));
  }

  Future<List<Map<String, dynamic>>> getNotificationByDay(
      int reminderId, Day day) async {
    final Database db = await getdb;
    return (await db.query(notifications,
        where: "reminderId = ? && day = ?",
        whereArgs: [reminderId, day.toString()]));
  }

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
      whereArgs: [_reminder.id.toString()],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future close() async {
    var dbClient = await getdb;
    return dbClient.close();
  }
}
