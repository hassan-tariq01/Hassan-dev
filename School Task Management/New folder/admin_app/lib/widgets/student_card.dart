import 'package:flutter/material.dart';
import '../models/user.dart';
import '../utils/constants.dart';

class StudentCard extends StatelessWidget {
  final User student;

  const StudentCard({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
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
          title: Text(
            student.name,
            style: AppConstants.headingStyle.copyWith(fontSize: 18),
          ),
          subtitle: Text(
            student.email,
            style: AppConstants.subheadingStyle,
          ),
          trailing: const Icon(Icons.person, color: Colors.indigo),
        ),
      ),
    );
  }
}