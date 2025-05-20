import 'package:flutter/material.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'dart:developer' as developer;

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

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
            task.title,
            style: AppConstants.headingStyle.copyWith(fontSize: 18),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description != null)
                Text(
                  task.description!,
                  style: AppConstants.subheadingStyle,
                ),
              Text(
                'Assigned To: ${task.assignedTo}',
                style: AppConstants.subheadingStyle,
              ),
              Text(
                'Due: ${task.dueDate != null ? formatDate(task.dueDate!) : 'No due date'}',
                style: AppConstants.subheadingStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}