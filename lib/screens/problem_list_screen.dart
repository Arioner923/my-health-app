import 'package:flutter/material.dart';

import '../core/constants/icd10_codes.dart';
import '../core/services/problem_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/problem_model.dart';

import '../core/services/calendar_auto_event_service.dart';

/// Screen for managing the patient Problem List using ICD-10 terminology.
///
/// The user can:
/// - search ICD-10 codes locally
/// - select a diagnosis/problem
/// - add status, date and notes
/// - save the problem
/// - view all saved problems
/// - delete problems
class ProblemListScreen extends StatefulWidget {
  const ProblemListScreen({super.key});

  @override
  State<ProblemListScreen> createState() => _ProblemListScreenState();
}

class _ProblemListScreenState extends State<ProblemListScreen> {
  /// Controller for ICD-10 search input.
  final TextEditingController _searchController = TextEditingController();

  /// Controller for the date added field.
  final TextEditingController _dateAddedController = TextEditingController();

  /// Controller for optional notes.
  final TextEditingController _notesController = TextEditingController();

  /// Selected ICD-10 code and diagnosis title.
  String? _selectedIcdCode;
  String? _selectedDiagnosisTitle;

  /// Selected problem status.
  String _selectedStatus = 'Active';

  /// Search results from the local ICD-10 list.
  List<Map<String, String>> _filteredIcdCodes = icd10Codes;

  /// Saved patient problems.
  List<ProblemModel> _problems = [];

  /// Shows whether saved data is being loaded.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Set current date as default date added.
    _setTodayAsDefaultDate();

    /// Load saved problem list records.
    _loadProblems();
  }

  @override
  void dispose() {
    /// Dispose controllers to prevent memory leaks.
    _searchController.dispose();
    _dateAddedController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  /// Sets today's date in YYYY-MM-DD format.
  void _setTodayAsDefaultDate() {
    final DateTime now = DateTime.now();

    final String formattedDate =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';

    _dateAddedController.text = formattedDate;
  }

  /// Loads all saved problem records from local storage.
  Future<void> _loadProblems() async {
    final List<ProblemModel> savedProblems =
        await ProblemStorageService.loadProblems();

    if (!mounted) return;

    setState(() {
      _problems = savedProblems.reversed.toList();
      _isLoading = false;
    });
  }

  /// Filters the local ICD-10 list based on the search query.
  void _filterIcdCodes(String query) {
    final String normalizedQuery = query.trim().toLowerCase();

    setState(() {
      if (normalizedQuery.isEmpty) {
        _filteredIcdCodes = icd10Codes;
      } else {
        _filteredIcdCodes = icd10Codes.where((item) {
          final String code = item['code']?.toLowerCase() ?? '';
          final String title = item['title']?.toLowerCase() ?? '';

          return code.contains(normalizedQuery) ||
              title.contains(normalizedQuery);
        }).toList();
      }
    });
  }

  /// Selects an ICD-10 item from the lookup list.
  void _selectIcdCode(Map<String, String> item) {
    setState(() {
      _selectedIcdCode = item['code'];
      _selectedDiagnosisTitle = item['title'];
      _searchController.text = '${item['code']} - ${item['title']}';
    });
  }

  /// Opens a date picker and stores the selected date.
  Future<void> _selectDateAdded() async {
    final DateTime now = DateTime.now();

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year + 1),
    );

    if (selectedDate == null) return;

    final String formattedDate =
        '${selectedDate.year.toString().padLeft(4, '0')}-'
        '${selectedDate.month.toString().padLeft(2, '0')}-'
        '${selectedDate.day.toString().padLeft(2, '0')}';

    setState(() {
      _dateAddedController.text = formattedDate;
    });
  }

  /// Saves a new problem list entry.
  Future<void> _addProblem() async {
    if (_selectedIcdCode == null || _selectedDiagnosisTitle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppStrings.get('selectIcdFirst')),
        ),
      );
      return;
    }

    /// Timestamp is used as a simple unique id.
    final String problemId = DateTime.now().millisecondsSinceEpoch.toString();

    final ProblemModel problem = ProblemModel(
      id: problemId,
      icdCode: _selectedIcdCode!,
      title: _selectedDiagnosisTitle!,
      status: _selectedStatus,
      dateAdded: _dateAddedController.text.trim(),
      notes: _notesController.text.trim(),
    );

    await ProblemStorageService.saveProblem(problem);
    /// Automatically create a calendar event for the problem list entry.
    await CalendarAutoEventService.createCalendarEvent(
      title: AppStrings.get('autoEventProblem'),
      type: 'Problem',
      date: problem.dateAdded,
      description:
          '${AppStrings.get('icdCode')}: ${problem.icdCode}\n'
          '${AppStrings.get('diagnosisTitle')}: ${problem.title}\n'
          '${AppStrings.get('status')}: ${_localizedStatus(problem.status)}',
    );

    /// Clear form after saving.
    _searchController.clear();
    _notesController.clear();
    _setTodayAsDefaultDate();

    setState(() {
      _selectedIcdCode = null;
      _selectedDiagnosisTitle = null;
      _selectedStatus = 'Active';
      _filteredIcdCodes = icd10Codes;
    });

    await _loadProblems();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('savedSuccessfully')),
      ),
    );
  }

  /// Deletes a problem entry.
  Future<void> _deleteProblem(String problemId) async {
    await ProblemStorageService.deleteProblem(problemId);

    await _loadProblems();
  }

  /// Converts internal status value into localized label.
  String _localizedStatus(String status) {
    switch (status) {
      case 'Active':
        return AppStrings.get('active');
      case 'Resolved':
        return AppStrings.get('resolved');
      case 'Chronic':
        return AppStrings.get('chronic');
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('problemList')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildProblemFormCard(),
                      const SizedBox(height: 16),
                      _buildSavedProblemsCard(),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Builds the problem input form and ICD-10 search section.
  Widget _buildProblemFormCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.medical_information,
              size: 56,
              color: Colors.teal,
            ),

            const SizedBox(height: 12),

            Text(
              AppStrings.get('problemListTitle'),
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 8),

            Text(
              AppStrings.get('problemListInstructions'),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            /// ICD-10 search field.
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: AppStrings.get('searchIcd'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.search),
              ),
              onChanged: _filterIcdCodes,
            ),

            const SizedBox(height: 12),

            /// ICD-10 search results.
            Container(
              constraints: const BoxConstraints(maxHeight: 230),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
              ),
              child: _filteredIcdCodes.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No ICD-10 results found.'),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredIcdCodes.length,
                      itemBuilder: (context, index) {
                        final Map<String, String> item =
                            _filteredIcdCodes[index];

                        final bool isSelected =
                            item['code'] == _selectedIcdCode;

                        return ListTile(
                          leading: Icon(
                            Icons.medical_services,
                            color: isSelected ? Colors.teal : null,
                          ),
                          title: Text('${item['code']} - ${item['title']}'),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.teal,
                                )
                              : null,
                          onTap: () {
                            _selectIcdCode(item);
                          },
                        );
                      },
                    ),
            ),

            const SizedBox(height: 16),

            /// Selected ICD-10 summary.
            if (_selectedIcdCode != null && _selectedDiagnosisTitle != null)
              Card(
                elevation: 1,
                child: ListTile(
                  leading: const Icon(
                    Icons.check_circle,
                    color: Colors.teal,
                  ),
                  title: Text(
                    '${AppStrings.get('icdCode')}: $_selectedIcdCode',
                  ),
                  subtitle: Text(
                    '${AppStrings.get('diagnosisTitle')}: '
                    '$_selectedDiagnosisTitle',
                  ),
                ),
              ),

            const SizedBox(height: 16),

            /// Problem status dropdown.
            DropdownButtonFormField<String>(
              initialValue: _selectedStatus,
              decoration: InputDecoration(
                labelText: AppStrings.get('status'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.flag),
              ),
              items: [
                DropdownMenuItem(
                  value: 'Active',
                  child: Text(AppStrings.get('active')),
                ),
                DropdownMenuItem(
                  value: 'Resolved',
                  child: Text(AppStrings.get('resolved')),
                ),
                DropdownMenuItem(
                  value: 'Chronic',
                  child: Text(AppStrings.get('chronic')),
                ),
              ],
              onChanged: (String? value) {
                if (value == null) return;

                setState(() {
                  _selectedStatus = value;
                });
              },
            ),

            const SizedBox(height: 16),

            /// Date added field.
            TextFormField(
              controller: _dateAddedController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: AppStrings.get('dateAdded'),
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.calendar_today),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.date_range),
                  onPressed: _selectDateAdded,
                ),
              ),
              onTap: _selectDateAdded,
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

            /// Add problem button.
            FilledButton.icon(
              onPressed: _addProblem,
              icon: const Icon(Icons.add),
              label: Text(AppStrings.get('addProblem')),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the saved problem list.
  Widget _buildSavedProblemsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.get('savedProblems'),
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 12),

            if (_problems.isEmpty)
              Text(AppStrings.get('noProblemsYet'))
            else
              for (final ProblemModel problem in _problems)
                Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: const Icon(
                      Icons.medical_information,
                      color: Colors.teal,
                    ),
                    title: Text('${problem.icdCode} - ${problem.title}'),
                    subtitle: Text(
                      '${AppStrings.get('status')}: '
                      '${_localizedStatus(problem.status)}\n'
                      '${AppStrings.get('dateAdded')}: '
                      '${problem.dateAdded}\n'
                      '${AppStrings.get('notes')}: '
                      '${problem.notes.isEmpty ? '-' : problem.notes}',
                    ),
                    trailing: IconButton(
                      tooltip: AppStrings.get('delete'),
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteProblem(problem.id);
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