import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:uuid/uuid.dart';
import '../models/user.dart';
import '../models/task.dart';
import '../models/report.dart';
import 'dart:developer' as developer;

class SupabaseService {
  final client = supabase.Supabase.instance.client;
  final uuid = const Uuid();

  Future<void> addStudent(String name, String email) async {
    try {
      await client.from('users').insert({
        'id': uuid.v4(),
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'student',
        'created_at': DateTime.now().toIso8601String(),
      });
      developer.log('Student added: $name, $email');
    } catch (e) {
      developer.log('Add student failed: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to add student: $e');
    }
  }

  Future<List<User>> getStudents() async {
    try {
      final response = await client.from('users').select().eq('role', 'student');
      final students = response.map((json) => User.fromJson(json)).toList();
      developer.log('Fetched ${students.length} students');
      return students;
    } catch (e) {
      developer.log('Get students failed: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to fetch students: $e');
    }
  }

  Future<void> addTask(String title, String assignedTo, {String? description, DateTime? dueDate}) async {
    try {
      await client.from('tasks').insert({
        'id': uuid.v4(),
        'title': title.trim(),
        'description': description?.trim(),
        'assigned_to': assignedTo,
        'status': 'pending',
        'due_date': dueDate?.toIso8601String(),
        'created_by': 'admin',
        'created_at': DateTime.now().toIso8601String(),
      });
      developer.log('Task added: $title, assigned to: $assignedTo');
    } catch (e) {
      developer.log('Add task failed: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to add task: $e');
    }
  }

  Future<List<Task>> getTasks() async {
    try {
      final response = await client.from('tasks').select();
      final tasks = response.map((json) => Task.fromJson(json)).toList();
      developer.log('Fetched ${tasks.length} tasks');
      return tasks;
    } catch (e) {
      developer.log('Get tasks failed: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to fetch tasks: $e');
    }
  }

  Future<void> addReport(String studentId, double completionRate, int totalTasks, int completedTasks) async {
    try {
      await client.from('reports').insert({
        'id': uuid.v4(),
        'student_id': studentId,
        'completion_rate': completionRate,
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'report_date': DateTime.now().toIso8601String().split('T')[0],
        'created_at': DateTime.now().toIso8601String(),
      });
      developer.log('Report added for student: $studentId');
    } catch (e) {
      developer.log('Add report failed: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to add report: $e');
    }
  }

  Future<List<Report>> getReports() async {
    try {
      final response = await client.from('reports').select();
      final reports = response.map((json) => Report.fromJson(json)).toList();
      developer.log('Fetched ${reports.length} reports');
      return reports;
    } catch (e) {
      developer.log('Get reports failed: $e', stackTrace: StackTrace.current);
      throw Exception('Failed to fetch reports: $e');
    }
  }

  void subscribeToTasks(Function(List<Task>) onUpdate) {
    try {
      client
          .channel('public:tasks')
          .onPostgresChanges(
        event: supabase.PostgresChangeEvent.all,
        schema: 'public',
        table: 'tasks',
        callback: (_) => getTasks().then(onUpdate),
      )
          .subscribe();
      developer.log('Subscribed to tasks');
    } catch (e) {
      developer.log('Task subscription failed: $e', stackTrace: StackTrace.current);
    }
  }

  void subscribeToReports(Function(List<Report>) onUpdate) {
    try {
      client
          .channel('public:reports')
          .onPostgresChanges(
        event: supabase.PostgresChangeEvent.all,
        schema: 'public',
        table: 'reports',
        callback: (_) => getReports().then(onUpdate),
      )
          .subscribe();
      developer.log('Subscribed to reports');
    } catch (e) {
      developer.log('Report subscription failed: $e', stackTrace: StackTrace.current);
    }
  }
}