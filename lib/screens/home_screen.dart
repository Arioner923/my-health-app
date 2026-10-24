import 'package:flutter/material.dart';

import '../core/services/api_service.dart';
import '../localization/app_strings.dart';
import '../models/home_module.dart';

/// Home dashboard screen.
///
/// This screen appears after a successful login.
/// It displays:
/// - motivational message from an external API
/// - Heraklion temperature
/// - Heraklion air quality index
/// - quick access buttons to all health modules
class HomeScreen extends StatefulWidget {
  // Callback used to change the application language.
  final void Function(String languageCode) onLanguageChanged;

  const HomeScreen({
    super.key,
    required this.onLanguageChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  /// Stores the motivational message returned from the API.
  String? _motivationalMessage;

  /// Stores the current temperature for Heraklion.
  double? _temperature;

  /// Stores the current air quality index for Heraklion.
  int? _airQualityIndex;

  /// Shows whether the dashboard API data is still loading.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// API calls are triggered when the HomeScreen is created.
    /// Since the HomeScreen opens after login, this satisfies the requirement
    /// that data should be retrieved after a successful login.
    _loadDashboardApiData();
  }

  /// Loads the Home Dashboard API data.
  ///
  /// This method is used both on the first HomeScreen load and when
  /// the user presses the refresh button.
  ///
  /// Important:
  /// - On the first load, a loading message can be shown.
  /// - On refresh, the old API values remain visible until the new values arrive.
  /// - Each API request has its own timeout and fallback handling.
  Future<void> _loadDashboardApiData() async {
    /// Detect if this is the first time the dashboard loads.
    /// If we already have data, we do not hide the cards during refresh.
    final bool isFirstLoad =
        _motivationalMessage == null &&
        _temperature == null &&
        _airQualityIndex == null;

    if (isFirstLoad) {
      setState(() {
        _isLoading = true;
      });
    }

    try {
      /// Load the motivational quote.
      ///
      /// If the quote API is slow or unavailable, the previous quote remains.
      final String quote = await ApiService.fetchMotivationalMessage()
          .timeout(
            const Duration(seconds: 6),
            onTimeout: () =>
                _motivationalMessage ?? AppStrings.get('unavailable'),
          )
          .catchError((error) {
            debugPrint('Motivation API error: $error');
            return _motivationalMessage ?? AppStrings.get('unavailable');
          });

      /// Load the Heraklion temperature.
      ///
      /// If the weather API fails, the previous temperature remains.
      final double? temperature = await ApiService.fetchHeraklionTemperature()
          .timeout(
            const Duration(seconds: 6),
            onTimeout: () => _temperature,
          )
          .catchError((error) {
            debugPrint('Weather API error: $error');
            return _temperature;
          });

      /// Load the Heraklion air quality index.
      ///
      /// If the air quality API fails, the previous air quality value remains.
      final int? airQualityIndex =
          await ApiService.fetchHeraklionAirQualityIndex()
              .timeout(
                const Duration(seconds: 6),
                onTimeout: () => _airQualityIndex,
              )
              .catchError((error) {
                debugPrint('Air Quality API error: $error');
                return _airQualityIndex;
              });

      if (!mounted) return;

      setState(() {
        _motivationalMessage = quote;
        _temperature = temperature;
        _airQualityIndex = airQualityIndex;
        _isLoading = false;
      });
    } catch (error) {
      /// General safety fallback.
      ///
      /// The HomeScreen must remain usable even if all APIs fail.
      debugPrint('Dashboard API general error: $error');

      if (!mounted) return;

      setState(() {
        _motivationalMessage ??= AppStrings.get('unavailable');
        _isLoading = false;
      });
    }
  }

  /// Refreshes only the motivational quote.
  ///
  /// This method is called when the user returns to the HomeScreen
  /// from another module. It updates only the quote and avoids
  /// unnecessary weather and air quality API requests.
  Future<void> _refreshMotivationalQuote() async {
    try {
      final String quote = await ApiService.fetchMotivationalMessage();

      if (!mounted) return;

      setState(() {
        _motivationalMessage = quote;
      });
    } catch (error) {
      /// If the quote API fails, the previous quote remains visible.
      debugPrint('Motivational quote refresh error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    /// List of dashboard modules.
    ///
    /// Each module contains:
    /// - title
    /// - icon
    /// - route
    final List<HomeModule> modules = [
      HomeModule(
        title: AppStrings.get('patientDemographics'),
        icon: Icons.person,
        route: '/demographics',
      ),
      HomeModule(
        title: AppStrings.get('who5'),
        icon: Icons.psychology,
        route: '/who5',
      ),
      HomeModule(
        title: AppStrings.get('framingham'),
        icon: Icons.favorite,
        route: '/framingham',
      ),
      HomeModule(
        title: AppStrings.get('findrisc'),
        icon: Icons.bloodtype,
        route: '/findrisc',
      ),
      HomeModule(
        title: AppStrings.get('allergies'),
        icon: Icons.warning_amber,
        route: '/allergies',
      ),
      HomeModule(
        title: AppStrings.get('medications'),
        icon: Icons.medication,
        route: '/medications',
      ),
      HomeModule(
        title: AppStrings.get('problemList'),
        icon: Icons.medical_information,
        route: '/problems',
      ),
      HomeModule(
        title: AppStrings.get('calendar'),
        icon: Icons.calendar_month,
        route: '/calendar',
      ),
      HomeModule(
        title: AppStrings.get('charts'),
        icon: Icons.show_chart,
        route: '/charts',
      ),
      HomeModule(
        title: AppStrings.get('settings'),
        icon: Icons.settings,
        route: '/settings',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('home')),

        /// AppBar actions contain language selection, refresh and logout.
        actions: [
          /// Manual refresh button for API data.
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardApiData,
          ),

          /// Language menu.
          PopupMenuButton<String>(
            icon: const Icon(Icons.language),
            onSelected: widget.onLanguageChanged,
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'en',
                child: Text(AppStrings.get('english')),
              ),
              PopupMenuItem(
                value: 'el',
                child: Text(AppStrings.get('greek')),
              ),
            ],
          ),

          /// Logout button.
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),

      body: Center(
        /// The Center widget keeps the dashboard content aligned nicely on web.
        child: ConstrainedBox(
          /// Maximum width prevents the dashboard from becoming too wide on web.
          constraints: const BoxConstraints(maxWidth: 1100),

          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                /// Welcome dashboard card.
                Card(
                  elevation: 2,
                  child: ListTile(
                    leading: const Icon(
                      Icons.health_and_safety,
                      color: Colors.teal,
                      size: 40,
                    ),
                    title: Text(
                      AppStrings.get('welcome'),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    subtitle: Text(AppStrings.get('dashboardSubtitle')),
                  ),
                ),

                const SizedBox(height: 12),

                /// API cards section.
                ///
                /// It contains the motivational message and environmental data.
                if (_isLoading)
                  Card(
                    elevation: 2,
                    child: ListTile(
                      leading: const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(strokeWidth: 3),
                      ),
                      title: Text(AppStrings.get('loadingData')),
                    ),
                  )
                else
                  _buildApiCards(context),

                const SizedBox(height: 16),

                /// Responsive grid with all application modules.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      /// Decide how many cards should appear per row.
                      int crossAxisCount;

                      if (constraints.maxWidth < 600) {
                        crossAxisCount = 2;
                      } else if (constraints.maxWidth < 900) {
                        crossAxisCount = 3;
                      } else {
                        crossAxisCount = 4;
                      }

                      return GridView.builder(
                        itemCount: modules.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,

                          /// Fixed card height keeps the card layout stable.
                          mainAxisExtent: 150,
                        ),
                        itemBuilder: (context, index) {
                          final HomeModule module = modules[index];

                          return Card(
                            elevation: 2,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(12),

                              /// Opens the selected module screen.
                              onTap: () async {                            
                              /// When the user comes back to the HomeScreen,
                              /// the motivational quote is refreshed.
                              await Navigator.pushNamed(context, module.route);

                              /// Refresh only the quote after returning to Home.
                              /// This keeps the dashboard dynamic without making unnecessary
                              /// weather and air quality API calls.
                              await _refreshMotivationalQuote();
                            },

                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      module.icon,
                                      size: 40,
                                      color: Colors.teal,
                                    ),

                                    const SizedBox(height: 12),

                                    /// Flexible prevents long text from causing overflow.
                                    Flexible(
                                      child: Text(
                                        module.title,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the API data cards shown on the Home Dashboard.
  ///
  /// On mobile screens, the cards are displayed vertically.
  /// On wider screens, the cards are displayed horizontally.
  ///
  /// Expanded is used only inside Row, not inside Column,
  /// because using Expanded inside a Column with unbounded height
  /// can cause layout errors on mobile devices.
  Widget _buildApiCards(BuildContext context) {
    final String temperatureText = _temperature == null
        ? AppStrings.get('unavailable')
        : '${_temperature!.toStringAsFixed(1)} °C';

    final String airQualityText = _airQualityIndex == null
        ? AppStrings.get('unavailable')
        : _airQualityIndex.toString();

    final Widget motivationCard = _InfoCard(
      icon: Icons.format_quote,
      title: AppStrings.get('motivation'),
      subtitle: _motivationalMessage ?? AppStrings.get('unavailable'),
    );

    final Widget environmentCard = _InfoCard(
      icon: Icons.thermostat,
      title: AppStrings.get('environment'),
      subtitle:
          '${AppStrings.get('temperature')}: $temperatureText\n'
          '${AppStrings.get('airQuality')}: $airQualityText',
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 700) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              motivationCard,
              const SizedBox(height: 12),
              environmentCard,
            ],
          );
        }

        return Row(
          children: [
            Expanded(child: motivationCard),
            const SizedBox(width: 12),
            Expanded(child: environmentCard),
          ],
        );
      },
    );
  }       
}

/// Reusable information card used for API data.
///
/// This keeps the HomeScreen UI cleaner and avoids repeating the same
/// Card/ListTile layout multiple times.
class _InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.teal,
          size: 32,
        ),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}