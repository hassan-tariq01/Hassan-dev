import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  _TodayScreenState createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final todayWeekday = DateFormat('EEEE').format(now);

    // Filter tasks into repeated and non-repeated
    final repeatedTasks = taskProvider.tasks.where((task) {
      if (task.isCompleted) return false;
      return task.isRepeated && task.repeatDays.split(',').contains(todayWeekday);
    }).toList();

    final nonRepeatedTasks = taskProvider.tasks.where((task) {
      if (task.isCompleted) return false;
      if (task.isRepeated) return false;
      final taskDate = DateTime(task.date.year, task.date.month, task.date.day);
      return taskDate.isAtSameMomentAs(today);
    }).toList();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Repeated Tasks Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Repeated Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          repeatedTasks.isEmpty
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No repeated tasks for today.'),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: repeatedTasks.length,
            itemBuilder: (context, index) {
              Task task = repeatedTasks[index];
              return TaskTile(
                task: task,
                onUpdate: () => taskProvider.loadTasks(),
                isEditable: true,
                showContextMenu: () => _showTaskOptions(context, task, taskProvider),
              );
            },
          ),
          const Divider(),
          // Non-Repeated Tasks Section
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Non-Repeated Tasks',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          nonRepeatedTasks.isEmpty
              ? const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text('No non-repeated tasks for today.'),
          )
              : ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: nonRepeatedTasks.length,
            itemBuilder: (context, index) {
              Task task = nonRepeatedTasks[index];
              return TaskTile(
                task: task,
                onUpdate: () => taskProvider.loadTasks(),
                isEditable: true,
                showContextMenu: () => _showTaskOptions(context, task, taskProvider),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showTaskOptions(BuildContext context, Task task, TaskProvider taskProvider) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Task'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/add_edit_task', arguments: task);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Delete Task'),
              onTap: () async {
                Navigator.pop(context);
                await taskProvider.deleteTask(task.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.check_circle),
              title: Text(task.isCompleted ? 'Mark as Incomplete' : 'Mark as Completed'),
              onTap: () async {
                Navigator.pop(context);
                task.isCompleted = !task.isCompleted;
                await taskProvider.updateTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}