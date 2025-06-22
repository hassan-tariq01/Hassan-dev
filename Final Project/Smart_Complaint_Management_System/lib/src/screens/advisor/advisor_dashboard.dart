import 'package:flutter/material.dart';

// TODO: Implement Advisor Dashboard
class AdvisorDashboard extends StatelessWidget {
  const AdvisorDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Advisor Dashboard')),
      body: const Center(
        child: Text('Advisor Dashboard: View Batch Complaints'),
      ),
      // TODO: Add navigation to complaint_list
    );
  }
}