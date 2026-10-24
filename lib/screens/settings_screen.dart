import 'package:flutter/material.dart';

import '../core/services/language_storage_service.dart';
import '../localization/app_strings.dart';

/// Screen for application settings.
///
/// For this project, the main setting is language selection.
/// The selected language is saved locally and applied immediately.
class SettingsScreen extends StatefulWidget {
  /// Callback used to notify the root application when the language changes.
  final void Function(String languageCode) onLanguageChanged;

  const SettingsScreen({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// Stores the selected language in the dropdown.
  String _selectedLanguage = AppStrings.currentLanguage;

  /// Changes the application language and saves it locally.
  Future<void> _changeLanguage(String? languageCode) async {
    if (languageCode == null) return;

    setState(() {
      _selectedLanguage = languageCode;
    });

    /// Save selected language so it remains after refresh or restart.
    await LanguageStorageService.saveLanguage(languageCode);

    /// Notify the root widget to rebuild the app with the new language.
    widget.onLanguageChanged(languageCode);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(AppStrings.get('languageChanged')),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('settings')),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    /// Settings icon.
                    const Icon(
                      Icons.settings,
                      size: 56,
                      color: Colors.teal,
                    ),

                    const SizedBox(height: 12),

                    /// Settings title.
                    Text(
                      AppStrings.get('settingsTitle'),
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),

                    const SizedBox(height: 8),

                    /// Short description.
                    Text(
                      AppStrings.get('settingsInstructions'),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 24),

                    /// Language selector.
                    DropdownButtonFormField<String>(
                      initialValue: _selectedLanguage,
                      decoration: InputDecoration(
                        labelText: AppStrings.get('selectLanguage'),
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.language),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'en',
                          child: Text(AppStrings.get('english')),
                        ),
                        DropdownMenuItem(
                          value: 'el',
                          child: Text(AppStrings.get('greek')),
                        ),
                      ],
                      onChanged: _changeLanguage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}