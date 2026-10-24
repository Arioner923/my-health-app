/// Model class for a health calendar event.
///
/// Each event contains:
/// - unique id
/// - title
/// - type
/// - date
/// - description
///
/// The date is stored as a String in YYYY-MM-DD format so it can be
/// easily saved in local storage and displayed in the calendar.
class HealthEventModel {
  final String id;
  final String title;
  final String type;
  final String date;
  final String description;

  const HealthEventModel({
    required this.id,
    required this.title,
    required this.type,
    required this.date,
    required this.description,
  });

  /// Converts the event object into a Map.
  ///
  /// This is used before saving the event as JSON.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'date': date,
      'description': description,
    };
  }

  /// Creates a HealthEventModel object from a Map.
  ///
  /// This is used when loading saved calendar events from local storage.
  factory HealthEventModel.fromMap(Map<String, dynamic> map) {
    return HealthEventModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      type: map['type'] ?? '',
      date: map['date'] ?? '',
      description: map['description'] ?? '',
    );
  }
}