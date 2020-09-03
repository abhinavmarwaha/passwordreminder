import 'package:flutter/material.dart';
import 'package:passwordreminder/utilities/theme_changer.dart';
import 'package:passwordreminder/utilities/utilities.dart';
import 'package:provider/provider.dart';

import '../constants.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  int hour, min;
  String _selectedTimeOfTheDayString;

  @override
  void initState() {
    ThemeChanger.getDarkModePlainBool().then((value) {
      setState(() {
        _darkMode = value;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

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

  @override
  Widget build(BuildContext context) {
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        children: <Widget>[
          Card(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Dark Mode"),
                  Spacer(),
                  Switch(
                    onChanged: (val) {
                      setState(() {
                        _darkMode = val;
                        _themeChanger.setDarkMode(_darkMode);
                      });
                    },
                    value: _darkMode,
                  )
                ],
              ),
            ),
          ),
          Card(
            child: GestureDetector(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return StatefulBuilder(builder: (context, setState) {
                        var remindingTime;
                        String _selectedTime;
                        Utilities.getDefRemindingTimeOfDay().then(
                            (value) => _selectedTimeOfTheDayString = value);
                        Utilities.getDefInterval()
                            .then((value) => _selectedTime = value);
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
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          groupValue: _selectedTime,
                                          value: remindingTime.daily
                                              .toShortString(),
                                          onChanged: (value) => setState(() {
                                            _selectedTime = value;
                                          }),
                                        ),
                                        Text(remindingTime.daily
                                            .toShortString()),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          groupValue: _selectedTime,
                                          value: remindingTime.tryweekly
                                              .toShortString(),
                                          onChanged: (value) => setState(() {
                                            _selectedTime = value;
                                          }),
                                        ),
                                        Text(remindingTime.tryweekly
                                            .toShortString()),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          groupValue: _selectedTime,
                                          value: remindingTime.biweekly
                                              .toShortString(),
                                          onChanged: (value) => setState(() {
                                            _selectedTime = value;
                                          }),
                                        ),
                                        Text(remindingTime.biweekly
                                            .toShortString()),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          groupValue: _selectedTime,
                                          value: remindingTime.weekly
                                              .toShortString(),
                                          onChanged: (value) => setState(() {
                                            _selectedTime = value;
                                          }),
                                        ),
                                        Text(remindingTime.weekly
                                            .toShortString()),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          groupValue: _selectedTime,
                                          value: remindingTime.weekly
                                              .toShortString(),
                                          onChanged: (value) => setState(() {
                                            _selectedTime = value;
                                          }),
                                        ),
                                        Text(remindingTime.weekly
                                            .toShortString()),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          groupValue: _selectedTime,
                                          value: remindingTime.bimonthly
                                              .toShortString(),
                                          onChanged: (value) => setState(() {
                                            _selectedTime = value;
                                          }),
                                        ),
                                        Text(remindingTime.bimonthly
                                            .toShortString()),
                                      ],
                                    ),
                                    Row(
                                      children: <Widget>[
                                        Radio(
                                          groupValue: _selectedTime,
                                          value: remindingTime.monthly
                                              .toShortString(),
                                          onChanged: (value) => setState(() {
                                            _selectedTime = value;
                                          }),
                                        ),
                                        Text(remindingTime.monthly
                                            .toShortString()),
                                      ],
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text("Time Selected"),
                                        Spacer(),
                                        RaisedButton(
                                          onPressed: () => _pickTime(),
                                          child: Text(
                                              _selectedTimeOfTheDayString !=
                                                      null
                                                  ? _selectedTimeOfTheDayString
                                                  : "Select Time"),
                                        ),
                                      ],
                                    ),
                                    RaisedButton(
                                      onPressed: () {
                                        Utilities.setStringInPref(
                                            "definterval", _selectedTime);
                                        Utilities.setStringInPref(
                                            'defRemindingTimeOfDay',
                                            _selectedTimeOfTheDayString);
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
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Default Time and Interval"),
              ),
            ),
          ),
          // Card(
          //   child: Padding(
          //     padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.center,
          //       children: <Widget>[
          //         Text("Zen Reader (Experimental)"),
          //         Spacer(),
          //         Switch(
          //           onChanged: (val) {
          //             setState(() {
          //               _zenReader = val;
          //               Utilities.setZenBool(val);
          //             });
          //           },
          //           value: _zenReader,
          //         )
          //       ],
          //     ),
          //   ),
          // ),
          Card(
            child: GestureDetector(
              onTap: () {
                openPrivacyPolicy();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Privacy Policy"),
              ),
            ),
          ),
          Card(
            child: GestureDetector(
              onTap: () {
                openFeaturesForm();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Request Features"),
              ),
            ),
          ),
          Card(
            child: GestureDetector(
              onTap: () {
                openRateApp();
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Rate App"),
              ),
            ),
          ),
        ],
      ),
    );
  }

  openPrivacyPolicy() {
    Utilities.launchInWebViewOrVC(PRIVACYPOLICYURL);
  }

  openFeaturesForm() {
    Utilities.launchInWebViewOrVC(FEATUREFORMURL);
  }

  openRateApp() {
    Utilities.launchInWebViewOrVC(RATEAPPURL);
  }
}
