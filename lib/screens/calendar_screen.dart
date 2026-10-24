import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

import '../core/services/health_event_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/health_event_model.dart';

/// Screen for the Health Calendar module.
///
/// The user can:
/// - view a monthly calendar
/// - select a day
/// - add health-related events
/// - view events for the selected day
/// - delete events
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  /// Form key used for validating event input fields.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Text controllers for event fields.
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  /// Currently focused month in the calendar.
  DateTime _focusedDay = DateTime.now();

  /// Currently selected day in the calendar.
  DateTime _selectedDay = DateTime.now();

  /// Selected event type.
  String _selectedEventType = 'General';

  /// Saved health events.
  List<HealthEventModel> _events = [];

  /// Shows whether saved events are being loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Set today's date as the default event date.
    _dateController.text = _formatDate(DateTime.now());

    /// Load saved events when the screen opens.
    _loadEvents();
  }

  @override
  void dispose() {
    /// Dispose controllers to prevent memory leaks.
    _titleController.dispose();
    _dateController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  /// Loads all saved calendar events from local storage.
  Future<void> _loadEvents() async {
    final List<HealthEventModel> savedEvents =
        await HealthEventStorageService.loadEvents();

    if (!mounted) return;

    setState(() {
      _events = savedEvents;
      _isLoading = false;
    });
  }

  /// Formats a DateTime object as YYYY-MM-DD.
  String _formatDate(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Returns all events for a specific calendar day.
  List<HealthEventModel> _eventsForDay(DateTime day) {
    return _events.where((event) {
      final DateTime eventDate = DateTime.parse(event.date);

      return isSameDay(eventDate, day);
    }).toList();
  }

  /// Opens a date picker and stores the selected event date.
  Future<void> _selectEventDate() async {
    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (selectedDate == null) return;

    setState(() {
      _selectedDay = selectedDate;
      _focusedDay = selectedDate;
      _dateController.text = _formatDate(selectedDate);
    });
  }

  /// Saves a new calendar event.
  Future<void> _addEvent() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    /// Timestamp is used as a simple unique id.
    final String eventId = DateTime.now().millisecondsSinceEpoch.toString();

    final HealthEventModel event = HealthEventModel(
      id: eventId,
      title: _titleController.text.trim(),
      type: _selectedEventType,
      date: _dateController.text.trim(),
      description: _descriptionController.text.trim(),
    );

    await HealthEventStorageService.saveEvent(event);

    /// Clear input fields after saving.
    _titleController.clear();
    _descriptionController.clear();

    setState(() {
      _selectedEventType = 'General';
    });

    await _loadEvents();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('savedSuccessfully')),
      ),
    );
  }

  /// Deletes a calendar event.
  Future<void> _deleteEvent(String eventId) async {
    await HealthEventStorageService.deleteEvent(eventId);

    await _loadEvents();
  }

  /// Common validator for required text fields.
  String? _requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.get('pleaseFillField');
    }

    return null;
  }

  /// Converts the internal event type value into a localized label.
  String _localizedEventType(String type) {
    switch (type) {
      case 'Appointment':
        return AppStrings.get('appointment');
      case 'Medication':
        return AppStrings.get('medications');
      case 'Questionnaire':
        return AppStrings.get('questionnaire');
      case 'Risk Score':
        return AppStrings.get('riskScore');
      case 'Allergy':
        return AppStrings.get('allergyRecord');
      case 'Problem':
        return AppStrings.get('problemRecord');
      case 'General':
        return AppStrings.get('general');
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<HealthEventModel> selectedDayEvents =
        _eventsForDay(_selectedDay);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('calendar')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 950),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCalendarCard(),
                      const SizedBox(height: 16),
                      _buildEventFormCard(),
                      const SizedBox(height: 16),
                      _buildSelectedDayEventsCard(selectedDayEvents),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds the calendar card using the table_calendar package.
  Widget _buildCalendarCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: TableCalendar<HealthEventModel>(
          firstDay: DateTime(2020),
          lastDay: DateTime(2035),
          focusedDay: _focusedDay,

          /// Highlights the selected day.
          selectedDayPredicate: (day) {
            return isSameDay(_selectedDay, day);
          },

          /// Loads events for each calendar day.
          eventLoader: _eventsForDay,

          /// Updates selected day when the user taps a date.
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
              _focusedDay = focusedDay;
              _dateController.text = _formatDate(selectedDay);
            });
          },

          /// Allows month switching.
          onPageChanged: (focusedDay) {
            _focusedDay = focusedDay;
          },

          calendarStyle: const CalendarStyle(
            todayDecoration: BoxDecoration(
              color: Colors.teal,
              shape: BoxShape.circle,
            ),
            selectedDecoration: BoxDecoration(
              color: Colors.tealAccent,
              shape: BoxShape.circle,
            ),
            markerDecoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),

          headerStyle: const HeaderStyle(
            formatButtonVisible: false,
            titleCentered: true,
          ),
        ),
      ),
    );
  }

  /// Builds the form used to add new events.
  Widget _buildEventFormCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.calendar_month,
                size: 56,
                color: Colors.teal,
              ),

              const SizedBox(height: 12),

              Text(
                AppStrings.get('calendarTitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                AppStrings.get('calendarInstructions'),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              /// Event title field.
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('eventTitle'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: _requiredFieldValidator,
              ),

              const SizedBox(height: 16),

              /// Event type dropdown.
              DropdownButtonFormField<String>(
                initialValue: _selectedEventType,
                decoration: InputDecoration(
                  labelText: AppStrings.get('eventType'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Appointment',
                    child: Text(AppStrings.get('appointment')),
                  ),
                  DropdownMenuItem(
                    value: 'Medication',
                    child: Text(AppStrings.get('medications')),
                  ),
                  DropdownMenuItem(
                    value: 'Questionnaire',
                    child: Text(AppStrings.get('questionnaire')),
                  ),
                  DropdownMenuItem(
                    value: 'Risk Score',
                    child: Text(AppStrings.get('riskScore')),
                  ),
                  DropdownMenuItem(
                    value: 'General',
                    child: Text(AppStrings.get('general')),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) return;

                  setState(() {
                    _selectedEventType = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              /// Event date field.
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppStrings.get('eventDate'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _selectEventDate,
                  ),
                ),
                onTap: _selectEventDate,
                validator: _requiredFieldValidator,
              ),

              const SizedBox(height: 16),

              /// Event description field.
              TextFormField(
                controller: _descriptionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppStrings.get('eventDescription'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),

              const SizedBox(height: 24),

              /// Add event button.
              FilledButton.icon(
                onPressed: _addEvent,
                icon: const Icon(Icons.add),
                label: Text(AppStrings.get('addEvent')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the event list for the currently selected calendar day.
  Widget _buildSelectedDayEventsCard(List<HealthEventModel> events) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('eventsForSelectedDay'),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            if (events.isEmpty)
              Text(AppStrings.get('noEventsForDay'))
            else
              for (final HealthEventModel event in events)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.event,
                      color: Colors.teal,
                    ),
                    title: Text(event.title),
                    subtitle: Text(
                      '${AppStrings.get('eventType')}: '
                      '${_localizedEventType(event.type)}\n'
                      '${AppStrings.get('eventDate')}: ${event.date}\n'
                      '${AppStrings.get('eventDescription')}: '
                      '${event.description.isEmpty ? '-' : event.description}',
                    ),
                    trailing: IconButton(
                      tooltip: AppStrings.get('delete'),
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteEvent(event.id);
                      },
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }
}