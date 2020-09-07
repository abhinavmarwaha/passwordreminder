import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:passwordreminder/utilities/theme_changer.dart';
import 'package:passwordreminder/utilities/utilities.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';

import '../constants.dart';
import '../models/reminder.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _auth = false;
  int hour, min;
  String _selectedTime;
  String _selectedTimeOfTheDayString;
  LocalAuthentication _localAuthentication;

  @override
  void initState() {
    _localAuthentication = LocalAuthentication();
    ThemeChanger.getDarkModePlainBool().then((value) {
      setState(() {
        _darkMode = value;
      });
    });
    Utilities.getAuthBool().then((value) {
      setState(() {
        _auth = value;
      });
    });
    Utilities.getDefRemindingTimeOfDay().then((value) => setState(() {
          _selectedTimeOfTheDayString = value;
          hour = int.parse(_selectedTimeOfTheDayString.split(":")[0]);
          min = int.parse(_selectedTimeOfTheDayString.split(":")[1]);
        }));
    Utilities.getDefInterval()
        .then((value) => setState(() => _selectedTime = value));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
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
            child: Padding(
              padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text("Fingerprint Lock"),
                  Spacer(),
                  Switch(
                    onChanged: (val) async {
                      bool didAuthenticate = await _localAuthentication
                          .authenticateWithBiometrics(localizedReason: "");
                      setState(() {
                        if (didAuthenticate) {
                          _auth = val;
                          Utilities.setBoolInPref("authBool", val);
                        }
                      });
                    },
                    value: _auth,
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
                        return Dialog(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0)),
                          child: SizedBox(
                            height: 500,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: <Widget>[
                                    RadioListTile(
                                      title: Text(
                                          reminding_time.daily.toShortString()),
                                      groupValue: _selectedTime,
                                      value:
                                          reminding_time.daily.toShortString(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTime = value;
                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      title: Text(reminding_time.triweekly
                                          .toShortString()),
                                      groupValue: _selectedTime,
                                      value: reminding_time.triweekly
                                          .toShortString(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedTime = value;
                                        });
                                      },
                                    ),
                                    RadioListTile(
                                      title: Text(reminding_time.biweekly
                                          .toShortString()),
                                      groupValue: _selectedTime,
                                      value: reminding_time.biweekly
                                          .toShortString(),
                                      onChanged: (value) => setState(() {
                                        _selectedTime = value;
                                      }),
                                    ),
                                    RadioListTile(
                                      title: Text(reminding_time.weekly
                                          .toShortString()),
                                      groupValue: _selectedTime,
                                      value:
                                          reminding_time.weekly.toShortString(),
                                      onChanged: (value) => setState(() {
                                        _selectedTime = value;
                                      }),
                                    ),
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
                                        _selectedTimeOfTheDayString =
                                            hour.toString() +
                                                ":" +
                                                min.toString();
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
