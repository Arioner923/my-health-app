import 'package:flutter/material.dart';

import '../core/services/framingham_score_service.dart';
import '../core/services/framingham_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/framingham_result_model.dart';

import '../core/services/calendar_auto_event_service.dart';

/// Screen for the Framingham Cardiovascular Risk Score calculator.
///
/// The screen allows the user to enter cardiovascular risk factors,
/// calculates a Framingham-style risk score, and stores the result locally.
class FraminghamScreen extends StatefulWidget {
  const FraminghamScreen({super.key});

  @override
  State<FraminghamScreen> createState() => _FraminghamScreenState();
}

class _FraminghamScreenState extends State<FraminghamScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _totalCholesterolController =
      TextEditingController();
  final TextEditingController _hdlCholesterolController =
      TextEditingController();
  final TextEditingController _systolicBpController = TextEditingController();

  String _selectedGender = 'Male';

  bool _treatedBp = false;
  bool _smoker = false;
  bool _diabetes = false;

  FraminghamResultModel? _latestResult;
  List<FraminghamResultModel> _history = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _ageController.dispose();
    _totalCholesterolController.dispose();
    _hdlCholesterolController.dispose();
    _systolicBpController.dispose();
    super.dispose();
  }

  /// Loads saved Framingham results from local storage.
  Future<void> _loadHistory() async {
    final List<FraminghamResultModel> savedResults =
        await FraminghamStorageService.loadResults();

    if (!mounted) return;

    setState(() {
      _history = savedResults.reversed.toList();
      _isLoading = false;
    });
  }

  /// Validates a required numeric field.
  String? _numberValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return AppStrings.get('pleaseFillField');
    }

    final int? number = int.tryParse(value.trim());

    if (number == null) {
      return AppStrings.get('invalidNumber');
    }

    return null;
  }

  /// Validates the age field.
  String? _ageValidator(String? value) {
    final String? basicValidation = _numberValidator(value);

    if (basicValidation != null) {
      return basicValidation;
    }

    final int age = int.parse(value!.trim());

    if (age < 20 || age > 79) {
      return AppStrings.get('ageRangeFramingham');
    }

    return null;
  }

  /// Calculates and saves the Framingham score.
  Future<void> _calculateAndSaveRisk() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final int age = int.parse(_ageController.text.trim());
    final int totalCholesterol =
        int.parse(_totalCholesterolController.text.trim());
    final int hdlCholesterol = int.parse(_hdlCholesterolController.text.trim());
    final int systolicBp = int.parse(_systolicBpController.text.trim());

    final int riskPoints = FraminghamScoreService.calculateRiskPoints(
      age: age,
      gender: _selectedGender,
      totalCholesterol: totalCholesterol,
      hdlCholesterol: hdlCholesterol,
      systolicBp: systolicBp,
      treatedBp: _treatedBp,
      smoker: _smoker,
      diabetes: _diabetes,
    );

    final double riskPercentage =
        FraminghamScoreService.calculateRiskPercentage(
      riskPoints: riskPoints,
      gender: _selectedGender,
    );

    final String riskCategory = FraminghamScoreService.getRiskCategory(
      riskPercentage: riskPercentage,
      lowRiskLabel: AppStrings.get('lowRisk'),
      moderateRiskLabel: AppStrings.get('moderateRisk'),
      highRiskLabel: AppStrings.get('highRisk'),
    );

    final DateTime now = DateTime.now();

    final String formattedDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final FraminghamResultModel result = FraminghamResultModel(
      age: age,
      gender: _selectedGender,
      totalCholesterol: totalCholesterol,
      hdlCholesterol: hdlCholesterol,
      systolicBp: systolicBp,
      treatedBp: _treatedBp,
      smoker: _smoker,
      diabetes: _diabetes,
      riskPoints: riskPoints,
      riskPercentage: riskPercentage,
      riskCategory: riskCategory,
      date: formattedDate,
    );

    await FraminghamStorageService.saveResult(result);
    /// Automatically create a calendar event for the Framingham calculation.
    await CalendarAutoEventService.createCalendarEvent(
      title: AppStrings.get('autoEventRiskScore'),
      type: 'Risk Score',
      date: result.date,
      description:
          '${AppStrings.get('framinghamTitle')}\n'
          '${AppStrings.get('riskPoints')}: ${result.riskPoints}\n'
          '${AppStrings.get('riskPercentage')}: '
          '${result.riskPercentage.toStringAsFixed(1)}%\n'
          '${AppStrings.get('riskCategory')}: ${result.riskCategory}',
    );

    if (!mounted) return;

    setState(() {
      _latestResult = result;
    });

    await _loadHistory();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('savedSuccessfully')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('framingham')),
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
                      _buildCalculatorCard(),
                      const SizedBox(height: 16),
                      if (_latestResult != null) _buildResultCard(),
                      const SizedBox(height: 16),
                      _buildHistoryCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds the main calculator form.
  Widget _buildCalculatorCard() {
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
                Icons.favorite,
                size: 56,
                color: Colors.teal,
              ),

              const SizedBox(height: 12),

              Text(
                AppStrings.get('framinghamTitle'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),

              const SizedBox(height: 8),

              Text(
                AppStrings.get('framinghamInstructions'),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 24),

              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: AppStrings.get('age'),
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.cake),
                ),
                validator: _ageValidator,
              ),

              const SizedBox(height: 16),

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
                ],
                onChanged: (String? value) {
                  if (value == null) return;

                  setState(() {
                    _selectedGender = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _totalCholesterolController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      '${AppStrings.get('totalCholesterol')} (${AppStrings.get('mgDl')})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.bloodtype),
                ),
                validator: _numberValidator,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _hdlCholesterolController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      '${AppStrings.get('hdlCholesterol')} (${AppStrings.get('mgDl')})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.water_drop),
                ),
                validator: _numberValidator,
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _systolicBpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      '${AppStrings.get('systolicBp')} (${AppStrings.get('mmHg')})',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.monitor_heart),
                ),
                validator: _numberValidator,
              ),

              const SizedBox(height: 12),

              SwitchListTile(
                title: Text(AppStrings.get('treatedBp')),
                subtitle: Text(_treatedBp
                    ? AppStrings.get('yes')
                    : AppStrings.get('no')),
                value: _treatedBp,
                onChanged: (bool value) {
                  setState(() {
                    _treatedBp = value;
                  });
                },
              ),

              SwitchListTile(
                title: Text(AppStrings.get('smoker')),
                subtitle:
                    Text(_smoker ? AppStrings.get('yes') : AppStrings.get('no')),
                value: _smoker,
                onChanged: (bool value) {
                  setState(() {
                    _smoker = value;
                  });
                },
              ),

              SwitchListTile(
                title: Text(AppStrings.get('diabetes')),
                subtitle: Text(
                    _diabetes ? AppStrings.get('yes') : AppStrings.get('no')),
                value: _diabetes,
                onChanged: (bool value) {
                  setState(() {
                    _diabetes = value;
                  });
                },
              ),

              const SizedBox(height: 16),

              FilledButton.icon(
                onPressed: _calculateAndSaveRisk,
                icon: const Icon(Icons.calculate),
                label: Text(AppStrings.get('calculateRisk')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a card that displays the latest calculated result.
  Widget _buildResultCard() {
    final FraminghamResultModel result = _latestResult!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('framinghamTitle'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            Text('${AppStrings.get('riskPoints')}: ${result.riskPoints}'),
            Text(
              '${AppStrings.get('riskPercentage')}: '
              '${result.riskPercentage.toStringAsFixed(1)}%',
            ),
            Text('${AppStrings.get('riskCategory')}: ${result.riskCategory}'),
            Text('${AppStrings.get('date')}: ${result.date}'),
          ],
        ),
      ),
    );
  }

  /// Builds the saved Framingham result history.
  Widget _buildHistoryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('framinghamHistory'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            if (_history.isEmpty)
              Text(AppStrings.get('noResultsYet'))
            else
              for (final FraminghamResultModel result in _history.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.favorite,
                    color: Colors.teal,
                  ),
                  title: Text(
                    '${AppStrings.get('riskPercentage')}: '
                    '${result.riskPercentage.toStringAsFixed(1)}%',
                  ),
                  subtitle: Text(
                    '${AppStrings.get('riskPoints')}: ${result.riskPoints}\n'
                    '${AppStrings.get('riskCategory')}: '
                    '${result.riskCategory}',
                  ),
                  trailing: Text(result.date),
                ),
          ],
        ),
      ),
    );
  }
}