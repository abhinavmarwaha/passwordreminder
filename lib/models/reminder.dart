class Reminder {
  int id;
  String name;
  String userName;
  String passwordHash;
  reminding_time time;
  int remindingTimeOfTheDayHour;
  int remindingTimeOfTheDayMin;

  Reminder(
      {this.id,
      this.name,
      this.userName,
      this.passwordHash,
      this.time,
      this.remindingTimeOfTheDayHour,
      this.remindingTimeOfTheDayMin});

  Reminder.fromMap(Map<String, dynamic> map) {
    this.id = map['id'];
    this.name = map['name'];
    this.userName = map['userName'];
    this.passwordHash = map['passwordHash'];
    this.time = getEnum(map['time']);
    this.remindingTimeOfTheDayHour = map['remindingTimeOfTheDayHour'];
    this.remindingTimeOfTheDayMin = map['remindingTimeOfTheDayMin'];
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userName': userName,
      'passwordHash': passwordHash,
      'time': time.toShortString(),
      'remindingTimeOfTheDayHour': remindingTimeOfTheDayHour,
      'remindingTimeOfTheDayMin': remindingTimeOfTheDayMin,
    };
  }
}

enum reminding_time {
  daily,
  triweekly,
  biweekly,
  weekly,
  // bimonthly,
  // monthly,
  // spaced_repetaion
}

extension ParseToString on reminding_time {
  String toShortString() {
    return this.toString().split('.').last;
  }
}

reminding_time getEnum(String timeString) {
  return reminding_time.values
      .firstWhere((e) => e.toString() == 'reminding_time.' + timeString);
}
