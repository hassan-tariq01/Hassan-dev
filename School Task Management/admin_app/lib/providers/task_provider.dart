import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/supabase_service.dart';
import 'dart:developer' as developer;

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;

  final SupabaseService _supabaseService = SupabaseService();

  Future<void> fetchTasks() async {
    try {
      _tasks = await _supabaseService.getTasks();
      notifyListeners();
      developer.log('Tasks fetched successfully');
    } catch (e) {
      developer.log('Fetch tasks failed: $e');
    }
  }

  Future<void> addTask(String title, String assignedTo, {String? description, DateTime? dueDate}) async {
    try {
      await _supabaseService.addTask(title, assignedTo, description: description, dueDate: dueDate);
      await fetchTasks();
      developer.log('Task added successfully');
    } catch (e) {
      developer.log('Add task failed: $e');
    }
  }

  void subscribeToTasks() {
    try {
      _supabaseService.subscribeToTasks((tasks) {
        _tasks = tasks;
        notifyListeners();
        developer.log('Tasks updated via subscription');
      });
      developer.log('Subscribed to tasks');
    } catch (e) {
      developer.log('Task subscription failed: $e');
    }
  }
}