import 'package:flutter/material.dart';

// TODO: Implement Complaint Card
class ComplaintCard extends StatelessWidget {
  const ComplaintCard({super.key});

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: ListTile(
        title: Text('Complaint Title'),
        subtitle: Text('Status: Submitted'),
      ),
    );
    // TODO: Add complaint details and navigation to complaint_detail
  }
}