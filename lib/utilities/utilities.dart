import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:password/password.dart';

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

  static Future<bool> getZenBool() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool zenBool;
    if (prefs.containsKey('zenBool'))
      zenBool = prefs.getBool('zenBool');
    else {
      await prefs.setBool('zenBool', false);
      zenBool = false;
    }
    return zenBool;
  }

  static Future<bool> setZenBool(bool _zen) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setBool('zenBool', _zen);
  }

  static String hash(String psswd) {
    final algorithm = PBKDF2();
    return Password.hash(psswd, algorithm);
  }

  static bool verify(String psswd, String hash) {
    return Password.verify(psswd, hash);
  }
}
