import 'package:flutter/material.dart';

import '../localization/app_strings.dart';

/// Login screen of the application.
///
/// This screen contains:
/// - language selector
/// - email or username input
/// - password input
/// - validation logic
/// - login navigation
class LoginScreen extends StatefulWidget {
  /// Callback function used to notify the root widget when the language changes.
  final void Function(String languageCode) onLanguageChanged;

  const LoginScreen({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Form key used to validate all form fields.
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  /// Controller for the email or username input field.
  final TextEditingController _emailController = TextEditingController();

  /// Controller for the password input field.
  final TextEditingController _passwordController = TextEditingController();

  /// Stores the currently selected language in the dropdown.
  String _selectedLanguage = AppStrings.currentLanguage;

  @override
  void dispose() {
    /// Dispose controllers to free memory when the screen is removed.
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Checks if the input is a valid email address.
  ///
  /// Accepted example:
  /// - user@example.com
  ///
  /// Rejected examples:
  /// - user@
  /// - user.com
  /// - user example@gmail.com
  bool _isValidEmail(String input) {
    final RegExp emailRegex = RegExp(
      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
    );

    return emailRegex.hasMatch(input);
  }

  /// Checks if the input is a valid username.
  ///
  /// Username rules:
  /// - 3 to 20 characters
  /// - must start with a letter
  /// - can contain letters, numbers, dot and underscore
  ///
  /// Accepted examples:
  /// - arioner923
  /// - user_name
  /// - user.name
  ///
  /// Rejected examples:
  /// - 12user
  /// - ab
  /// - user name
  /// - user!
  bool _isValidUsername(String input) {
    final RegExp usernameRegex = RegExp(
      r'^[A-Za-z][A-Za-z0-9._]{2,19}$',
    );

    return usernameRegex.hasMatch(input);
  }

  /// Validates the email or username field.
  ///
  /// If the input contains "@", the app treats it as an email.
  /// Otherwise, the app treats it as a username.
  String? _validateEmailOrUsername(String? value) {
    final String input = value?.trim() ?? '';

    if (input.isEmpty) {
      return AppStrings.get('enterEmail');
    }

    /// If the input contains "@", validate it as an email.
    if (input.contains('@')) {
      if (_isValidEmail(input)) {
        return null;
      }

      return AppStrings.get('invalidEmailOrUsername');
    }

    /// If the input does not contain "@", validate it as a username.
    if (_isValidUsername(input)) {
      return null;
    }

    return AppStrings.get('invalidEmailOrUsername');
  }

  /// Handles the login button press.
  ///
  /// For this university project stage, authentication is local/demo based.
  /// If the form is valid, the user is redirected to the Home Dashboard.
  void _login() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  /// Updates the selected language from the dropdown.
  void _updateLanguage(String? value) {
    if (value == null) return;

    setState(() {
      _selectedLanguage = value;
    });

    widget.onLanguageChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        /// SingleChildScrollView prevents overflow on smaller screens.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          /// Card gives the login form a clean and professional look.
          child: Card(
            elevation: 3,
            child: Padding(
              padding: const EdgeInsets.all(24),

              /// ConstrainedBox keeps the form from becoming too wide on web.
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Application icon.
                      const Icon(
                        Icons.health_and_safety,
                        size: 64,
                        color: Colors.teal,
                      ),

                      const SizedBox(height: 16),

                      /// Application title.
                      Text(
                        AppStrings.get('appTitle'),
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 24),

                      /// Language selector.
                      DropdownButtonFormField<String>(
                        initialValue: _selectedLanguage,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('language'),
                          border: const OutlineInputBorder(),
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
                        onChanged: _updateLanguage,
                      ),

                      const SizedBox(height: 16),

                      /// Email or username input field.
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('email'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.person),
                        ),

                        /// Validates whether the input is a proper email
                        /// or a proper username.
                        validator: _validateEmailOrUsername,
                      ),

                      const SizedBox(height: 16),

                      /// Password input field.
                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: AppStrings.get('password'),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                        ),

                        /// Basic password validation.
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return AppStrings.get('enterPassword');
                          }

                          if (value.trim().length < 4) {
                            return AppStrings.get('passwordLength');
                          }

                          return null;
                        },
                      ),

                      const SizedBox(height: 24),

                      /// Login button.
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _login,
                          icon: const Icon(Icons.login),
                          label: Text(AppStrings.get('login')),
                        ),
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