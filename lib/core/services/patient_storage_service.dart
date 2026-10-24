import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/patient_model.dart';

/// Service responsible for saving and loading patient demographic data.
///
/// For the current web-based development stage, SharedPreferences is used.
/// Later, when running on Android, this can be migrated to SQLite if needed.
///
/// Keeping storage logic in a separate service keeps the UI clean.
class PatientStorageService {
  /// Storage key used to save patient data.
  static const String _patientKey = 'patient_demographics';

  /// Saves patient demographic data to local storage.
  static Future<void> savePatient(PatientModel patient) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    /// Convert the model to JSON string before saving it.
    final String encodedPatient = jsonEncode(patient.toMap());

    await prefs.setString(_patientKey, encodedPatient);
  }

  /// Loads patient demographic data from local storage.
  ///
  /// Returns null if no patient data has been saved yet.
  static Future<PatientModel?> loadPatient() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedPatient = prefs.getString(_patientKey);

    if (savedPatient == null) {
      return null;
    }

    final Map<String, dynamic> decodedPatient = jsonDecode(savedPatient);

    return PatientModel.fromMap(decodedPatient);
  }
}