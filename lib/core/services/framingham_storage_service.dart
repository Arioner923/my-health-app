import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/framingham_result_model.dart';

/// Service responsible for saving and loading Framingham score results.
///
/// SharedPreferences is used for the current web-development stage.
/// Results are stored as a JSON list so multiple calculations can be saved.
class FraminghamStorageService {
  /// Storage key used for Framingham result history.
  static const String _framinghamResultsKey = 'framingham_results';

  /// Saves a new Framingham result.
  ///
  /// The new result is appended to the existing history.
  static Future<void> saveResult(FraminghamResultModel result) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<FraminghamResultModel> existingResults = await loadResults();

    existingResults.add(result);

    final List<Map<String, dynamic>> encodedResults =
        existingResults.map((item) => item.toMap()).toList();

    await prefs.setString(_framinghamResultsKey, jsonEncode(encodedResults));
  }

  /// Loads all saved Framingham results.
  ///
  /// Returns an empty list if no result exists.
  static Future<List<FraminghamResultModel>> loadResults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_framinghamResultsKey);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData
        .map((item) => FraminghamResultModel.fromMap(item))
        .toList();
  }
}