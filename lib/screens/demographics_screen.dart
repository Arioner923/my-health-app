import 'package:flutter/material.dart';

import '../core/services/patient_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/patient_model.dart';

/// Screen used to collect and store patient demographic information.
///
/// The form includes all demographic fields required by the assignment:
/// - name
/// - age
/// - gender
/// - race
/// - ethnicity
/// - birthday
/// - city
/// - country
class DemographicsScreen extends StatefulWidget {
  const DemographicsScreen({super.key});

  @override
  State<DemographicsScreen> createState() => _DemographicsScreenState();
}

class _DemographicsScreenState extends State<DemographicsScreen> {
  /// Form key used for validating the form fields.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Text controllers for each text input field.
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _raceController = TextEditingController();
  final TextEditingController _ethnicityController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();

  /// Stores selected gender.
  String _selectedGender = 'Male';

  /// Indicates if saved data is being loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Load previously saved patient data when the screen opens.
    _loadSavedPatientData();
  }

  @override
  void dispose() {
    /// Dispose controllers to prevent memory leaks.
    _nameController.dispose();
    _ageController.dispose();
    _raceController.dispose();
    _ethnicityController.dispose();
    _birthdayController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  /// Loads saved patient demographics from local storage.
  Future<void> _loadSavedPatientData() async {
    final PatientModel? savedPatient =
        await PatientStorageService.loadPatient();

    if (!mounted) return;

    if (savedPatient != null) {
      _nameController.text = savedPatient.name;
      _ageController.text = savedPatient.age;
      _selectedGender = savedPatient.gender;
      _raceController.text = savedPatient.race;
      _ethnicityController.text = savedPatient.ethnicity;
      _birthdayController.text = savedPatient.birthday;
      _cityController.text = savedPatient.city;
      _countryController.text = savedPatient.country;
    }

    setState(() {
      _isLoading = false;
    });
  }

  /// Opens a date picker and stores the selected birthday.
  Future<void> _selectBirthday() async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,

      /// Initial date is set to 25 years ago for convenience.
      initialDate: DateTime(now.year - 25),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (selectedDate == null) return;

    /// Save date in a simple YYYY-MM-DD format.
    final String formattedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    setState(() {
      _birthdayController.text = formattedDate;
    });
  }

  /// Saves the patient demographic form.
  Future<void> _savePatientData() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final PatientModel patient = PatientModel(
      name: _nameController.text.trim(),
      age: _ageController.text.trim(),
      gender: _selectedGender,
      race: _raceController.text.trim(),
      ethnicity: _ethnicityController.text.trim(),
      birthday: _birthdayController.text.trim(),
      city: _cityController.text.trim(),
      country: _countryController.text.trim(),
    );

    await PatientStorageService.savePatient(patient);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('savedSuccessfully')),
      ),
    );
  }

  /// Common validator used by required text fields.
  String? _requiredFieldValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.get('pleaseFillField');
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('patientDemographics')),
      ),

      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Card(
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            /// Header icon and title.
                            const Icon(
                              Icons.person,
                              size: 56,
                              color: Colors.teal,
                            ),

                            const SizedBox(height: 12),

                            Text(
                              AppStrings.get('patientDemographics'),
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineSmall,
                            ),

                            const SizedBox(height: 24),

                            /// Name field.
                            TextFormField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('name'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.badge),
                              ),
                              validator: _requiredFieldValidator,
                            ),

                            const SizedBox(height: 16),

                            /// Age field.
                            TextFormField(
                              controller: _ageController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('age'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.cake),
                              ),
                              validator: _requiredFieldValidator,
                            ),

                            const SizedBox(height: 16),

                            /// Gender dropdown.
                            DropdownButtonFormField<String>(
                              initialValue: _selectedGender,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('gender'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.wc),
                              ),
                              items: [
                                DropdownMenuItem(
                                  value: 'Male',
                                  child: Text(AppStrings.get('male')),
                                ),
                                DropdownMenuItem(
                                  value: 'Female',
                                  child: Text(AppStrings.get('female')),
                                ),
                                DropdownMenuItem(
                                  value: 'Other',
                                  child: Text(AppStrings.get('other')),
                                ),
                              ],
                              onChanged: (String? value) {
                                if (value == null) return;

                                setState(() {
                                  _selectedGender = value;
                                });
                              },
                            ),

                            const SizedBox(height: 16),

                            /// Race field.
                            TextFormField(
                              controller: _raceController,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('race'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.groups),
                              ),
                              validator: _requiredFieldValidator,
                            ),

                            const SizedBox(height: 16),

                            /// Ethnicity field.
                            TextFormField(
                              controller: _ethnicityController,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('ethnicity'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.public),
                              ),
                              validator: _requiredFieldValidator,
                            ),

                            const SizedBox(height: 16),

                            /// Birthday field.
                            ///
                            /// The field is read-only because the date should
                            /// be selected using the date picker.
                            TextFormField(
                              controller: _birthdayController,
                              readOnly: true,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('birthday'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.calendar_today),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.date_range),
                                  onPressed: _selectBirthday,
                                ),
                              ),
                              onTap: _selectBirthday,
                              validator: _requiredFieldValidator,
                            ),

                            const SizedBox(height: 16),

                            /// City field.
                            TextFormField(
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('city'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.location_city),
                              ),
                              validator: _requiredFieldValidator,
                            ),

                            const SizedBox(height: 16),

                            /// Country field.
                            TextFormField(
                              controller: _countryController,
                              decoration: InputDecoration(
                                labelText: AppStrings.get('country'),
                                border: const OutlineInputBorder(),
                                prefixIcon: const Icon(Icons.flag),
                              ),
                              validator: _requiredFieldValidator,
                            ),

                            const SizedBox(height: 24),

                            /// Save button.
                            FilledButton.icon(
                              onPressed: _savePatientData,
                              icon: const Icon(Icons.save),
                              label: Text(AppStrings.get('save')),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}