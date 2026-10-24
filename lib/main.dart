import 'package:flutter/material.dart';

import 'core/services/language_storage_service.dart';
import 'localization/app_strings.dart';

import 'screens/allergies_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/charts_screen.dart';
import 'screens/demographics_screen.dart';
import 'screens/findrisc_screen.dart';
import 'screens/framingham_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/medications_screen.dart';
import 'screens/problem_list_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/who5_screen.dart';

/// Entry point of the Flutter application.
///
/// WidgetsFlutterBinding.ensureInitialized() makes sure Flutter is ready
/// before using plugins such as SharedPreferences.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyHealthApp());
}

/// Root widget of the application.
///
/// This widget is Stateful because the selected language can change while
/// the app is running.
class MyHealthApp extends StatefulWidget {
  const MyHealthApp({super.key});

  @override
  State<MyHealthApp> createState() => _MyHealthAppState();
}

class _MyHealthAppState extends State<MyHealthApp> {
  /// Indicates whether the saved language is still loading.
  bool _isLoadingLanguage = true;

  @override
  void initState() {
    super.initState();

    /// Load saved language when the app starts.
    _loadSavedLanguage();
  }

  /// Loads the saved language from local storage.
  ///
  /// If loading fails, English is used as the default language.
  Future<void> _loadSavedLanguage() async {
    try {
      final String savedLanguage = await LanguageStorageService.loadLanguage();

      AppStrings.currentLanguage = savedLanguage;
    } catch (error) {
      /// Safe fallback if SharedPreferences fails for any reason.
      AppStrings.currentLanguage = 'en';
    }

    if (!mounted) return;

    setState(() {
      _isLoadingLanguage = false;
    });
  }

  /// Changes the app language and saves it locally.
  void changeLanguage(String languageCode) {
    if (languageCode != 'en' && languageCode != 'el') {
      return;
    }

    AppStrings.currentLanguage = languageCode;

    /// Save the selected language.
    LanguageStorageService.saveLanguage(languageCode);

    /// Rebuild the app so all visible text updates.
    setState(() {});
  }

  /// Creates routes manually.
  ///
  /// This is safer for Flutter Web than relying only on initialRoute/routes,
  /// because it avoids null route lookups.
  Route<dynamic> _buildRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) => LoginScreen(
            onLanguageChanged: changeLanguage,
          ),
        );

      case '/home':
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            onLanguageChanged: changeLanguage,
          ),
        );

      case '/demographics':
        return MaterialPageRoute(
          builder: (_) => const DemographicsScreen(),
        );

      case '/who5':
        return MaterialPageRoute(
          builder: (_) => const Who5Screen(),
        );

      case '/framingham':
        return MaterialPageRoute(
          builder: (_) => const FraminghamScreen(),
        );

      case '/findrisc':
        return MaterialPageRoute(
          builder: (_) => const FindriscScreen(),
        );

      case '/allergies':
        return MaterialPageRoute(
          builder: (_) => const AllergiesScreen(),
        );

      case '/medications':
        return MaterialPageRoute(
          builder: (_) => const MedicationsScreen(),
        );

      case '/problems':
        return MaterialPageRoute(
          builder: (_) => const ProblemListScreen(),
        );

      case '/calendar':
        return MaterialPageRoute(
          builder: (_) => const CalendarScreen(),
        );

      case '/charts':
        return MaterialPageRoute(
          builder: (_) => const ChartsScreen(),
        );

      case '/settings':
        return MaterialPageRoute(
          builder: (_) => SettingsScreen(
            onLanguageChanged: changeLanguage,
          ),
        );

      default:
        /// If an unknown route is requested, return to the login screen.
        return MaterialPageRoute(
          builder: (_) => LoginScreen(
            onLanguageChanged: changeLanguage,
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    /// Show a simple loading screen while the saved language is loading.
    if (_isLoadingLanguage) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return MaterialApp(
      title: AppStrings.get('appTitle'),
      debugShowCheckedModeBanner: false,

      /// Basic Material 3 theme.
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),

      /// The app always starts from the LoginScreen.
      ///
      /// Navigation to the rest of the screens is handled by onGenerateRoute.
      home: LoginScreen(
        onLanguageChanged: changeLanguage,
      ),

      /// Manual route generator for all app screens.
      onGenerateRoute: _buildRoute,
    );
  }
}