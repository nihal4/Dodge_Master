import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'setting_screen.dart'; // Import Settings Screen
import 'package:flutter/services.dart'; // Add this import for SystemNavigator
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences

class MainMenu extends StatefulWidget {
  final Function(bool) onThemeChanged;

  MainMenu({required this.onThemeChanged});

  @override
  _MainMenuState createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    _loadTheme(); // Load the saved theme preference
  }

  // Load the saved theme preference from SharedPreferences
  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance(); // Get the shared preferences instance
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false; // Default to light mode if not found
    });
  }

  // Callback function to handle theme change
  void _onThemeChanged(bool isDarkMode) {
    setState(() {
      _isDarkMode = isDarkMode;
    });
    widget.onThemeChanged(isDarkMode); // Propagate theme change to main app
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isDarkMode ? Colors.black : Colors.white, // Switch background color based on theme
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Dodge Master",
              style: TextStyle(
                fontFamily: 'PressStart2P', // Use the local font family
                color: _isDarkMode ? Colors.white : Colors.black, // Adjust text color based on theme
                fontSize: 24,
                shadows: [
                  Shadow(
                    offset: Offset(3, 3),
                    blurRadius: 4,
                    color: _isDarkMode ? Colors.blueAccent : Colors.grey,
                  ),
                ],
              ),
            ),
            SizedBox(height: 40),
            Column(
              children: [
                _buildMenuButton(
                  context,
                  "Play",
                  Colors.green,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GameScreen()),
                  ),
                ),
                SizedBox(height: 25),
                _buildMenuButton(
                  context,
                  "Settings",
                  Colors.orange,
                      () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SettingsScreen(onThemeChanged: _onThemeChanged),
                    ),
                  ),
                ),
                SizedBox(height: 25),
                _buildMenuButton(
                  context,
                  "Exit",
                  Colors.red,
                      () => SystemNavigator.pop(), // Close the app
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(
      BuildContext context,
      String text,
      Color color,
      VoidCallback onPressed,
      ) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        shadowColor: Colors.white,
        elevation: 10,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'PressStart2P', // Use the local font family
          color: _isDarkMode ? Colors.white : Colors.black,
          shadows: [
            Shadow(
              offset: Offset(2, 2),
              blurRadius: 4,
              color: _isDarkMode ? Colors.black : Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
