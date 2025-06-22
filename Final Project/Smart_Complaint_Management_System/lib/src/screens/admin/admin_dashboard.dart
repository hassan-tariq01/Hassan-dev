import 'package:flutter/material.dart';

// TODO: Implement Admin dashboard
class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard')),
      body: const Center(
        child: Text('Admin Dashboard: Stats, Navigation to Management Screens'),
      ),
      // TODO: Add navigation to department_management, batch_upload, etc.
      // TODO: Display complaint statistics using stats_dashboard
    );
  }
}