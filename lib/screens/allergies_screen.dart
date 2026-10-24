import 'package:flutter/material.dart';

import '../core/services/allergy_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/allergy_model.dart';

import '../core/services/calendar_auto_event_service.dart';

/// Screen for managing patient allergies.
///
/// The user can:
/// - add a new allergy
/// - view all saved allergies
/// - delete an allergy
class AllergiesScreen extends StatefulWidget {
  const AllergiesScreen({super.key});

  @override
  State<AllergiesScreen> createState() => _AllergiesScreenState();
}

class _AllergiesScreenState extends State<AllergiesScreen> {
  /// Form key used for validating allergy input fields.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Text controllers for allergy fields.
  final TextEditingController _allergenNameController =
      TextEditingController();
  final TextEditingController _reactionDescriptionController =
      TextEditingController();
  final TextEditingController _onsetDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  /// Selected allergy severity.
  String _selectedSeverity = 'Mild';

  /// Saved allergy list.
  List<AllergyModel> _allergies = [];

  /// Shows whether allergy data is being loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Load saved allergy records when the screen opens.
    _loadAllergies();
  }

  @override
  void dispose() {
    /// Dispose controllers to prevent memory leaks.
    _allergenNameController.dispose();
    _reactionDescriptionController.dispose();
    _onsetDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Loads all saved allergy records from local storage.
  Future<void> _loadAllergies() async {
    final List<AllergyModel> savedAllergies =
        await AllergyStorageService.loadAllergies();

    if (!mounted) return;

    setState(() {
      _allergies = savedAllergies.reversed.toList();
      _isLoading = false;
    });
  }

  /// Opens a date picker and stores the selected onset date.
  Future<void> _selectOnsetDate() async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate == null) return;

    /// Save date in YYYY-MM-DD format.
    final String formattedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    setState(() {
      _onsetDateController.text = formattedDate;
    });
  }

  /// Saves a new allergy record.
  Future<void> _addAllergy() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    /// Timestamp is used as a simple unique id.
    final String allergyId = DateTime.now().millisecondsSinceEpoch.toString();

    final AllergyModel allergy = AllergyModel(
      id: allergyId,
      allergenName: _allergenNameController.text.trim(),
      reactionDescription: _reactionDescriptionController.text.trim(),
      severity: _selectedSeverity,
      onsetDate: _onsetDateController.text.trim(),
      notes: _notesController.text.trim(),
    );

    await AllergyStorageService.saveAllergy(allergy);
    /// Automatically create a calendar event for the allergy record.
    await CalendarAutoEventService.createCalendarEvent(
      title: AppStrings.get('autoEventAllergy'),
      type: 'Allergy',
      date: allergy.onsetDate.isEmpty
          ? CalendarAutoEventService.today()
          : allergy.onsetDate,
      description:
          '${AppStrings.get('allergenName')}: ${allergy.allergenName}\n'
          '${AppStrings.get('reactionDescription')}: '
          '${allergy.reactionDescription}\n'
          '${AppStrings.get('severity')}: '
          '${_localizedSeverity(allergy.severity)}',
    );

    /// Clear form fields after saving.
    _allergenNameController.clear();
    _reactionDescriptionController.clear();
    _onsetDateController.clear();
    _notesController.clear();

    setState(() {
      _selectedSeverity = 'Mild';
    });

    await _loadAllergies();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('savedSuccessfully')),
      ),
    );
  }

  /// Deletes an allergy record.
  Future<void> _deleteAllergy(String allergyId) async {
    await AllergyStorageService.deleteAllergy(allergyId);

    await _loadAllergies();
  }

  /// Common validator for required fields.
  String? _requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.get('pleaseFillField');
    }

    return null;
  }

  /// Converts the internal severity value into a localized label.
  String _localizedSeverity(String severity) {
    switch (severity) {
      case 'Mild':
        return AppStrings.get('mild');
      case 'Moderate':
        return AppStrings.get('moderate');
      case 'Severe':
        return AppStrings.get('severe');
      default:
        return severity;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('allergies')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildAllergyFormCard(),
                      const SizedBox(height: 16),
                      _buildAllergyListCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds the allergy input form.
  Widget _buildAllergyFormCard() {
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
                Icons.warning_amber,
                size: 56,
                color: Colors.teal,
              ),

              const SizedBox(height: 12),

              Text(
                AppStrings.get('allergiesTitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                AppStrings.get('allergiesInstructions'),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              /// Allergen name field.
              TextFormField(
                controller: _allergenNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('allergenName'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.coronavirus),
                ),
                validator: _requiredFieldValidator,
              ),

              const SizedBox(height: 16),

              /// Reaction description field.
              TextFormField(
                controller: _reactionDescriptionController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('reactionDescription'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.description),
                ),
                validator: _requiredFieldValidator,
              ),

              const SizedBox(height: 16),

              /// Severity dropdown.
              DropdownButtonFormField<String>(
                initialValue: _selectedSeverity,
                decoration: InputDecoration(
                  labelText: AppStrings.get('severity'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.priority_high),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'Mild',
                    child: Text(AppStrings.get('mild')),
                  ),
                  DropdownMenuItem(
                    value: 'Moderate',
                    child: Text(AppStrings.get('moderate')),
                  ),
                  DropdownMenuItem(
                    value: 'Severe',
                    child: Text(AppStrings.get('severe')),
                  ),
                ],
                onChanged: (String? value) {
                  if (value == null) return;

                  setState(() {
                    _selectedSeverity = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              /// Onset date field.
              TextFormField(
                controller: _onsetDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppStrings.get('onsetDate'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: _selectOnsetDate,
                  ),
                ),
                onTap: _selectOnsetDate,
              ),

              const SizedBox(height: 16),

              /// Notes field.
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: AppStrings.get('notes'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.note),
                ),
              ),

              const SizedBox(height: 24),

              /// Add allergy button.
              FilledButton.icon(
                onPressed: _addAllergy,
                icon: const Icon(Icons.add),
                label: Text(AppStrings.get('addAllergy')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the saved allergies list.
  Widget _buildAllergyListCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('allergiesTitle'),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            if (_allergies.isEmpty)
              Text(AppStrings.get('noAllergiesYet'))
            else
              for (final AllergyModel allergy in _allergies)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.warning_amber,
                      color: Colors.teal,
                    ),
                    title: Text(allergy.allergenName),
                    subtitle: Text(
                      '${AppStrings.get('reactionDescription')}: '
                      '${allergy.reactionDescription}\n'
                      '${AppStrings.get('severity')}: '
                      '${_localizedSeverity(allergy.severity)}\n'
                      '${AppStrings.get('onsetDate')}: '
                      '${allergy.onsetDate.isEmpty ? '-' : allergy.onsetDate}\n'
                      '${AppStrings.get('notes')}: '
                      '${allergy.notes.isEmpty ? '-' : allergy.notes}',
                    ),
                    trailing: IconButton(
                      tooltip: AppStrings.get('delete'),
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteAllergy(allergy.id);
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