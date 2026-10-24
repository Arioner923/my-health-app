import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/allergy_model.dart';

/// Service responsible for saving, loading and deleting allergy records.
///
/// SharedPreferences is used for the current web-development stage.
/// The allergy list is stored as a JSON list.
class AllergyStorageService {
  /// Storage key used for allergy records.
  static const String _allergiesKey = 'allergy_records';

  /// Saves a new allergy record.
  static Future<void> saveAllergy(AllergyModel allergy) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<AllergyModel> existingAllergies = await loadAllergies();

    existingAllergies.add(allergy);

    final List<Map<String, dynamic>> encodedAllergies =
        existingAllergies.map((item) => item.toMap()).toList();

    await prefs.setString(_allergiesKey, jsonEncode(encodedAllergies));
  }

  /// Loads all saved allergy records.
  ///
  /// Returns an empty list if no allergy has been saved yet.
  static Future<List<AllergyModel>> loadAllergies() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_allergiesKey);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((item) => AllergyModel.fromMap(item)).toList();
  }

  /// Deletes an allergy record by its unique id.
  static Future<void> deleteAllergy(String allergyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<AllergyModel> existingAllergies = await loadAllergies();

    existingAllergies.removeWhere((item) => item.id == allergyId);

    final List<Map<String, dynamic>> encodedAllergies =
        existingAllergies.map((item) => item.toMap()).toList();

    await prefs.setString(_allergiesKey, jsonEncode(encodedAllergies));
  }
}