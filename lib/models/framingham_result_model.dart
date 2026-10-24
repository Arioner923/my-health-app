/// Model class for a saved Framingham risk score result.
///
/// This model stores:
/// - input values used in the calculation
/// - total risk points
/// - estimated 10-year risk percentage
/// - risk category
/// - date of calculation
class FraminghamResultModel {
  final int age;
  final String gender;
  final int totalCholesterol;
  final int hdlCholesterol;
  final int systolicBp;
  final bool treatedBp;
  final bool smoker;
  final bool diabetes;
  final int riskPoints;
  final double riskPercentage;
  final String riskCategory;
  final String date;

  const FraminghamResultModel({
    required this.age,
    required this.gender,
    required this.totalCholesterol,
    required this.hdlCholesterol,
    required this.systolicBp,
    required this.treatedBp,
    required this.smoker,
    required this.diabetes,
    required this.riskPoints,
    required this.riskPercentage,
    required this.riskCategory,
    required this.date,
  });

  /// Converts the result object into a Map.
  ///
  /// This allows the object to be saved as JSON.
  Map<String, dynamic> toMap() {
    return {
      'age': age,
      'gender': gender,
      'totalCholesterol': totalCholesterol,
      'hdlCholesterol': hdlCholesterol,
      'systolicBp': systolicBp,
      'treatedBp': treatedBp,
      'smoker': smoker,
      'diabetes': diabetes,
      'riskPoints': riskPoints,
      'riskPercentage': riskPercentage,
      'riskCategory': riskCategory,
      'date': date,
    };
  }

  /// Creates a FraminghamResultModel object from a Map.
  ///
  /// This is used when reading saved JSON data from local storage.
  factory FraminghamResultModel.fromMap(Map<String, dynamic> map) {
    return FraminghamResultModel(
      age: map['age'] ?? 0,
      gender: map['gender'] ?? '',
      totalCholesterol: map['totalCholesterol'] ?? 0,
      hdlCholesterol: map['hdlCholesterol'] ?? 0,
      systolicBp: map['systolicBp'] ?? 0,
      treatedBp: map['treatedBp'] ?? false,
      smoker: map['smoker'] ?? false,
      diabetes: map['diabetes'] ?? false,
      riskPoints: map['riskPoints'] ?? 0,
      riskPercentage: (map['riskPercentage'] ?? 0).toDouble(),
      riskCategory: map['riskCategory'] ?? '',
      date: map['date'] ?? '',
    );
  }
}