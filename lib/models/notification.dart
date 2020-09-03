import 'package:passwordreminder/models/reminder.dart';
import 'package:passwordreminder/utilities/utilities.dart';

class Notification {
  int id;
  int reminderId;
  String day;
  int hour;
  int min;
  DateTime dateTime;
  reminding_time reminding;

  Notification(
      {this.id,
      this.day,
      this.hour,
      this.min,
      this.reminderId,
      this.reminding,
      this.dateTime});

  Notification.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.reminderId = map['reminderId'];
    this.day = map['day'];
    this.hour = map['hour'];
    this.min = map['min'];
    this.reminding = getEnum(map['reminding']);
    this.dateTime = DateTime.parse(map['dateTime']);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderId': reminderId,
      'day': day,
      'hour': hour,
      'min': min,
      'reminding': reminding.toShortString(),
      'dateTime': Utilities.formatDate(dateTime)
    };
  }
}
