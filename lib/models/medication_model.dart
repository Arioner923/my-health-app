/// Model class for a medication record.
///
/// Each medication record contains:
/// - unique id
/// - medication name
/// - dosage
/// - frequency
/// - start date
/// - end date
/// - ongoing flag
/// - notes
///
/// This follows the medication module requirements of the assignment.
class MedicationModel {
  final String id;
  final String medicationName;
  final String dosage;
  final String frequency;
  final String startDate;
  final String endDate;
  final bool ongoing;
  final String notes;

  const MedicationModel({
    required this.id,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    required this.endDate,
    required this.ongoing,
    required this.notes,
  });

  /// Converts the medication object into a Map.
  ///
  /// This is used before saving the medication as JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'medicationName': medicationName,
      'dosage': dosage,
      'frequency': frequency,
      'startDate': startDate,
      'endDate': endDate,
      'ongoing': ongoing,
      'notes': notes,
    };
  }

  /// Creates a MedicationModel object from a Map.
  ///
  /// This is used when loading saved medication data from local storage.
  factory MedicationModel.fromMap(Map<String, dynamic> map) {
    return MedicationModel(
      id: map['id'] ?? '',
      medicationName: map['medicationName'] ?? '',
      dosage: map['dosage'] ?? '',
      frequency: map['frequency'] ?? '',
      startDate: map['startDate'] ?? '',
      endDate: map['endDate'] ?? '',
      ongoing: map['ongoing'] ?? false,
      notes: map['notes'] ?? '',
    );
  }
}