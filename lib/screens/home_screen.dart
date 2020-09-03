import 'package:flutter/material.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:passwordreminder/models/reminder.dart';
import 'package:passwordreminder/screens/settings_screen.dart';
import 'package:passwordreminder/utilities/utilities.dart';

import '../db_helper.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title, this.payload}) : super(key: key);

  final String title;
  final String payload;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Reminder> _reminders = [];
  DbHelper _dbHelper = new DbHelper();

  @override
  void initState() {
    getReminders();
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
                    showReminder(_reminders[index].id);
                  },
                  onLongPress: () {},
                  child: Column(
                    children: <Widget>[
                      Text(_reminders[index].name),
                      Text(
                        _reminders[index].userName,
                        style: TextStyle(color: Colors.grey),
                      )
                    ],
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
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            TextEditingController _nameController = new TextEditingController();
            TextEditingController _userNameController =
                new TextEditingController();
            TextEditingController _passswordController =
                new TextEditingController();
            String _selectedTimeOfTheDayString;
            int hour, min;
            String _selectedTime = reminding_time.daily.toShortString();
            _pickTime() async {
              TimeOfDay date = await showTimePicker(
                context: context,
                initialTime: TimeOfDay.now(),
              );
              if (date != null) {
                hour = date.hour;
                min = date.minute;
                setState(() {
                  _selectedTimeOfTheDayString =
                      date.hour.toString() + " : " + date.minute.toString();
                });
              }
            }

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
                        Row(
                          children: <Widget>[
                            Radio(
                              groupValue: _selectedTime,
                              value: reminding_time.daily.toShortString(),
                              onChanged: (value) => setState(() {
                                _selectedTime = value;
                              }),
                            ),
                            Text(reminding_time.daily.toShortString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              groupValue: _selectedTime,
                              value: reminding_time.tryweekly.toShortString(),
                              onChanged: (value) => setState(() {
                                _selectedTime = value;
                              }),
                            ),
                            Text(reminding_time.tryweekly.toShortString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              groupValue: _selectedTime,
                              value: reminding_time.biweekly.toShortString(),
                              onChanged: (value) => setState(() {
                                _selectedTime = value;
                              }),
                            ),
                            Text(reminding_time.biweekly.toShortString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              groupValue: _selectedTime,
                              value: reminding_time.weekly.toShortString(),
                              onChanged: (value) => setState(() {
                                _selectedTime = value;
                              }),
                            ),
                            Text(reminding_time.weekly.toShortString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              groupValue: _selectedTime,
                              value: reminding_time.weekly.toShortString(),
                              onChanged: (value) => setState(() {
                                _selectedTime = value;
                              }),
                            ),
                            Text(reminding_time.weekly.toShortString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              groupValue: _selectedTime,
                              value: reminding_time.bimonthly.toShortString(),
                              onChanged: (value) => setState(() {
                                _selectedTime = value;
                              }),
                            ),
                            Text(reminding_time.bimonthly.toShortString()),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Radio(
                              groupValue: _selectedTime,
                              value: reminding_time.monthly.toShortString(),
                              onChanged: (value) => setState(() {
                                _selectedTime = value;
                              }),
                            ),
                            Text(reminding_time.monthly.toShortString()),
                          ],
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text("Time Selected"),
                            Spacer(),
                            RaisedButton(
                              onPressed: () => _pickTime(),
                              child: Text(_selectedTimeOfTheDayString != null
                                  ? _selectedTimeOfTheDayString
                                  : "Select Time"),
                            ),
                          ],
                        ),
                        RaisedButton(
                          onPressed: () {
                            Reminder _reminder = Reminder(
                                name: _nameController.value.toString(),
                                userName: _userNameController.value.toString(),
                                passwordHash: Utilities.hash(
                                    _passswordController.value.toString()),
                                remindingTimeOfTheDayHour: hour,
                                remindingTimeOfTheDayMin: min,
                                time: getEnum(_selectedTime));
                            _dbHelper.insertReminder(_reminder);
                            setState(() => _reminders.add(_reminder));
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

  showReminder(int _id) {}

  editReminder(int _id) {}

  showMenu(int _id) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: SizedBox(
            height: 150,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    child: Text("Delete"),
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                                title: Text("Are you sure?"),
                                actions: [
                                  FlatButton(
                                    child: Text("yes"),
                                    onPressed: () {
                                      _dbHelper.deleteReminder(_id);
                                    },
                                  ),
                                  FlatButton(
                                    child: Text("No"),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  )
                                ],
                              ));
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      editReminder(_id);
                    },
                    child: Text("Edit"),
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  getReminders() {
    _dbHelper.getReminders().then((reminders) => setState(() {
          reminders.forEach((element) {
            debugPrint('/n' + element.name + '/n');
          });
          _reminders = reminders;
        }));
  }
}
