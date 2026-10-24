import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/health_event_model.dart';

/// Service responsible for saving, loading and deleting health calendar events.
///
/// SharedPreferences is used for the current web-development stage.
/// Calendar events are stored as a JSON list.
class HealthEventStorageService {
  /// Storage key used for calendar events.
  static const String _eventsKey = 'health_calendar_events';

  /// Saves a new health event.
  static Future<void> saveEvent(HealthEventModel event) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<HealthEventModel> existingEvents = await loadEvents();

    existingEvents.add(event);

    final List<Map<String, dynamic>> encodedEvents =
        existingEvents.map((item) => item.toMap()).toList();

    await prefs.setString(_eventsKey, jsonEncode(encodedEvents));
  }

  /// Loads all saved health events.
  ///
  /// Returns an empty list if no event has been saved yet.
  static Future<List<HealthEventModel>> loadEvents() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? savedData = prefs.getString(_eventsKey);

    if (savedData == null) {
      return [];
    }

    final List<dynamic> decodedData = jsonDecode(savedData);

    return decodedData
        .map((item) => HealthEventModel.fromMap(item))
        .toList();
  }

  /// Deletes a health event by its unique id.
  static Future<void> deleteEvent(String eventId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<HealthEventModel> existingEvents = await loadEvents();

    existingEvents.removeWhere((item) => item.id == eventId);

    final List<Map<String, dynamic>> encodedEvents =
        existingEvents.map((item) => item.toMap()).toList();

    await prefs.setString(_eventsKey, jsonEncode(encodedEvents));
  }
}