/// Model class for a saved FINDRISC result.
///
/// FINDRISC estimates the risk of developing type 2 diabetes.
/// This model stores:
/// - each selected score component
/// - the total FINDRISC score
/// - the risk category
/// - the calculation date
class FindriscResultModel {
  final String gender;
  final int ageScore;
  final int bmiScore;
  final int waistScore;
  final int activityScore;
  final int dietScore;
  final int bpMedicationScore;
  final int glucoseScore;
  final int familyHistoryScore;
  final int totalScore;
  final String riskCategory;
  final String date;

  const FindriscResultModel({
    required this.gender,
    required this.ageScore,
    required this.bmiScore,
    required this.waistScore,
    required this.activityScore,
    required this.dietScore,
    required this.bpMedicationScore,
    required this.glucoseScore,
    required this.familyHistoryScore,
    required this.totalScore,
    required this.riskCategory,
    required this.date,
  });

  /// Converts the result object into a Map.
  ///
  /// This allows the object to be saved as JSON in local storage.
  Map<String, dynamic> toMap() {
    return {
      'gender': gender,
      'ageScore': ageScore,
      'bmiScore': bmiScore,
      'waistScore': waistScore,
      'activityScore': activityScore,
      'dietScore': dietScore,
      'bpMedicationScore': bpMedicationScore,
      'glucoseScore': glucoseScore,
      'familyHistoryScore': familyHistoryScore,
      'totalScore': totalScore,
      'riskCategory': riskCategory,
      'date': date,
    };
  }

  /// Creates a FindriscResultModel object from a Map.
  ///
  /// This is used when loading saved JSON data from local storage.
  factory FindriscResultModel.fromMap(Map<String, dynamic> map) {
    return FindriscResultModel(
      gender: map['gender'] ?? '',
      ageScore: map['ageScore'] ?? 0,
      bmiScore: map['bmiScore'] ?? 0,
      waistScore: map['waistScore'] ?? 0,
      activityScore: map['activityScore'] ?? 0,
      dietScore: map['dietScore'] ?? 0,
      bpMedicationScore: map['bpMedicationScore'] ?? 0,
      glucoseScore: map['glucoseScore'] ?? 0,
      familyHistoryScore: map['familyHistoryScore'] ?? 0,
      totalScore: map['totalScore'] ?? 0,
      riskCategory: map['riskCategory'] ?? '',
      date: map['date'] ?? '',
    );
  }
}