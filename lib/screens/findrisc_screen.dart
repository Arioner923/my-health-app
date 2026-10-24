import 'package:flutter/material.dart';

import '../core/services/findrisc_score_service.dart';
import '../core/services/findrisc_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/findrisc_result_model.dart';

import '../core/services/calendar_auto_event_service.dart';

/// Screen for the FINDRISC diabetes risk score calculator.
///
/// The user selects answers for the eight FINDRISC risk factors.
/// The app calculates the total score, shows the risk category,
/// and saves the result in local storage.
class FindriscScreen extends StatefulWidget {
  const FindriscScreen({super.key});

  @override
  State<FindriscScreen> createState() => _FindriscScreenState();
}

class _FindriscScreenState extends State<FindriscScreen> {
  /// Selected gender is needed because waist circumference scoring
  /// uses different thresholds for men and women.
  String _selectedGender = 'Male';

  /// FINDRISC score components.
  int _ageScore = 0;
  int _bmiScore = 0;
  int _waistScore = 0;
  int _activityScore = 0;
  int _dietScore = 0;
  int _bpMedicationScore = 0;
  int _glucoseScore = 0;
  int _familyHistoryScore = 0;

  /// Stores the latest calculated result.
  FindriscResultModel? _latestResult;

  /// Stores saved FINDRISC result history.
  List<FindriscResultModel> _history = [];

  /// Shows whether saved data is being loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Load previous saved results when the screen opens.
    _loadHistory();
  }

  /// Loads saved FINDRISC results from local storage.
  Future<void> _loadHistory() async {
    final List<FindriscResultModel> savedResults =
        await FindriscStorageService.loadResults();

    if (!mounted) return;

    setState(() {
      _history = savedResults.reversed.toList();
      _isLoading = false;
    });
  }

  /// Calculates and saves the FINDRISC result.
  Future<void> _calculateAndSaveScore() async {
    final int totalScore = FindriscScoreService.calculateTotalScore(
      ageScore: _ageScore,
      bmiScore: _bmiScore,
      waistScore: _waistScore,
      activityScore: _activityScore,
      dietScore: _dietScore,
      bpMedicationScore: _bpMedicationScore,
      glucoseScore: _glucoseScore,
      familyHistoryScore: _familyHistoryScore,
    );

    final String riskCategory = FindriscScoreService.getRiskCategory(
      totalScore: totalScore,
      lowRiskLabel: AppStrings.get('lowRisk'),
      slightlyElevatedRiskLabel: AppStrings.get('slightlyElevatedRisk'),
      moderateRiskLabel: AppStrings.get('moderateRisk'),
      highRiskLabel: AppStrings.get('highRisk'),
      veryHighRiskLabel: AppStrings.get('veryHighRisk'),
    );

    final DateTime now = DateTime.now();

    /// Store date in YYYY-MM-DD format.
    final String formattedDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final FindriscResultModel result = FindriscResultModel(
      gender: _selectedGender,
      ageScore: _ageScore,
      bmiScore: _bmiScore,
      waistScore: _waistScore,
      activityScore: _activityScore,
      dietScore: _dietScore,
      bpMedicationScore: _bpMedicationScore,
      glucoseScore: _glucoseScore,
      familyHistoryScore: _familyHistoryScore,
      totalScore: totalScore,
      riskCategory: riskCategory,
      date: formattedDate,
    );

    await FindriscStorageService.saveResult(result);
    /// Automatically create a calendar event for the FINDRISC calculation.
    await CalendarAutoEventService.createCalendarEvent(
      title: AppStrings.get('autoEventRiskScore'),
      type: 'Risk Score',
      date: result.date,
      description:
          '${AppStrings.get('findriscTitle')}\n'
          '${AppStrings.get('findriscScore')}: '
          '${result.totalScore} ${AppStrings.get('points')}\n'
          '${AppStrings.get('diabetesRisk')}: ${result.riskCategory}',
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

  /// Returns waist circumference options based on selected gender.
  ///
  /// Male thresholds:
  /// - less than 94 cm: 0 points
  /// - 94–102 cm: 3 points
  /// - more than 102 cm: 4 points
  ///
  /// Female thresholds:
  /// - less than 80 cm: 0 points
  /// - 80–88 cm: 3 points
  /// - more than 88 cm: 4 points
  List<DropdownMenuItem<int>> _getWaistOptions() {
    final bool isMale = _selectedGender == 'Male';

    if (isMale) {
      return [
        DropdownMenuItem(
          value: 0,
          child: Text('${AppStrings.get('waistLow')} (< 94 ${AppStrings.get('cm')})'),
        ),
        DropdownMenuItem(
          value: 3,
          child: Text('${AppStrings.get('waistMedium')} (94–102 ${AppStrings.get('cm')})'),
        ),
        DropdownMenuItem(
          value: 4,
          child: Text('${AppStrings.get('waistHigh')} (> 102 ${AppStrings.get('cm')})'),
        ),
      ];
    }

    return [
      DropdownMenuItem(
        value: 0,
        child: Text('${AppStrings.get('waistLow')} (< 80 ${AppStrings.get('cm')})'),
      ),
      DropdownMenuItem(
        value: 3,
        child: Text('${AppStrings.get('waistMedium')} (80–88 ${AppStrings.get('cm')})'),
      ),
      DropdownMenuItem(
        value: 4,
        child: Text('${AppStrings.get('waistHigh')} (> 88 ${AppStrings.get('cm')})'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('findrisc')),
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

  /// Builds the main FINDRISC calculator card.
  Widget _buildCalculatorCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.bloodtype,
              size: 56,
              color: Colors.teal,
            ),

            const SizedBox(height: 12),

            Text(
              AppStrings.get('findriscTitle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            Text(
              AppStrings.get('findriscInstructions'),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            /// Gender selector.
            DropdownButtonFormField<String>(
            initialValue: _selectedGender,

            /// Allows the dropdown value to use the full available width.
            /// This helps prevent text overflow on small mobile screens.
            isExpanded: true,

            decoration: InputDecoration(
              labelText: AppStrings.get('gender'),
              border: const OutlineInputBorder(),
              prefixIcon: const Icon(Icons.wc),
            ),
            items: [
              DropdownMenuItem(
                value: 'Male',
                child: Text(
                  AppStrings.get('male'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
              DropdownMenuItem(
                value: 'Female',
                child: Text(
                  AppStrings.get('female'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                ),
              ),
            ],
            onChanged: (String? value) {
              if (value == null) return;

              setState(() {
                _selectedGender = value;

                /// Reset waist score when gender changes because
                /// waist thresholds are different for men and women.
                _waistScore = 0;
              });
            },
          ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppStrings.get('age'),
              icon: Icons.cake,
              value: _ageScore,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('${AppStrings.get('under45')} - 0 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('${AppStrings.get('age45to54')} - 2 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('${AppStrings.get('age55to64')} - 3 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 4,
                  child: Text('${AppStrings.get('over64')} - 4 ${AppStrings.get('points')}'),
                ),
              ],
              onChanged: (int value) {
                setState(() {
                  _ageScore = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppStrings.get('bmi'),
              icon: Icons.monitor_weight,
              value: _bmiScore,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('${AppStrings.get('bmiUnder25')} - 0 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('${AppStrings.get('bmi25to30')} - 1 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('${AppStrings.get('bmiOver30')} - 3 ${AppStrings.get('points')}'),
                ),
              ],
              onChanged: (int value) {
                setState(() {
                  _bmiScore = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppStrings.get('waistCircumference'),
              icon: Icons.straighten,
              value: _waistScore,
              items: _getWaistOptions(),
              onChanged: (int value) {
                setState(() {
                  _waistScore = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppStrings.get('physicalActivity'),
              icon: Icons.directions_run,
              value: _activityScore,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('${AppStrings.get('dailyYes')} - 0 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('${AppStrings.get('dailyNo')} - 2 ${AppStrings.get('points')}'),
                ),
              ],
              onChanged: (int value) {
                setState(() {
                  _activityScore = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppStrings.get('fruitVegetables'),
              icon: Icons.restaurant,
              value: _dietScore,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('${AppStrings.get('dailyYes')} - 0 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 1,
                  child: Text('${AppStrings.get('dailyNo')} - 1 ${AppStrings.get('points')}'),
                ),
              ],
              onChanged: (int value) {
                setState(() {
                  _dietScore = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppStrings.get('highBpMedication'),
              icon: Icons.medication,
              value: _bpMedicationScore,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('${AppStrings.get('no')} - 0 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 2,
                  child: Text('${AppStrings.get('yes')} - 2 ${AppStrings.get('points')}'),
                ),
              ],
              onChanged: (int value) {
                setState(() {
                  _bpMedicationScore = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppStrings.get('highGlucoseHistory'),
              icon: Icons.bloodtype,
              value: _glucoseScore,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('${AppStrings.get('no')} - 0 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text('${AppStrings.get('yes')} - 5 ${AppStrings.get('points')}'),
                ),
              ],
              onChanged: (int value) {
                setState(() {
                  _glucoseScore = value;
                });
              },
            ),

            const SizedBox(height: 16),

            _buildDropdownField(
              label: AppStrings.get('familyHistoryDiabetes'),
              icon: Icons.family_restroom,
              value: _familyHistoryScore,
              items: [
                DropdownMenuItem(
                  value: 0,
                  child: Text('${AppStrings.get('familyNone')} - 0 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 3,
                  child: Text('${AppStrings.get('familySecondDegree')} - 3 ${AppStrings.get('points')}'),
                ),
                DropdownMenuItem(
                  value: 5,
                  child: Text('${AppStrings.get('familyFirstDegree')} - 5 ${AppStrings.get('points')}'),
                ),
              ],
              onChanged: (int value) {
                setState(() {
                  _familyHistoryScore = value;
                });
              },
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _calculateAndSaveScore,
              icon: const Icon(Icons.calculate),
              label: Text(AppStrings.get('calculateScore')),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable dropdown field for FINDRISC questions.
  ///
  /// This method is mobile-friendly:
  /// - isExpanded prevents the selected value from overflowing horizontally.
  /// - selectedItemBuilder controls how the selected option is displayed.
  /// - long texts are shortened with ellipsis on small screens.
  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required int value,
    required List<DropdownMenuItem<int>> items,
    required void Function(int value) onChanged,
  }) {
    return DropdownButtonFormField<int>(
      initialValue: value,

      /// Allows the dropdown content to use the full available width.
      /// This is important for small mobile screens.
      isExpanded: true,

      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),

      /// Rebuilds the menu items with overflow protection.
      items: items.map((DropdownMenuItem<int> item) {
        return DropdownMenuItem<int>(
          value: item.value,
          child: _buildSafeDropdownChild(item.child),
        );
      }).toList(),

      /// Controls how the selected item appears inside the closed dropdown.
      /// Without this, long values can overflow on real Android devices.
      selectedItemBuilder: (BuildContext context) {
        return items.map((DropdownMenuItem<int> item) {
          return _buildSafeDropdownChild(item.child);
        }).toList();
      },

      onChanged: (int? selectedValue) {
        if (selectedValue == null) return;

        onChanged(selectedValue);
      },
    );
  }

  /// Builds a safe dropdown child that does not overflow on mobile.
  ///
  /// Most FINDRISC dropdown items use Text widgets.
  /// This helper keeps their text on one line and shows "..." if needed.
  Widget _buildSafeDropdownChild(Widget child) {
    if (child is Text) {
      return Text(
        child.data ?? '',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        softWrap: false,
      );
    }

    return child;
  }

  /// Builds a card that displays the latest calculated FINDRISC result.
  Widget _buildResultCard() {
    final FindriscResultModel result = _latestResult!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('findriscTitle'),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text(
              '${AppStrings.get('findriscScore')}: '
              '${result.totalScore} ${AppStrings.get('points')}',
            ),
            Text('${AppStrings.get('diabetesRisk')}: ${result.riskCategory}'),
            Text('${AppStrings.get('date')}: ${result.date}'),
          ],
        ),
      ),
    );
  }

  /// Builds the saved FINDRISC result history.
  Widget _buildHistoryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('findriscHistory'),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            if (_history.isEmpty)
              Text(AppStrings.get('noResultsYet'))
            else
              for (final FindriscResultModel result in _history.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.bloodtype,
                    color: Colors.teal,
                  ),
                  title: Text(
                    '${AppStrings.get('findriscScore')}: '
                    '${result.totalScore} ${AppStrings.get('points')}',
                  ),
                  subtitle: Text(
                    '${AppStrings.get('diabetesRisk')}: '
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