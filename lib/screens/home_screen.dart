import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:passwordreminder/constants.dart';
import 'package:passwordreminder/models/reminder.dart';
import 'package:passwordreminder/screens/settings_screen.dart';
import 'package:passwordreminder/utilities/utilities.dart';
import 'package:battery_optimization/battery_optimization.dart';
import 'package:autostart/autostart.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../db_helper.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Reminder> _reminders = [];
  DbHelper _dbHelper = new DbHelper();

  TextEditingController _nameController = new TextEditingController();
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _passswordController = new TextEditingController();
  int hour = DateTime.now().hour, min = DateTime.now().minute;
  String _selectedTime = reminding_time.daily.toShortString();
  TextEditingController _passswordTestController = new TextEditingController();

  dialogInitEdit(int _index) {
    _nameController = new TextEditingController();
    _nameController.text = _reminders[_index].name;
    _userNameController = new TextEditingController();
    _userNameController.text = _reminders[_index].userName;
    hour = _reminders[_index].remindingTimeOfTheDayHour;
    min = _reminders[_index].remindingTimeOfTheDayMin;
    _selectedTime = _reminders[_index].time.toShortString();
  }

  dialogInit() {
    _nameController = new TextEditingController();
    _userNameController = new TextEditingController();
    _passswordController = new TextEditingController();
    hour = DateTime.now().hour;
    min = DateTime.now().minute;
    _selectedTime = reminding_time.daily.toShortString();

    Utilities.getDefInterval().then((value) {
      setState(() => _selectedTime = value);
    });
    Utilities.getDefRemindingTimeOfDay().then((value) {
      setState(() {
        var splits = value.split(":");
        hour = int.parse(splits[0]);
        min = int.parse(splits[1]);
      });
    });
  }

  @override
  void initState() {
    getReminders();
    checkBatteryOptimisation();
    checkAutoStart();

    Reminder rem = GetIt.instance.get(instanceName: REMINDER_SERVICE).curRemin;
    if (rem != null) {
      testReminder(null, rem);
      GetIt.instance.get(instanceName: REMINDER_SERVICE).curRemin = null;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SettingsScreen())),
          )
        ],
      ),
      body: Center(
          child: ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    showReminder(index);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          _reminders[index].name,
                          style: TextStyle(),
                        ),
                        Text(
                          _reminders[index].userName,
                          style: TextStyle(color: Colors.grey),
                        )
                      ],
                    ),
                  ),
                );
              })),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addItem(),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  addItem() {
    dialogInit();
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: SizedBox(
                height: 660,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "Name"),
                        ),
                        TextField(
                          controller: _userNameController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "User Name"),
                        ),
                        PasswordField(
                          controller: _passswordController,
                          hintText: "Password",
                        ),
                        RadioListTile(
                          title: Text(reminding_time.daily.toShortString()),
                          groupValue: _selectedTime,
                          value: reminding_time.daily.toShortString(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text(reminding_time.tryweekly.toShortString()),
                          groupValue: _selectedTime,
                          value: reminding_time.tryweekly.toShortString(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text(reminding_time.biweekly.toShortString()),
                          groupValue: _selectedTime,
                          value: reminding_time.biweekly.toShortString(),
                          onChanged: (value) => setState(() {
                            _selectedTime = value;
                          }),
                        ),
                        RadioListTile(
                          title: Text(reminding_time.weekly.toShortString()),
                          groupValue: _selectedTime,
                          value: reminding_time.weekly.toShortString(),
                          onChanged: (value) => setState(() {
                            _selectedTime = value;
                          }),
                        ),
                        // RadioListTile(
                        //   title: Text(reminding_time.bimonthly.toShortString()),
                        //   groupValue: _selectedTime,
                        //   value: reminding_time.bimonthly.toShortString(),
                        //   onChanged: (value) => setState(() {
                        //     _selectedTime = value;
                        //   }),
                        // ),
                        // RadioListTile(
                        //   title: Text(reminding_time.monthly.toShortString()),
                        //   groupValue: _selectedTime,
                        //   value: reminding_time.monthly.toShortString(),
                        //   onChanged: (value) => setState(() {
                        //     _selectedTime = value;
                        //   }),
                        // ),
                        CupertinoTimerPicker(
                          initialTimerDuration:
                              Duration(minutes: hour * 60 + min),
                          onTimerDurationChanged: (value) {
                            hour = value.inHours;
                            min = value.inMinutes % 60;
                          },
                          mode: CupertinoTimerPickerMode.hm,
                        ),
                        RaisedButton(
                          onPressed: () {
                            Reminder _reminder = Reminder(
                              name: _nameController.text,
                              userName: _userNameController.text,
                              passwordHash:
                                  Utilities.hash(_passswordController.text),
                              remindingTimeOfTheDayHour: hour,
                              remindingTimeOfTheDayMin: min,
                              time: getEnum(_selectedTime),
                            );
                            print(_reminder.toMap());
                            _dbHelper.insertReminder(_reminder);
                            getReminders();
                            Navigator.of(context).pop();
                          },
                          child: Text("Submit"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  showReminder(int _index) {
    print(_reminders[_index].toMap());
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          height: 192,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(_reminders[_index].name),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("UserName: " + _reminders[_index].userName),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text("Time: " +
                      _reminders[_index].remindingTimeOfTheDayHour.toString() +
                      ":" +
                      _reminders[_index].remindingTimeOfTheDayMin.toString()),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child:
                      Text("Type: " + _reminders[_index].time.toShortString()),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    FlatButton(
                      child: Text("Edit"),
                      onPressed: () {
                        editReminder(_index);
                      },
                    ),
                    FlatButton(
                      child: Text("Delete"),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: Text("Are You Sure?"),
                            actions: [
                              FlatButton(
                                child: Text("Yes"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Navigator.of(context).pop();
                                  _dbHelper
                                      .deleteReminder(_reminders[_index].id)
                                      .then((value) =>
                                          setState(() => getReminders()));
                                },
                              ),
                              FlatButton(
                                child: Text("No"),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              )
                            ],
                          ),
                        );
                      },
                    ),
                    FlatButton(
                      child: Text("Test"),
                      onPressed: () {
                        testReminder(_index, null);
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  editReminder(int _index) {
    dialogInitEdit(_index);
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0)),
              child: SizedBox(
                height: 660,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: <Widget>[
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "Name"),
                        ),
                        TextField(
                          controller: _userNameController,
                          decoration: InputDecoration(
                              border: InputBorder.none, hintText: "User Name"),
                        ),
                        RadioListTile(
                          title: Text(reminding_time.daily.toShortString()),
                          groupValue: _selectedTime,
                          value: reminding_time.daily.toShortString(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text(reminding_time.tryweekly.toShortString()),
                          groupValue: _selectedTime,
                          value: reminding_time.tryweekly.toShortString(),
                          onChanged: (value) {
                            setState(() {
                              _selectedTime = value;
                            });
                          },
                        ),
                        RadioListTile(
                          title: Text(reminding_time.biweekly.toShortString()),
                          groupValue: _selectedTime,
                          value: reminding_time.biweekly.toShortString(),
                          onChanged: (value) => setState(() {
                            _selectedTime = value;
                          }),
                        ),
                        RadioListTile(
                          title: Text(reminding_time.weekly.toShortString()),
                          groupValue: _selectedTime,
                          value: reminding_time.weekly.toShortString(),
                          onChanged: (value) => setState(() {
                            _selectedTime = value;
                          }),
                        ),
                        // RadioListTile(
                        //   title: Text(reminding_time.bimonthly.toShortString()),
                        //   groupValue: _selectedTime,
                        //   value: reminding_time.bimonthly.toShortString(),
                        //   onChanged: (value) => setState(() {
                        //     _selectedTime = value;
                        //   }),
                        // ),
                        // RadioListTile(
                        //   title: Text(reminding_time.monthly.toShortString()),
                        //   groupValue: _selectedTime,
                        //   value: reminding_time.monthly.toShortString(),
                        //   onChanged: (value) => setState(() {
                        //     _selectedTime = value;
                        //   }),
                        // ),
                        CupertinoTimerPicker(
                          initialTimerDuration:
                              Duration(minutes: hour * 60 + min),
                          onTimerDurationChanged: (value) {
                            hour = value.inHours;
                            min = value.inMinutes % 60;
                          },
                          mode: CupertinoTimerPickerMode.hm,
                        ),
                        RaisedButton(
                          onPressed: () {
                            Reminder _reminder = Reminder(
                              id: _reminders[_index].id,
                              name: _nameController.text,
                              userName: _userNameController.text,
                              passwordHash:
                                  Utilities.hash(_passswordController.text),
                              remindingTimeOfTheDayHour: hour,
                              remindingTimeOfTheDayMin: min,
                              time: getEnum(_selectedTime),
                            );
                            print(_reminder.toMap());
                            _dbHelper.editReminder(_reminder);
                            Navigator.of(context).pop();
                          },
                          child: Text("Submit"),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }

  testReminder(int _index, Reminder rem) {
    _passswordTestController = new TextEditingController();
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: SizedBox(
          height: 144,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(_reminders[_index].name ?? rem.name),
                Text(_reminders[_index].userName ?? rem.userName),
                TextField(
                  controller: _passswordTestController,
                  decoration: InputDecoration(
                      border: InputBorder.none, hintText: "Password"),
                ),
                RaisedButton(
                  onPressed: () {
                    if (_reminders[_index].passwordHash.compareTo(
                            Utilities.hash(_passswordTestController.text)) ==
                        0) {
                      Fluttertoast.showToast(
                          msg: "Yippee the password is correct!!",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.white,
                          textColor: Colors.blue,
                          fontSize: 16.0);
                      Navigator.of(context).pop();
                    } else {
                      Fluttertoast.showToast(
                          msg: "Incorrect, try Again.",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.CENTER,
                          timeInSecForIosWeb: 1,
                          backgroundColor: Colors.red,
                          textColor: Colors.white,
                          fontSize: 16.0);
                    }
                  },
                  child: Text("Test"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  getReminders() {
    _dbHelper.getReminders().then((reminders) => setState(() {
          _reminders = reminders;
        }));
  }

  checkBatteryOptimisation() {
    Utilities.getBatteryOptimisation().then((value) {
      if (!value) {
        BatteryOptimization.isIgnoringBatteryOptimizations().then((onValue) {
          if (!onValue) {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: Text(
                    "The App is batary optimised this may hinder the normal functionaly of the app"),
                actions: [
                  FlatButton(
                    child: Text("Take me to Settings"),
                    onPressed: () {
                      Utilities.setBoolInPref("BatteryOptimisation", true);
                      BatteryOptimization.openBatteryOptimizationSettings();
                    },
                  ),
                  FlatButton(
                    child: Text("Its Alright"),
                    onPressed: () {
                      Utilities.setBoolInPref("BatteryOptimisation", true);
                      Navigator.of(context).pop();
                    },
                  )
                ],
              ),
            );
          }
        });
      }
    });
  }

  void checkAutoStart() {
    Utilities.getAutoStart().then((value) async {
      if (!value) {
        bool isAutoStartPermissionAvailable =
            await Autostart.isAutoStartPermissionAvailable;
        if (isAutoStartPermissionAvailable) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(
                  "If you want to get notification after boot, you should give the permision to autostart"),
              actions: [
                FlatButton(
                  child: Text("Sure"),
                  onPressed: () {
                    Autostart.getAutoStartPermission();
                    Utilities.setBoolInPref("autostart", true);
                    Navigator.of(context).pop();
                  },
                ),
                FlatButton(
                  child: Text("Nae"),
                  onPressed: () {
                    Utilities.setBoolInPref("autostart", true);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text("You have to start application after boot"),
              actions: [
                FlatButton(
                  child: Text("Ok"),
                  onPressed: () {
                    Utilities.setBoolInPref("autostart", true);
                    Navigator.of(context).pop();
                  },
                )
              ],
            ),
          );
        }
      }
    });
  }
}
