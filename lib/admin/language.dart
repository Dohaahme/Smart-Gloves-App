import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'ar/strings.dart'; // Import Arabic translations
import 'en/english.dart'; // Import English translations

class LanguageProvider extends ChangeNotifier {
  Locale _appLocale = Locale('en');
  Map<String, String> _localizedStrings = {};

  Locale get appLocale => _appLocale;

  Map<String, String> get localizedStrings => _localizedStrings;

  void changeLanguage(Locale locale) async {
    _appLocale = locale;
    _loadLocalizedStrings(locale.languageCode);
    notifyListeners();

    // Save the language preference to shared preferences
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', locale.languageCode);
  }

  // Constructor to initialize the language preference
  LanguageProvider() {
    _loadLanguagePreference();
  }

  // Function to load the language preference from shared preferences
  void _loadLanguagePreference() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? 'en';
    _appLocale = Locale(languageCode);
    _loadLocalizedStrings(languageCode);
    notifyListeners();
  }

  void _loadLocalizedStrings(String languageCode) {
    if (languageCode == 'ar') {
      _localizedStrings = arabicStrings;
    } else {
      // Load English translations by default
      _localizedStrings = englishStrings;
    }
  }
}
