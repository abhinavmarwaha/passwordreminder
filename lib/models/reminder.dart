class Reminder {
  final int id;
  final String name;
  final String userName;
  final String passwordHash;
  final reminding_time time;
  final int remindingTimeOfTheDayHour;
  final int remindingTimeOfTheDayMin;

  Reminder(
      {this.id,
      this.name,
      this.userName,
      this.passwordHash,
      this.time,
      this.remindingTimeOfTheDayHour,
      this.remindingTimeOfTheDayMin});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'userName': userName,
      'passwordHash': passwordHash,
      'time': time.toShortString(),
      'remindingTimeOfTheDayHour': remindingTimeOfTheDayHour,
      'remindingTimeOfTheDayMin': remindingTimeOfTheDayMin
    };
  }
}

enum reminding_time {
  daily,
  tryweekly,
  biweekly,
  weekly,
  bimonthly,
  monthly,
  spaced_repetaion
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
