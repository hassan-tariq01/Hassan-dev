import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import '../widgets/task_tile.dart';
import '../services/task_database.dart';
import 'package:share_plus/share_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class CompletedScreen extends StatefulWidget {
  const CompletedScreen({super.key});

  @override
  CompletedScreenState createState() => CompletedScreenState();
}

class CompletedScreenState extends State<CompletedScreen> {
  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completedTasks = taskProvider.tasks.where((task) => task.isCompleted).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Completed Tasks'),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'export_csv') {
                final csvPath = await TaskDatabase.instance.exportToCsv();
                Share.shareFiles([csvPath], text: 'Exported Tasks CSV');
              } else if (value == 'export_pdf') {
                final pdf = pw.Document();
                pdf.addPage(
                  pw.Page(
                    build: (pw.Context context) => pw.Table(
                      children: completedTasks
                          .map((task) => pw.TableRow(
                        children: [
                          pw.Text(task.title),
                          pw.Text(task.description),
                          pw.Text(task.date.toString()),
                        ],
                      ))
                          .toList(),
                    ),
                  ),
                );
                final directory = await getTemporaryDirectory();
                final pdfPath = '${directory.path}/tasks.pdf';
                final file = File(pdfPath);
                await file.writeAsBytes(await pdf.save());
                Share.shareFiles([pdfPath], text: 'Exported Tasks PDF');
              } else if (value == 'export_email') {
                final csvPath = await TaskDatabase.instance.exportToCsv();
                Share.shareFiles([csvPath], text: 'Tasks exported for email', subject: 'Task Export');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'export_csv', child: Text('Export to CSV')),
              const PopupMenuItem(value: 'export_pdf', child: Text('Export to PDF')),
              const PopupMenuItem(value: 'export_email', child: Text('Export via Email')),
            ],
          ),
        ],
      ),
      body: completedTasks.isEmpty
          ? const Center(child: Text('No completed tasks.'))
          : ListView.builder(
        itemCount: completedTasks.length,
        itemBuilder: (context, index) {
          Task task = completedTasks[index];
          return TaskTile(
            task: task,
            onUpdate: () => taskProvider.loadTasks(),
            isEditable: true,
            showContextMenu: () => _showTaskOptions(context, task, taskProvider),
          );
        },
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
              leading: const Icon(Icons.delete),
              title: const Text('Delete Task'),
              onTap: () async {
                Navigator.pop(context);
                await taskProvider.deleteTask(task.id!);
              },
            ),
            ListTile(
              leading: const Icon(Icons.radio_button_unchecked),
              title: const Text('Mark as Incomplete'),
              onTap: () async {
                Navigator.pop(context);
                task.isCompleted = false;
                await taskProvider.updateTask(task);
              },
            ),
          ],
        ),
      ),
    );
  }
}