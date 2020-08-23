import 'package:flutter/material.dart';
import 'package:passwordfield/passwordfield.dart';
import 'package:passwordreminder/models/reminder.dart';
import 'package:passwordreminder/utilities/utilities.dart';

import '../db_helper.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Reminder> _reminders;
  DbHelper _dbHelper = new DbHelper();
  Future<TimeOfDay> _selectedTimeOfTheDay;

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
      ),
      body: Center(
          child: ListView.builder(
              itemCount: _reminders.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    showReminder(_reminders[index].id);
                  },
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
        onPressed: addItem(),
        tooltip: 'Add',
        child: Icon(Icons.add),
      ),
    );
  }

  addItem() {
    showDialog(
        context: context,
        builder: (context) {
          TextEditingController _nameController;
          TextEditingController _userNameController;
          TextEditingController _passswordController;
          int _selectedTime = 0;
          String _selectedTimeValue = reminding_time.daily.toShortString();
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0)),
            child: SizedBox(
              height: 160,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
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
                          value: 0,
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
                          value: 1,
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
                          value: 2,
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
                          value: 3,
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
                          value: 4,
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
                          value: 5,
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
                          value: 6,
                          onChanged: (value) => setState(() {
                            _selectedTime = value;
                          }),
                        ),
                        Text(reminding_time.monthly.toShortString()),
                      ],
                    ),
                    RaisedButton(
                      onPressed: () {
                        _selectedTimeOfTheDay = showTimePicker(
                          initialTime: TimeOfDay.now(),
                          context: context,
                        );
                      },
                      child: Text('Time of the Day'),
                    ),
                    RaisedButton(
                      onPressed: () => _selectedTimeOfTheDay.then((value) => {
                            _dbHelper.insertReminder(Reminder(
                                name: _nameController.value.toString(),
                                userName: _userNameController.value.toString(),
                                passwordHash: Utilities.hash(
                                    _passswordController.value.toString()),
                                remindingTimeOfTheDayHour: value.hour,
                                remindingTimeOfTheDayMin: value.minute,
                                time: getEnum(_selectedTimeValue))),
                          }),
                      child: Text("Submit"),
                    )
                  ],
                ),
              ),
            ),
          );
        });
  }

  showReminder(int _index) {}

  getReminders() {
    _dbHelper.getReminders().then((reminders) => setState(() {
          _reminders = reminders;
        }));
  }
}
