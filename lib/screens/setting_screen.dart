import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  final Function(bool) onThemeChanged;

  SettingsScreen({required this.onThemeChanged});

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingsScreen> {
  bool _isDarkMode = false;
  double _brightness = 1.0;
  double _contrast = 1.0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  // Load preferences when the screen is initialized
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('darkMode') ?? false;
      _brightness = prefs.getDouble('brightness') ?? 1.0;
      _contrast = prefs.getDouble('contrast') ?? 1.0;
    });

    // Call onThemeChanged with the loaded value to update the theme immediately
    widget.onThemeChanged(_isDarkMode);
  }

  // Save preferences when dark mode or other settings are changed
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('darkMode', _isDarkMode);
    prefs.setDouble('brightness', _brightness);
    prefs.setDouble('contrast', _contrast);
  }

  @override
  Widget build(BuildContext context) {
    // Set colors based on theme mode
    Color appBarColor = _isDarkMode ? Colors.black : Colors.white;
    Color backgroundColor = _isDarkMode ? Colors.black : Colors.white;
    Color textColor = _isDarkMode ? Colors.white : Colors.black;
    Color sliderActiveColor = _isDarkMode ? Colors.green : Colors.blue;
    Color buttonColor = _isDarkMode ? Colors.black : Colors.blue;
    Color buttonTextColor = _isDarkMode ? Colors.green : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings", style: TextStyle(fontFamily: 'PressStart2P', fontSize: 24, color: textColor)),
        backgroundColor: appBarColor,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Dark Mode Switch
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Dark Mode",
                    style: TextStyle(fontFamily: 'PressStart2P', fontSize: 18, color: textColor),
                  ),
                  Switch(
                    value: _isDarkMode,
                    onChanged: (value) {
                      setState(() {
                        _isDarkMode = value;
                        _savePreferences();
                      });
                      widget.onThemeChanged(_isDarkMode);
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Brightness Slider
              Text(
                "Brightness",
                style: TextStyle(fontFamily: 'PressStart2P', fontSize: 18, color: textColor),
              ),
              Slider(
                activeColor: sliderActiveColor,
                inactiveColor: _isDarkMode ? Colors.grey : Colors.black45,
                value: _brightness,
                min: 0.5,
                max: 1.5,
                onChanged: (value) {
                  setState(() {
                    _brightness = value;
                    _savePreferences();
                  });
                },
              ),
              SizedBox(height: 10),

              // Contrast Slider
              Text(
                "Contrast",
                style: TextStyle(fontFamily: 'PressStart2P', fontSize: 18, color: textColor),
              ),
              Slider(
                activeColor: sliderActiveColor,
                inactiveColor: _isDarkMode ? Colors.grey : Colors.black45,
                value: _contrast,
                min: 0.5,
                max: 1.5,
                onChanged: (value) {
                  setState(() {
                    _contrast = value;
                    _savePreferences();
                  });
                },
              ),
              SizedBox(height: 30),

              // Retro-Styled Button
              ElevatedButton(
                onPressed: () {
                  // Implement your button action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor,
                  foregroundColor: buttonTextColor,
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  "Save Settings",
                  style: TextStyle(fontFamily: 'PressStart2P', fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: backgroundColor,
    );
  }
}
