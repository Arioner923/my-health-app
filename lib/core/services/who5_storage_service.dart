import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/who5_result_model.dart';

/// Service responsible for saving and loading WHO-5 questionnaire results.
///
/// For the current web-based development stage, SharedPreferences is used.
/// The data is stored as a JSON list so that multiple questionnaire results
/// can be saved over time.
class Who5StorageService {
  /// Storage key used for the WHO-5 result history.
  static const String _who5ResultsKey = 'who5_results';

  /// Saves a new WHO-5 result.
  ///
  /// The new result is added to the existing result history.
  static Future<void> saveResult(Who5ResultModel result) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<Who5ResultModel> existingResults = await loadResults();

    existingResults.add(result);

    final List<Map<String, dynamic>> encodedResults =
        existingResults.map((item) => item.toMap()).toList();

    await prefs.setString(_who5ResultsKey, jsonEncode(encodedResults));
  }

  /// Loads all saved WHO-5 results.
  ///
  /// Returns an empty list if no results have been saved yet.
  static Future<List<Who5ResultModel>> loadResults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_who5ResultsKey);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData
        .map((item) => Who5ResultModel.fromMap(item))
        .toList();
  }
}