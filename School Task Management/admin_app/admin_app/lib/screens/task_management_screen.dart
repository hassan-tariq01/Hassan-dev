import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/student_provider.dart';
import '../widgets/task_card.dart';
import '../utils/helpers.dart';
import '../utils/constants.dart';
import 'dart:developer' as developer;

class TaskManagementScreen extends StatefulWidget {
  const TaskManagementScreen({super.key});

  @override
  _TaskManagementScreenState createState() => _TaskManagementScreenState();
}

class _TaskManagementScreenState extends State<TaskManagementScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final List<String> _assignedTo = [];
  DateTime? _dueDate;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  Future<void> _selectDueDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
      developer.log('Due date selected: $_dueDate');
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    try {
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      taskProvider.fetchTasks();
      taskProvider.subscribeToTasks();
      developer.log('Fetching and subscribing to tasks on init');
    } catch (e) {
      developer.log('Task init failed: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Tasks'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.primaryGradient,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.cardGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Task Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description (Optional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Assign to',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      isExpanded: true,
                      items: studentProvider.students
                          .map((student) => DropdownMenuItem<String>(
                        value: student.id,
                        child: Text(student.name),
                      ))
                          .toList(),
                      onChanged: (value) {
                        if (value != null && !_assignedTo.contains(value)) {
                          setState(() {
                            _assignedTo.add(value);
                          });
                        }
                      },
                      style: const TextStyle(color: Colors.black87),
                      dropdownColor: Colors.white,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: _assignedTo.map((id) {
                        final student = studentProvider.students.firstWhere((s) => s.id == id);
                        return Chip(
                          label: Text(student.name),
                          onDeleted: () {
                            setState(() {
                              _assignedTo.remove(id);
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dueDate == null
                                ? 'No due date selected'
                                : 'Due: ${formatDate(_dueDate!)}',
                            style: const TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _selectDueDate(context),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ).copyWith(
                            foregroundColor: WidgetStateProperty.all(Colors.white),
                            backgroundColor: WidgetStateProperty.all(Colors.transparent),
                            overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: AppConstants.primaryGradient,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            child: const Text(
                              'Select Due Date',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _assignedTo.isNotEmpty && _titleController.text.trim().isNotEmpty
                          ? () async {
                        try {
                          for (var studentId in _assignedTo) {
                            await taskProvider.addTask(
                              _titleController.text.trim(),
                              studentId,
                              description: _descriptionController.text.trim().isEmpty
                                  ? null
                                  : _descriptionController.text.trim(),
                              dueDate: _dueDate,
                            );
                          }
                          _titleController.clear();
                          _descriptionController.clear();
                          setState(() {
                            _assignedTo.clear();
                            _dueDate = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Tasks assigned successfully')),
                          );
                          developer.log('Tasks assigned via UI to ${_assignedTo.length} students');
                        } catch (e) {
                          developer.log('Assign tasks failed: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to assign tasks: $e')),
                          );
                        }
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ).copyWith(
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppConstants.primaryGradient,
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        child: const Text(
                          'Assign Task',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: taskProvider.tasks.length,
                  itemBuilder: (_, index) => TaskCard(task: taskProvider.tasks[index]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}