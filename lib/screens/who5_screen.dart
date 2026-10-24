import 'package:flutter/material.dart';

import '../core/services/who5_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/who5_result_model.dart';

import '../core/services/calendar_auto_event_service.dart';

/// Screen for the WHO-5 Well-Being Index questionnaire.
///
/// The questionnaire contains five short well-being items.
/// Each item is scored from 0 to 5.
///
/// Score calculation:
/// - raw score = sum of all five answers, range 0-25
/// - percentage score = raw score * 4, range 0-100
class Who5Screen extends StatefulWidget {
  const Who5Screen({super.key});

  @override
  State<Who5Screen> createState() => _Who5ScreenState();
}

class _Who5ScreenState extends State<Who5Screen> {
  /// Stores the selected answer for each of the five questions.
  ///
  /// Default value is 3 for each question so the form always has valid values.
  final List<int> _answers = [3, 3, 3, 3, 3];

  /// Stores the latest calculated result.
  Who5ResultModel? _latestResult;

  /// Stores all previous saved WHO-5 results.
  List<Who5ResultModel> _history = [];

  /// Shows whether saved results are being loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Load saved WHO-5 results when the screen opens.
    _loadHistory();
  }

  /// Loads previous WHO-5 results from local storage.
  Future<void> _loadHistory() async {
    final List<Who5ResultModel> savedResults =
        await Who5StorageService.loadResults();

    if (!mounted) return;

    setState(() {
      _history = savedResults.reversed.toList();
      _isLoading = false;
    });
  }

  /// Calculates and saves the WHO-5 score.
  Future<void> _calculateAndSaveScore() async {
    final int rawScore = _answers.reduce((a, b) => a + b);
    final int percentageScore = rawScore * 4;

    /// A percentage score below 50 is treated as low well-being.
    final String category = percentageScore < 50
        ? AppStrings.get('lowWellbeing')
        : AppStrings.get('goodWellbeing');

    final DateTime now = DateTime.now();

    /// Store the date in YYYY-MM-DD format.
    final String formattedDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    final Who5ResultModel result = Who5ResultModel(
      answers: List<int>.from(_answers),
      rawScore: rawScore,
      percentageScore: percentageScore,
      category: category,
      date: formattedDate,
    );

    await Who5StorageService.saveResult(result);
    /// Automatically create a calendar event for the WHO-5 completion.
    await CalendarAutoEventService.createCalendarEvent(
      title: AppStrings.get('autoEventQuestionnaire'),
      type: 'Questionnaire',
      date: result.date,
      description:
          '${AppStrings.get('who5Title')}\n'
          '${AppStrings.get('rawScore')}: ${result.rawScore}/25\n'
          '${AppStrings.get('percentageScore')}: ${result.percentageScore}/100\n'
          '${AppStrings.get('wellbeingCategory')}: ${result.category}',
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

  /// Returns the questionnaire items used by the screen.
  ///
  /// The labels are short and UI-friendly, while still matching the purpose
  /// of each WHO-5 well-being dimension.
  List<String> _getQuestionLabels() {
    return [
      AppStrings.get('cheerfulMood'),
      AppStrings.get('calmRelaxed'),
      AppStrings.get('activeEnergetic'),
      AppStrings.get('freshRested'),
      AppStrings.get('dailyInterest'),
    ];
  }

  /// Returns answer options from 5 to 0.
  ///
  /// Higher values indicate better well-being.
  List<DropdownMenuItem<int>> _getAnswerOptions() {
    return [
      DropdownMenuItem(
        value: 5,
        child: Text('5 - ${AppStrings.get('allOfTheTime')}'),
      ),
      DropdownMenuItem(
        value: 4,
        child: Text('4 - ${AppStrings.get('mostOfTheTime')}'),
      ),
      DropdownMenuItem(
        value: 3,
        child: Text('3 - ${AppStrings.get('moreThanHalf')}'),
      ),
      DropdownMenuItem(
        value: 2,
        child: Text('2 - ${AppStrings.get('lessThanHalf')}'),
      ),
      DropdownMenuItem(
        value: 1,
        child: Text('1 - ${AppStrings.get('someOfTheTime')}'),
      ),
      DropdownMenuItem(
        value: 0,
        child: Text('0 - ${AppStrings.get('atNoTime')}'),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final List<String> questions = _getQuestionLabels();

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('who5')),
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
                      /// Main questionnaire card.
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Icon(
                                Icons.psychology,
                                size: 56,
                                color: Colors.teal,
                              ),

                              const SizedBox(height: 12),

                              Text(
                                AppStrings.get('who5Title'),
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),

                              const SizedBox(height: 8),

                              Text(
                                AppStrings.get('who5Instructions'),
                                textAlign: TextAlign.center,
                              ),

                              const SizedBox(height: 24),

                              /// Generate the five WHO-5 questionnaire fields.
                              for (int index = 0;
                                  index < questions.length;
                                  index++)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DropdownButtonFormField<int>(
                                    initialValue: _answers[index],
                                    decoration: InputDecoration(
                                      labelText:
                                          '${index + 1}. ${questions[index]}',
                                      border: const OutlineInputBorder(),
                                      prefixIcon:
                                          const Icon(Icons.check_circle),
                                    ),
                                    items: _getAnswerOptions(),
                                    onChanged: (int? value) {
                                      if (value == null) return;

                                      setState(() {
                                        _answers[index] = value;
                                      });
                                    },
                                  ),
                                ),

                              const SizedBox(height: 8),

                              /// Calculate and save button.
                              FilledButton.icon(
                                onPressed: _calculateAndSaveScore,
                                icon: const Icon(Icons.calculate),
                                label: Text(AppStrings.get('calculateScore')),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// Latest result card.
                      if (_latestResult != null) _buildResultCard(),

                      const SizedBox(height: 16),

                      /// History card.
                      _buildHistoryCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds a card that displays the latest calculated WHO-5 result.
  Widget _buildResultCard() {
    final Who5ResultModel result = _latestResult!;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('who5Title'),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            Text('${AppStrings.get('rawScore')}: ${result.rawScore}/25'),
            Text(
              '${AppStrings.get('percentageScore')}: '
              '${result.percentageScore}/100',
            ),
            Text('${AppStrings.get('wellbeingCategory')}: ${result.category}'),
            Text('Date: ${result.date}'),
          ],
        ),
      ),
    );
  }

  /// Builds the saved WHO-5 result history.
  Widget _buildHistoryCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('who5History'),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            if (_history.isEmpty)
              Text(AppStrings.get('noResultsYet'))
            else
              for (final Who5ResultModel result in _history.take(5))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.psychology,
                    color: Colors.teal,
                  ),
                  title: Text(
                    '${AppStrings.get('percentageScore')}: '
                    '${result.percentageScore}/100',
                  ),
                  subtitle: Text(
                    '${AppStrings.get('rawScore')}: ${result.rawScore}/25\n'
                    '${AppStrings.get('wellbeingCategory')}: '
                    '${result.category}',
                  ),
                  trailing: Text(result.date),
                ),
          ],
        ),
      ),
    );
  }
}