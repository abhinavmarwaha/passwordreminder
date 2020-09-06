import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:passwordreminder/constants.dart';
import 'package:passwordreminder/db_helper.dart';
import 'package:passwordreminder/models/reminder.dart';
import 'dart:async';

FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;

class ReminderService {
  ReminderService() {
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

    Timer.periodic(Duration(days: 1), (timer) {
      curRemin = null;
    });
  }

  Reminder curRemin;

  Future selectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: ' + payload);
    }
    DbHelper().getNotification(int.parse(payload)).then((notif) {
      DbHelper()
          .getReminder(notif.reminderId)
          .then((value) => curRemin = value);
    });
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

  // spacedNotif(int hour, int min, String payload) {}

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

  Future<List<PendingNotificationRequest>> getPendingNotif() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }

  printPendingNotif() async {
    (await _flutterLocalNotificationsPlugin.pendingNotificationRequests())
        .forEach((element) {
      print(element.id);
    });
  }
}

GetIt locator = GetIt.instance;

setupServiceLocator() {
  if (!locator.isRegistered(instanceName: REMINDER_SERVICE)) {
    locator.registerLazySingleton<ReminderService>(() => ReminderService(),
        instanceName: REMINDER_SERVICE);
  }
}
