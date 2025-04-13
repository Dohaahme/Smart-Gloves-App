import 'package:flutter/material.dart';
import 'package:test_gproject/HomePage.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import your main screen file
Future<void> saveThemeMode(bool isDarkMode) async {
  final prefs = await SharedPreferences.getInstance();
  prefs.setBool('isDarkMode', isDarkMode);
}
Future<bool> loadThemeMode() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('isDarkMode') ?? false; // Default to false if not found
}


class Splach extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Splash Screen Demo',
      home: SplashScreen(), // Set SplashScreen as the initial route
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for 2 seconds and then navigate to the main screen
    Future.delayed(Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyApp()), // Navigate to MainScreen
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image.asset('lib/assets/icon2.png',fit: BoxFit.cover), // Display the splash screen image
      ),
    );
  }
}