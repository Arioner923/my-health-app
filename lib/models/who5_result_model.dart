/// Model class for a saved WHO-5 questionnaire result.
///
/// The WHO-5 result stores:
/// - the five answers
/// - the raw score from 0 to 25
/// - the percentage score from 0 to 100
/// - the interpretation category
/// - the date of completion
class Who5ResultModel {
  final List<int> answers;
  final int rawScore;
  final int percentageScore;
  final String category;
  final String date;

  const Who5ResultModel({
    required this.answers,
    required this.rawScore,
    required this.percentageScore,
    required this.category,
    required this.date,
  });

  /// Converts the result object into a Map.
  ///
  /// This is used before saving the result as JSON.
  Map<String, dynamic> toMap() {
    return {
      'answers': answers,
      'rawScore': rawScore,
      'percentageScore': percentageScore,
      'category': category,
      'date': date,
    };
  }

  /// Creates a Who5ResultModel object from a Map.
  ///
  /// This is used when loading saved JSON data from local storage.
  factory Who5ResultModel.fromMap(Map<String, dynamic> map) {
    return Who5ResultModel(
      answers: List<int>.from(map['answers'] ?? []),
      rawScore: map['rawScore'] ?? 0,
      percentageScore: map['percentageScore'] ?? 0,
      category: map['category'] ?? '',
      date: map['date'] ?? '',
    );
  }
}