import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:passwordreminder/constants.dart';
import 'package:passwordreminder/db_helper.dart';
import 'package:passwordreminder/screens/home_screen.dart';
import 'dart:async';

BuildContext _context;
FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

class ReminderServie {
  ReminderServie(BuildContext context) {
    _context = context;
    Timer.periodic(Duration(days: 30), (timer) {
      DbHelper().updateRemindersForNextMonth();
    });
    Timer.periodic(Duration(days: 1), (timer) {
      DbHelper().deleteNotificationDaily();
    });
    serviceSetup();
  }

  Future<void> serviceSetup() async {
    _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var initializationSettingsAndroid =
        AndroidInitializationSettings('ic_launcher');
    var initializationSettingsIOS = IOSInitializationSettings();
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    await _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: selectNotification);
  }

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    DbHelper().deleteNotification(int.parse(payload));
    await Navigator.push(
      _context,
      MaterialPageRoute(
          builder: (context) => HomeScreen(
                title: 'Passwords',
                payload: payload,
              )),
    );
  }

  Future<void> nowNotif(int _id, String _title, String _body) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        CHANNEL_ID, CHANNEL_NAME, CHANNEL_DESC,
        importance: Importance.Max, priority: Priority.High, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.show(
        _id, _title, _body, platformChannelSpecifics,
        payload: _id.toString());
  }

  scheduleNotif(int _id, DateTime dateTime) async {
    var androidPlatformChannelSpecifics =
        AndroidNotificationDetails(CHANNEL_ID, CHANNEL_NAME, CHANNEL_DESC);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.schedule(
        _id, REMINDER_TITLE, REMINDER_BODY, dateTime, platformChannelSpecifics,
        payload: _id.toString(), androidAllowWhileIdle: true);
  }

  dailyNotif(int _id, int hour, int min) async {
    var time = Time(hour, min, 0);
    var androidPlatformChannelSpecifics =
        AndroidNotificationDetails(CHANNEL_ID, CHANNEL_NAME, CHANNEL_DESC);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.showDailyAtTime(
      _id,
      REMINDER_TITLE,
      REMINDER_BODY,
      time,
      platformChannelSpecifics,
      payload: _id.toString(),
    );
  }

  weeklyNotif(int _id, int hour, int min, {Day day = Day.Monday}) async {
    var time = Time(hour, min, 0);
    var androidPlatformChannelSpecifics =
        AndroidNotificationDetails(CHANNEL_ID, CHANNEL_NAME, CHANNEL_DESC);
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
    await _flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
      _id,
      REMINDER_TITLE,
      REMINDER_BODY,
      day,
      time,
      platformChannelSpecifics,
      payload: _id.toString(),
    );
  }

  monthlyNotif(int _id, int hour, int min) {
    // 1984–04–02 00:00:00.000
    DateTime now = DateTime.now();
    if (now.day > 1) {
      DateTime dateTime =
          DateTime.parse("${now.year}-${now.month + 1}-1 $hour:$min:00.000");
      scheduleNotif(_id, dateTime);
    } else {
      DateTime dateTime =
          DateTime.parse("${now.year}-${now.month}-1 $hour:$min:00.000");
      scheduleNotif(_id, dateTime);
    }
  }

  spacedNotif(int hour, int min, String payload) {}

  deleteNotif(int _id) async {
    await _flutterLocalNotificationsPlugin.cancel(_id);
  }

  deleteAllNotif() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  launchDetails() async {
    return await _flutterLocalNotificationsPlugin
        .getNotificationAppLaunchDetails();
  }

  Future<List<PendingNotificationRequest>> pendingNotif() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}

GetIt locator = GetIt.instance;

setupServiceLocator(BuildContext context) {
  if (!locator.isRegistered(instanceName: ReminderService))
    locator.registerLazySingleton<ReminderServie>(() => ReminderServie(context),
        instanceName: ReminderService);
}
