import 'package:flutter/material.dart';
import 'package:passwordreminder/reminder_service.dart';
import 'package:passwordreminder/screens/home_screen.dart';
import 'package:passwordreminder/utilities/theme_changer.dart';
import 'package:provider/provider.dart';

void main() {
  setupServiceLocator();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    return ChangeNotifierProvider<ThemeChanger>(
        create: (_) => ThemeChanger(),
        child: Builder(builder: (context) {
          return MaterialApp(
            title: 'Password Reminder',
            theme: theme.getTheme(),
            home: HomeScreen(title: 'Passwords'),
          );
        }));
  }
}

// ThemeData(
//         primarySwatch: Colors.blue,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
