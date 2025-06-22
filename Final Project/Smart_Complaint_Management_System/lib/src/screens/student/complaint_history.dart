import 'package:flutter/material.dart';

// TODO: Implement Complaint History
class ComplaintHistory extends StatelessWidget {
  const ComplaintHistory({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Complaint History')),
      body: const Center(
        child: Text('Complaint History: View Past Complaints'),
      ),
      // TODO: Add ListView with complaint_card for student’s complaints
    );
  }
}