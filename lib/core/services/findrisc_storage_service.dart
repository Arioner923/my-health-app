import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/findrisc_result_model.dart';

/// Service responsible for saving and loading FINDRISC results.
///
/// SharedPreferences is used for the current web-development stage.
/// Results are stored as a JSON list, so the app can keep a history
/// of multiple calculations over time.
class FindriscStorageService {
  /// Storage key used for FINDRISC result history.
  static const String _findriscResultsKey = 'findrisc_results';

  /// Saves a new FINDRISC result.
  ///
  /// The new result is appended to the existing saved history.
  static Future<void> saveResult(FindriscResultModel result) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<FindriscResultModel> existingResults = await loadResults();

    existingResults.add(result);

    final List<Map<String, dynamic>> encodedResults =
        existingResults.map((item) => item.toMap()).toList();

    await prefs.setString(_findriscResultsKey, jsonEncode(encodedResults));
  }

  /// Loads all saved FINDRISC results.
  ///
  /// Returns an empty list if no results have been saved yet.
  static Future<List<FindriscResultModel>> loadResults() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_findriscResultsKey);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData
        .map((item) => FindriscResultModel.fromMap(item))
        .toList();
  }
}