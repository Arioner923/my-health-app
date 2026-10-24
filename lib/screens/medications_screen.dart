import 'package:flutter/material.dart';

import '../core/services/medication_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/medication_model.dart';

import '../core/services/calendar_auto_event_service.dart';

/// Screen for managing patient medications.
///
/// The user can:
/// - add a new medication
/// - view current medications
/// - view medication history
/// - delete medication records
class MedicationsScreen extends StatefulWidget {
  const MedicationsScreen({super.key});

  @override
  State<MedicationsScreen> createState() => _MedicationsScreenState();
}

class _MedicationsScreenState extends State<MedicationsScreen> {
  /// Form key used for validating medication input fields.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Text controllers for medication fields.
  final TextEditingController _medicationNameController =
      TextEditingController();
  final TextEditingController _dosageController = TextEditingController();
  final TextEditingController _frequencyController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  /// Indicates whether the medication is currently ongoing.
  bool _ongoing = true;

  /// Saved medication list.
  List<MedicationModel> _medications = [];

  /// Shows whether medication data is being loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Load saved medication records when the screen opens.
    _loadMedications();
  }

  @override
  void dispose() {
    /// Dispose controllers to prevent memory leaks.
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Loads all saved medication records from local storage.
  Future<void> _loadMedications() async {
    final List<MedicationModel> savedMedications =
        await MedicationStorageService.loadMedications();

    if (!mounted) return;

    setState(() {
      _medications = savedMedications.reversed.toList();
      _isLoading = false;
    });
  }

  /// Opens a date picker and writes the selected date into a controller.
  Future<void> _selectDate(TextEditingController controller) async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 10),
    );

    if (selectedDate == null) return;

    /// Save date in YYYY-MM-DD format.
    final String formattedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    setState(() {
      controller.text = formattedDate;
    });
  }

  /// Saves a new medication record.
  Future<void> _addMedication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    /// If the medication is not ongoing, an end date is required.
    if (!_ongoing && _endDateController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('endDateRequired')),
        ),
      );
      return;
    }

    /// Timestamp is used as a simple unique id.
    final String medicationId = DateTime.now().millisecondsSinceEpoch.toString();

    final MedicationModel medication = MedicationModel(
      id: medicationId,
      medicationName: _medicationNameController.text.trim(),
      dosage: _dosageController.text.trim(),
      frequency: _frequencyController.text.trim(),
      startDate: _startDateController.text.trim(),
      endDate: _ongoing ? '' : _endDateController.text.trim(),
      ongoing: _ongoing,
      notes: _notesController.text.trim(),
    );

    await MedicationStorageService.saveMedication(medication);
    /// Automatically create a calendar event for the medication record.
    await CalendarAutoEventService.createCalendarEvent(
      title: AppStrings.get('autoEventMedication'),
      type: 'Medication',
      date: medication.startDate,
      description:
          '${AppStrings.get('medicationName')}: ${medication.medicationName}\n'
          '${AppStrings.get('dosage')}: ${medication.dosage}\n'
          '${AppStrings.get('frequency')}: ${medication.frequency}\n'
          '${AppStrings.get('ongoing')}: '
          '${medication.ongoing ? AppStrings.get('yes') : AppStrings.get('no')}',
    );

    /// Clear form fields after saving.
    _medicationNameController.clear();
    _dosageController.clear();
    _frequencyController.clear();
    _startDateController.clear();
    _endDateController.clear();
    _notesController.clear();

    setState(() {
      _ongoing = true;
    });

    await _loadMedications();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('savedSuccessfully')),
      ),
    );
  }

  /// Deletes a medication record.
  Future<void> _deleteMedication(String medicationId) async {
    await MedicationStorageService.deleteMedication(medicationId);

    await _loadMedications();
  }

  /// Common validator for required fields.
  String? _requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.get('pleaseFillField');
    }

    return null;
  }

  /// Returns current medications.
  ///
  /// A medication is considered current if it is marked as ongoing.
  List<MedicationModel> get _currentMedications {
    return _medications.where((item) => item.ongoing).toList();
  }

  /// Returns medication history.
  ///
  /// A medication is considered history if it is not ongoing.
  List<MedicationModel> get _medicationHistory {
    return _medications.where((item) => !item.ongoing).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('medications')),
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
                      _buildMedicationFormCard(),
                      const SizedBox(height: 16),
                      _buildMedicationListCard(
                        title: AppStrings.get('currentMedications'),
                        emptyMessage: AppStrings.get('noCurrentMedications'),
                        medications: _currentMedications,
                      ),
                      const SizedBox(height: 16),
                      _buildMedicationListCard(
                        title: AppStrings.get('medicationHistory'),
                        emptyMessage: AppStrings.get('noMedicationHistory'),
                        medications: _medicationHistory,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds the medication input form.
  Widget _buildMedicationFormCard() {
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
                Icons.medication,
                size: 56,
                color: Colors.teal,
              ),

              const SizedBox(height: 12),

              Text(
                AppStrings.get('medicationsTitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                AppStrings.get('medicationsInstructions'),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              /// Medication name field.
              TextFormField(
                controller: _medicationNameController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('medicationName'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.medication),
                ),
                validator: _requiredFieldValidator,
              ),

              const SizedBox(height: 16),

              /// Dosage field.
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('dosage'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.science),
                ),
                validator: _requiredFieldValidator,
              ),

              const SizedBox(height: 16),

              /// Frequency field.
              TextFormField(
                controller: _frequencyController,
                decoration: InputDecoration(
                  labelText: AppStrings.get('frequency'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.schedule),
                ),
                validator: _requiredFieldValidator,
              ),

              const SizedBox(height: 16),

              /// Start date field.
              TextFormField(
                controller: _startDateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: AppStrings.get('startDate'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.date_range),
                    onPressed: () => _selectDate(_startDateController),
                  ),
                ),
                onTap: () => _selectDate(_startDateController),
                validator: _requiredFieldValidator,
              ),

              const SizedBox(height: 12),

              /// Ongoing switch.
              SwitchListTile(
                title: Text(AppStrings.get('ongoing')),
                subtitle:
                    Text(_ongoing ? AppStrings.get('yes') : AppStrings.get('no')),
                value: _ongoing,
                onChanged: (bool value) {
                  setState(() {
                    _ongoing = value;

                    /// If the medication becomes ongoing, end date is cleared.
                    if (_ongoing) {
                      _endDateController.clear();
                    }
                  });
                },
              ),

              /// End date is shown only when medication is not ongoing.
              if (!_ongoing) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: AppStrings.get('endDate'),
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.event_busy),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.date_range),
                      onPressed: () => _selectDate(_endDateController),
                    ),
                  ),
                  onTap: () => _selectDate(_endDateController),
                ),
              ],

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

              /// Add medication button.
              FilledButton.icon(
                onPressed: _addMedication,
                icon: const Icon(Icons.add),
                label: Text(AppStrings.get('addMedication')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a medication list card.
  ///
  /// The same widget is reused for:
  /// - current medications
  /// - medication history
  Widget _buildMedicationListCard({
    required String title,
    required String emptyMessage,
    required List<MedicationModel> medications,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            if (medications.isEmpty)
              Text(emptyMessage)
            else
              for (final MedicationModel medication in medications)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.medication,
                      color: Colors.teal,
                    ),
                    title: Text(medication.medicationName),
                    subtitle: Text(
                      '${AppStrings.get('dosage')}: ${medication.dosage}\n'
                      '${AppStrings.get('frequency')}: ${medication.frequency}\n'
                      '${AppStrings.get('startDate')}: ${medication.startDate}\n'
                      '${AppStrings.get('endDate')}: '
                      '${medication.ongoing ? '-' : medication.endDate}\n'
                      '${AppStrings.get('ongoing')}: '
                      '${medication.ongoing ? AppStrings.get('yes') : AppStrings.get('no')}\n'
                      '${AppStrings.get('notes')}: '
                      '${medication.notes.isEmpty ? '-' : medication.notes}',
                    ),
                    trailing: IconButton(
                      tooltip: AppStrings.get('delete'),
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteMedication(medication.id);
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