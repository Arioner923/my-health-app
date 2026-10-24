import 'dart:convert';

import 'package:http/http.dart' as http;

/// Service class responsible for all external API calls.
///
/// This class keeps API logic outside the UI screens.
/// This makes the project cleaner, easier to test and easier to maintain.
class ApiService {
  /// Coordinates for Heraklion, Crete, Greece.
  ///
  /// These coordinates are used for weather and air quality API requests.
  static const double _heraklionLatitude = 35.3387;
  static const double _heraklionLongitude = 25.1442;

  /// Fetches one motivational message from a public quote API.
  ///
  /// The original assignment suggests ZenQuotes as an example API.
  /// However, when running the app in Flutter Web, some APIs may block browser
  /// requests because of CORS restrictions.
  ///
  /// For this reason, this implementation uses DummyJSON Quotes API,
  /// which provides a random quote endpoint that works well for development
  /// and testing.
  ///
  /// If the API request fails, the function returns a safe fallback message.
  /// This prevents the Home Dashboard from breaking when there is no internet
  /// connection or when the API is temporarily unavailable.
  static Future<String> fetchMotivationalMessage() async {
    try {
      final Uri url = Uri.parse('https://dummyjson.com/quotes/random');

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        /// DummyJSON returns:
        /// {
        ///   "id": 1,
        ///   "quote": "...",
        ///   "author": "..."
        /// }
        final String quote = decodedData['quote'] ?? '';
        final String author = decodedData['author'] ?? 'Unknown';

        if (quote.isNotEmpty) {
          return '"$quote" — $author';
        }
      }

      return 'Stay positive and take care of your health today.';
    } catch (error) {
      /// Fallback message used when the API cannot be reached.
      return 'Stay positive and take care of your health today.';
    }
  }

  /// Fetches the current temperature for Heraklion using Open-Meteo.
  ///
  /// The API returns current weather data in JSON format.
  /// If the request fails, the function returns null.
  static Future<double?> fetchHeraklionTemperature() async {
    try {
      final Uri url = Uri.parse(
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$_heraklionLatitude'
        '&longitude=$_heraklionLongitude'
        '&current=temperature_2m'
        '&timezone=auto',
      );

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        final dynamic currentData = decodedData['current'];

        if (currentData is Map<String, dynamic>) {
          final dynamic temperature = currentData['temperature_2m'];

          if (temperature is num) {
            return temperature.toDouble();
          }
        }
      }

      return null;
    } catch (error) {
      /// Returning null allows the UI to show an unavailable message.
      return null;
    }
  }

  /// Fetches the current European Air Quality Index for Heraklion.
  ///
  /// Open-Meteo Air Quality API provides pollution-related values.
  /// The European AQI is useful as a simple air-quality indicator.
  static Future<int?> fetchHeraklionAirQualityIndex() async {
    try {
      final Uri url = Uri.parse(
        'https://air-quality-api.open-meteo.com/v1/air-quality'
        '?latitude=$_heraklionLatitude'
        '&longitude=$_heraklionLongitude'
        '&current=european_aqi'
        '&timezone=auto',
      );

      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);

        final dynamic currentData = decodedData['current'];

        if (currentData is Map<String, dynamic>) {
          final dynamic aqi = currentData['european_aqi'];

          if (aqi is num) {
            return aqi.toInt();
          }
        }
      }

      return null;
    } catch (error) {
      /// Returning null allows the UI to handle API failure safely.
      return null;
    }
  }
}