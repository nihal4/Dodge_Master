import 'package:flutter/material.dart';

class ThemeSwitcher extends StatelessWidget {
  final Function(bool) onThemeChanged; // Callback to handle theme change

  ThemeSwitcher({required this.onThemeChanged}); // Constructor to pass callback

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: Theme.of(context).brightness == Brightness.dark, // Detect current theme
      onChanged: (bool value) {
        onThemeChanged(value); // Call the callback when theme is changed
      },
    );
  }
}
