import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/task_database.dart';

class TaskTile extends StatelessWidget {
  final Task task;
  final Function? onUpdate;
  final bool isEditable;
  final VoidCallback? showContextMenu;

  const TaskTile({
    super.key,
    required this.task,
    this.onUpdate,
    this.isEditable = true,
    this.showContextMenu,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable && showContextMenu != null ? showContextMenu : null,
      child: ListTile(
        title: Text(task.title.isEmpty ? 'Untitled' : task.title),
        subtitle: Text(task.description.isEmpty ? 'No description' : task.description),
        trailing: isEditable
            ? IconButton(
          icon: Icon(task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked),
          onPressed: () async {
            task.isCompleted = !task.isCompleted;
            final db = TaskDatabase.instance;
            await db.updateTask(task);
            if (onUpdate != null) {
              onUpdate!();
            }
          },
        )
            : const Icon(Icons.check_circle, color: Colors.grey),
      ),
    );
  }
}