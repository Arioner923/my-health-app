import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/medication_model.dart';

/// Service responsible for saving, loading and deleting medication records.
///
/// SharedPreferences is used for the current web-development stage.
/// The medication list is stored as a JSON list.
class MedicationStorageService {
  /// Storage key used for medication records.
  static const String _medicationsKey = 'medication_records';

  /// Saves a new medication record.
  static Future<void> saveMedication(MedicationModel medication) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<MedicationModel> existingMedications = await loadMedications();

    existingMedications.add(medication);

    final List<Map<String, dynamic>> encodedMedications =
        existingMedications.map((item) => item.toMap()).toList();

    await prefs.setString(_medicationsKey, jsonEncode(encodedMedications));
  }

  /// Loads all saved medication records.
  ///
  /// Returns an empty list if no medication has been saved yet.
  static Future<List<MedicationModel>> loadMedications() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_medicationsKey);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData
        .map((item) => MedicationModel.fromMap(item))
        .toList();
  }

  /// Deletes a medication record by its unique id.
  static Future<void> deleteMedication(String medicationId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<MedicationModel> existingMedications = await loadMedications();

    existingMedications.removeWhere((item) => item.id == medicationId);

    final List<Map<String, dynamic>> encodedMedications =
        existingMedications.map((item) => item.toMap()).toList();

    await prefs.setString(_medicationsKey, jsonEncode(encodedMedications));
  }
}