import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/student_provider.dart';
import '../utils/constants.dart';
import 'dart:developer' as developer;

class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  _PerformanceScreenState createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _showBarChart = true;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      studentProvider.fetchReports();
      studentProvider.subscribeToReports();
      developer.log('Fetching and subscribing to reports on init');
    } catch (e) {
      developer.log('Report init failed: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Performance'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.primaryGradient,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_showBarChart ? Icons.show_chart : Icons.bar_chart),
            onPressed: () {
              setState(() {
                _showBarChart = !_showBarChart;
              });
            },
            tooltip: 'Toggle Chart Type',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.cardGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: studentProvider.reports.isEmpty
              ? const Center(
            child: Text(
              'No reports available',
              style: AppConstants.headingStyle,
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Performance Overview',
                  style: AppConstants.headingStyle,
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: _showBarChart
                      ? BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      barGroups: studentProvider.reports.asMap().entries.map((entry) {
                        final index = entry.key;
                        final report = entry.value;
                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: report.completionRate,
                              gradient: AppConstants.primaryGradient,
                              width: 20,
                            ),
                          ],
                        );
                      }).toList(),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < studentProvider.reports.length) {
                                return Text(
                                  studentProvider.reports[index].studentId.substring(0, 4),
                                  style: AppConstants.subheadingStyle,
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}%',
                              style: AppConstants.subheadingStyle,
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  )
                      : LineChart(
                    LineChartData(
                      lineBarsData: [
                        LineChartBarData(
                          spots: studentProvider.reports.asMap().entries.map((entry) {
                            return FlSpot(entry.key.toDouble(), entry.value.completionRate);
                          }).toList(),
                          isCurved: true,
                          gradient: LinearGradient(
                            colors: [Colors.indigo, Colors.amber],
                          ),
                          barWidth: 4,
                          belowBarData: BarAreaData(
                            show: true,
                            gradient: LinearGradient(
                              colors: [Colors.indigo.withOpacity(0.3), Colors.amber.withOpacity(0.3)],
                            ),
                          ),
                        ),
                      ],
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final index = value.toInt();
                              if (index < studentProvider.reports.length) {
                                return Text(
                                  studentProvider.reports[index].studentId.substring(0, 4),
                                  style: AppConstants.subheadingStyle,
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}%',
                              style: AppConstants.subheadingStyle,
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: FlGridData(show: false),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}