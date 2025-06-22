import 'package:flutter/material.dart';

// TODO: Implement Student Dashboard
class StudentDashboard extends StatelessWidget {
  const StudentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Student Dashboard')),
      body: const Center(
        child: Text('Student Dashboard: Submit/View Complaints'),
      ),
      // TODO: Add navigation to complaint_submission and complaint_history
    );
  }
}