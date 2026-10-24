import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/problem_model.dart';

/// Service responsible for saving, loading and deleting problem list records.
///
/// SharedPreferences is used for the current web-development stage.
/// The problem list is stored as a JSON list.
class ProblemStorageService {
  /// Storage key used for problem list records.
  static const String _problemsKey = 'problem_list_records';

  /// Saves a new problem entry.
  static Future<void> saveProblem(ProblemModel problem) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<ProblemModel> existingProblems = await loadProblems();

    existingProblems.add(problem);

    final List<Map<String, dynamic>> encodedProblems =
        existingProblems.map((item) => item.toMap()).toList();

    await prefs.setString(_problemsKey, jsonEncode(encodedProblems));
  }

  /// Loads all saved problem entries.
  ///
  /// Returns an empty list if no problem has been saved yet.
  static Future<List<ProblemModel>> loadProblems() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_problemsKey);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData.map((item) => ProblemModel.fromMap(item)).toList();
  }

  /// Deletes a problem entry by its unique id.
  static Future<void> deleteProblem(String problemId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<ProblemModel> existingProblems = await loadProblems();

    existingProblems.removeWhere((item) => item.id == problemId);

    final List<Map<String, dynamic>> encodedProblems =
        existingProblems.map((item) => item.toMap()).toList();

    await prefs.setString(_problemsKey, jsonEncode(encodedProblems));
  }
}