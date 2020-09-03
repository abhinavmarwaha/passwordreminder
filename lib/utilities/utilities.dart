import 'package:passwordreminder/models/reminder.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:password/password.dart';
import 'package:intl/intl.dart';

class Utilities {
  static Future<void> launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        forceSafariVC: false,
        forceWebView: false,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
    }
  }

  static void vibrate() async {
    if (await Vibration.hasVibrator()) {
      Vibration.vibrate(duration: 70, amplitude: 10);
    }
  }

  static Future<String> getDefInterval() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String definterval;
    if (prefs.containsKey('definterval'))
      definterval = prefs.getString('definterval');
    else {
      await prefs.setString(
          'definterval', reminding_time.daily.toShortString());
      definterval = reminding_time.daily.toShortString();
    }
    return definterval;
  }

  static Future<String> getDefRemindingTimeOfDay() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String defRemindingTimeOfDay;
    if (prefs.containsKey('defRemindingTimeOfDay'))
      defRemindingTimeOfDay = prefs.getString('defRemindingTimeOfDay');
    else {
      await prefs.setString('defRemindingTimeOfDay', "21:00");
      defRemindingTimeOfDay = reminding_time.daily.toShortString();
    }
    return defRemindingTimeOfDay;
  }

  static Future<bool> setStringInPref(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static String hash(String psswd) {
    final algorithm = PBKDF2();
    return Password.hash(psswd, algorithm);
  }

  static bool verify(String psswd, String hash) {
    return Password.verify(psswd, hash);
  }

  static String formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyyMMdd');
    return formatter.format(date);
  }
}
