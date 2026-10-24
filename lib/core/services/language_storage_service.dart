import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for saving and loading the selected app language.
///
/// SharedPreferences is used because the selected language is a small
/// key-value setting and does not need a full database table.
class LanguageStorageService {
  /// Storage key used for the selected language.
  static const String _languageKey = 'selected_language';

  /// Saves the selected language code locally.
  ///
  /// Supported language codes:
  /// - 'en' for English
  /// - 'el' for Greek
  static Future<void> saveLanguage(String languageCode) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      /// Save only supported language codes.
      if (languageCode == 'en' || languageCode == 'el') {
        await prefs.setString(_languageKey, languageCode);
      }
    } catch (error) {
      /// If local storage fails, the app should continue running.
      /// This prevents the Settings module from crashing the application.
    }
  }

  /// Loads the saved language code from local storage.
  ///
  /// If no valid language has been saved yet, English is returned by default.
  static Future<String> loadLanguage() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      final String? savedLanguage = prefs.getString(_languageKey);

      if (savedLanguage == 'en') {
        return 'en';
      }

      if (savedLanguage == 'el') {
        return 'el';
      }

      /// Default language.
      return 'en';
    } catch (error) {
      /// If local storage fails, return English so the app can still start.
      return 'en';
    }
  }
}