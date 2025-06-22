import 'package:flutter/material.dart';

// TODO: Implement HOD Dashboard
class HodDashboard extends StatelessWidget {
  const HodDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HOD Dashboard')),
      body: const Center(
        child: Text('HOD Dashboard: View Escalated Complaints'),
      ),
      // TODO: Add navigation to escalated_complaint_list
    );
  }
}
