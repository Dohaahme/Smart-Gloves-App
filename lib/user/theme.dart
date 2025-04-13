import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;

  bool get isDarkMode => _isDarkMode;

  ThemeData get themeData => _isDarkMode ? _darkTheme : _lightTheme;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _saveThemeMode(_isDarkMode); // Save theme mode when toggled
    notifyListeners();
  }

  Future<void> _saveThemeMode(bool isDarkMode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }

  Future<void> loadThemeMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Define light theme
  final ThemeData _lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: Colors.blue, // Change primary color to blue
    colorScheme: ColorScheme.light(
      primary: Colors.blue, // Define primary color for light theme
      secondary: Colors.blueAccent, // Define secondary color for light theme
    ),
    // Define more properties for light theme as needed
  );

  // Define dark theme
  final ThemeData _darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: Colors.blue, // Change primary color to blue
    colorScheme: ColorScheme.dark(
      primary: Colors.blue, // Define primary color for dark theme
      secondary: Colors.blueAccent, // Define secondary color for dark theme
    ),
    // Define more properties for dark theme as needed
  );
}
