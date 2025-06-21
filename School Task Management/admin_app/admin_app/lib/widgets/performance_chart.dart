import 'package:flutter/material.dart';
import '../models/report.dart';
import '../utils/constants.dart';

class PerformanceChart extends StatelessWidget {
  final List<Report> reports;

  const PerformanceChart({super.key, required this.reports});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Performance Overview',
            style: AppConstants.headingStyle,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: reports.length,
              itemBuilder: (context, index) {
                final report = reports[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppConstants.cardGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Student ID: ${report.studentId}',
                          style: AppConstants.headingStyle.copyWith(fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Completion Rate: ${report.completionRate.toStringAsFixed(1)}%',
                          style: AppConstants.subheadingStyle,
                        ),
                        Text(
                          'Tasks: ${report.completedTasks}/${report.totalTasks}',
                          style: AppConstants.subheadingStyle,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}