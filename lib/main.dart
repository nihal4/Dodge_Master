import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/main_menu.dart'; // Import MainMenu widget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load the theme preference before the app starts
  final prefs = await SharedPreferences.getInstance();
  bool isDarkMode = prefs.getBool('darkMode') ?? false; // Default is false (light mode)

  runApp(MyApp(isDarkMode: isDarkMode));
}

class MyApp extends StatefulWidget {
  final bool isDarkMode;

  MyApp({required this.isDarkMode});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late bool _isDarkMode;

  @override
  void initState() {
    super.initState();
    _isDarkMode = widget.isDarkMode; // Initialize theme based on passed value
  }

  // Function to handle theme change
  void _onThemeChanged(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', isDarkMode); // Save the theme preference
    setState(() {
      _isDarkMode = isDarkMode; // Update the theme state immediately
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: _isDarkMode ? ThemeData.dark() : ThemeData.light(),
      home: MainMenu(onThemeChanged: _onThemeChanged), // Pass callback to MainMenu
    );
  }
}
