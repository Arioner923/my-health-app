/// Model class for a patient problem list entry.
///
/// Each problem entry contains:
/// - unique id
/// - ICD-10 code
/// - diagnosis/problem title
/// - status
/// - date added
/// - notes
///
/// This follows the Problem List requirements of the assignment.
class ProblemModel {
  final String id;
  final String icdCode;
  final String title;
  final String status;
  final String dateAdded;
  final String notes;

  const ProblemModel({
    required this.id,
    required this.icdCode,
    required this.title,
    required this.status,
    required this.dateAdded,
    required this.notes,
  });

  /// Converts the problem object into a Map.
  ///
  /// This is used before saving the problem as JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'icdCode': icdCode,
      'title': title,
      'status': status,
      'dateAdded': dateAdded,
      'notes': notes,
    };
  }

  /// Creates a ProblemModel object from a Map.
  ///
  /// This is used when loading saved problem data from local storage.
  factory ProblemModel.fromMap(Map<String, dynamic> map) {
    return ProblemModel(
      id: map['id'] ?? '',
      icdCode: map['icdCode'] ?? '',
      title: map['title'] ?? '',
      status: map['status'] ?? '',
      dateAdded: map['dateAdded'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}