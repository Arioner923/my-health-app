import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/services/framingham_storage_service.dart';
import '../core/services/findrisc_storage_service.dart';
import '../core/services/who5_storage_service.dart';
import '../localization/app_strings.dart';
import '../models/framingham_result_model.dart';
import '../models/findrisc_result_model.dart';
import '../models/who5_result_model.dart';

/// Screen for graphical monitoring of health scores over time.
///
/// This screen displays line charts for:
/// - WHO-5 percentage scores
/// - Framingham estimated cardiovascular risk
/// - FINDRISC diabetes risk scores
///
/// The data is loaded from local storage using the same services used
/// by the questionnaire and risk score modules.
class ChartsScreen extends StatefulWidget {
  const ChartsScreen({super.key});

  @override
  State<ChartsScreen> createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  /// Saved WHO-5 results.
  List<Who5ResultModel> _who5Results = [];

  /// Saved Framingham results.
  List<FraminghamResultModel> _framinghamResults = [];

  /// Saved FINDRISC results.
  List<FindriscResultModel> _findriscResults = [];

  /// Shows whether chart data is still loading.
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    /// Load all score histories when the screen opens.
    _loadChartData();
  }

  /// Loads score data from local storage.
  Future<void> _loadChartData() async {
    final List<Who5ResultModel> who5Results =
        await Who5StorageService.loadResults();

    final List<FraminghamResultModel> framinghamResults =
        await FraminghamStorageService.loadResults();

    final List<FindriscResultModel> findriscResults =
        await FindriscStorageService.loadResults();

    if (!mounted) return;

    setState(() {
      _who5Results = who5Results;
      _framinghamResults = framinghamResults;
      _findriscResults = findriscResults;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.get('charts')),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      /// Header card.
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.show_chart,
                                size: 56,
                                color: Colors.teal,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                AppStrings.get('chartsTitle'),
                                textAlign: TextAlign.center,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                AppStrings.get('chartsInstructions'),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      /// WHO-5 chart.
                      _buildChartCard(
                        title: AppStrings.get('who5Chart'),
                        spots: _buildWho5Spots(),
                        maxY: 100,
                      ),

                      const SizedBox(height: 16),

                      /// Framingham chart.
                      _buildChartCard(
                        title: AppStrings.get('framinghamChart'),
                        spots: _buildFraminghamSpots(),
                        maxY: 30,
                      ),

                      const SizedBox(height: 16),

                      /// FINDRISC chart.
                      _buildChartCard(
                        title: AppStrings.get('findriscChart'),
                        spots: _buildFindriscSpots(),
                        maxY: 30,
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  /// Converts WHO-5 saved results into chart points.
  ///
  /// X-axis: result order
  /// Y-axis: WHO-5 percentage score
  List<FlSpot> _buildWho5Spots() {
    return List.generate(_who5Results.length, (index) {
      return FlSpot(
        index.toDouble(),
        _who5Results[index].percentageScore.toDouble(),
      );
    });
  }

  /// Converts Framingham saved results into chart points.
  ///
  /// X-axis: result order
  /// Y-axis: estimated cardiovascular risk percentage
  List<FlSpot> _buildFraminghamSpots() {
    return List.generate(_framinghamResults.length, (index) {
      return FlSpot(
        index.toDouble(),
        _framinghamResults[index].riskPercentage,
      );
    });
  }

  /// Converts FINDRISC saved results into chart points.
  ///
  /// X-axis: result order
  /// Y-axis: FINDRISC total score
  List<FlSpot> _buildFindriscSpots() {
    return List.generate(_findriscResults.length, (index) {
      return FlSpot(
        index.toDouble(),
        _findriscResults[index].totalScore.toDouble(),
      );
    });
  }

  /// Builds a reusable chart card.
  ///
  /// If there are not enough data points, the card displays a helpful message
  /// instead of an empty chart.
  Widget _buildChartCard({
    required String title,
    required List<FlSpot> spots,
    required double maxY,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 16),

            if (spots.length < 2)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  AppStrings.get('notEnoughData'),
                  textAlign: TextAlign.center,
                ),
              )
            else
              SizedBox(
                height: 260,
                child: LineChart(
                  LineChartData(
                    minX: 0,
                    maxX: (spots.length - 1).toDouble(),
                    minY: 0,
                    maxY: maxY,

                    /// Grid lines make the chart easier to read.
                    gridData: const FlGridData(show: true),

                    /// Border around the chart area.
                    borderData: FlBorderData(show: true),

                    /// Axis titles and labels.
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      bottomTitles: AxisTitles(
                        axisNameWidget: Text(AppStrings.get('date')),
                        sideTitles: const SideTitles(
                          showTitles: true,
                          interval: 1,
                          reservedSize: 28,
                        ),
                      ),
                      leftTitles: AxisTitles(
                        axisNameWidget: Text(AppStrings.get('score')),
                        sideTitles: const SideTitles(
                          showTitles: true,
                          reservedSize: 40,
                        ),
                      ),
                    ),

                    /// Main chart line.
                    lineBarsData: [
                      LineChartBarData(
                        spots: spots,
                        isCurved: true,
                        barWidth: 3,
                        color: Colors.teal,
                        dotData: const FlDotData(show: true),
                        belowBarData: BarAreaData(
                          show: true,
                          color: Colors.teal.withValues(alpha: 0.15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}