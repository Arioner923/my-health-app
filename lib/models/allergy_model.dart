/// Model class for an allergy record.
///
/// Each allergy record contains:
/// - unique id
/// - allergen name
/// - reaction description
/// - severity
/// - onset date
/// - notes
///
/// This follows the allergy module requirements of the assignment.
class AllergyModel {
  final String id;
  final String allergenName;
  final String reactionDescription;
  final String severity;
  final String onsetDate;
  final String notes;

  const AllergyModel({
    required this.id,
    required this.allergenName,
    required this.reactionDescription,
    required this.severity,
    required this.onsetDate,
    required this.notes,
  });

  /// Converts the allergy object into a Map.
  ///
  /// This is used before saving the allergy as JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'allergenName': allergenName,
      'reactionDescription': reactionDescription,
      'severity': severity,
      'onsetDate': onsetDate,
      'notes': notes,
    };
  }

  /// Creates an AllergyModel object from a Map.
  ///
  /// This is used when loading saved allergy data from local storage.
  factory AllergyModel.fromMap(Map<String, dynamic> map) {
    return AllergyModel(
      id: map['id'] ?? '',
      allergenName: map['allergenName'] ?? '',
      reactionDescription: map['reactionDescription'] ?? '',
      severity: map['severity'] ?? '',
      onsetDate: map['onsetDate'] ?? '',
      notes: map['notes'] ?? '',
    );
  }
}