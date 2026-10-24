import '../../models/health_event_model.dart';
import 'health_event_storage_service.dart';

/// Service responsible for automatically creating calendar events
/// when important health actions are completed.
///
/// This connects the app modules with the Health Calendar module.
/// Examples:
/// - WHO-5 completed
/// - Framingham score calculated
/// - FINDRISC score calculated
/// - Medication added
/// - Allergy recorded
/// - Problem added
class CalendarAutoEventService {
  /// Creates and saves a calendar event.
  ///
  /// If the provided date is invalid or empty, today's date is used.
  static Future<void> createCalendarEvent({
    required String title,
    required String type,
    required String date,
    required String description,
  }) async {
    final String safeDate = _isValidDate(date) ? date : today();

    final HealthEventModel event = HealthEventModel(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: title,
      type: type,
      date: safeDate,
      description: description,
    );

    await HealthEventStorageService.saveEvent(event);
  }

  /// Returns today's date in YYYY-MM-DD format.
  static String today() {
    final DateTime now = DateTime.now();

    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Checks if a date string can be parsed safely.
  static bool _isValidDate(String date) {
    try {
      if (date.trim().isEmpty) {
        return false;
      }

      DateTime.parse(date);
      return true;
    } catch (error) {
      return false;
    }
  }
}