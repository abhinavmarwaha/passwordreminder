import 'package:flutter/material.dart';
import 'package:passwordreminder/reminder_service.dart';
import 'package:passwordreminder/screens/home_screen.dart';
import 'package:passwordreminder/utilities/theme_changer.dart';
import 'package:provider/provider.dart';
import 'package:flutter_phoenix/flutter_phoenix.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(Phoenix(
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeChanger>(
        create: (_) => ThemeChanger(),
        child: Builder(builder: (context) {
          final theme = Provider.of<ThemeChanger>(context);
          setupServiceLocator();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Password Reminder',
            theme: theme.getTheme(),
            home: HomeScreen(title: 'Passwords'),
          );
        }));
  }
}
