import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../utils/constants.dart';
import 'dart:developer' as developer;

class TopPerformersScreen extends StatefulWidget {
  const TopPerformersScreen({super.key});

  @override
  _TopPerformersScreenState createState() => _TopPerformersScreenState();
}

class _TopPerformersScreenState extends State<TopPerformersScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
      developer.log('Fetching reports for top performers on init');
    } catch (e) {
      developer.log('Fetch reports on init failed: $e');
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
    final topPerformers = List.from(studentProvider.reports)
      ..sort((a, b) => b.completionRate.compareTo(a.completionRate));
    final topFive = topPerformers.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Top Performers'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.primaryGradient,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.cardGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: topFive.isEmpty
              ? const Center(
            child: Text(
              'No top performers available',
              style: AppConstants.headingStyle,
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(8.0),
            itemCount: topFive.length,
            itemBuilder: (context, index) {
              final performer = topFive[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 5,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: AppConstants.cardGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: const Icon(Icons.star, color: Colors.amber, size: 30),
                    title: Text(
                      'Student ID: ${performer.studentId}',
                      style: AppConstants.headingStyle.copyWith(fontSize: 18),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Completion Rate: ${performer.completionRate.toStringAsFixed(1)}%',
                          style: AppConstants.subheadingStyle,
                        ),
                        Text(
                          'Tasks: ${performer.completedTasks}/${performer.totalTasks}',
                          style: AppConstants.subheadingStyle,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}