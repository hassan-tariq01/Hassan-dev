import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/user.dart' as app;
import '../models/report.dart';
import 'dart:developer' as developer;

class StudentProvider with ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<app.User> _students = [];
  List<Report> _reports = [];
  String? _errorMessage;

  List<app.User> get students => _students;
  List<Report> get reports => _reports;
  String? get errorMessage => _errorMessage;

  Future<void> fetchStudents() async {
    try {
      final response = await _supabase.from('users').select().eq('role', 'student');
      _students = (response as List<dynamic>).map((json) => app.User.fromJson(json)).toList();
      _errorMessage = null;
      developer.log('Fetched ${_students.length} students');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch students: $e';
      developer.log('Fetch students error: $e');
      notifyListeners();
    }
  }

  Future<void> addStudent(String name, String email) async {
    try {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        throw 'Invalid email format';
      }
      final uuid = const Uuid().v4();
      await _supabase.from('users').insert({
        'id': uuid,
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'role': 'student',
      });
      await fetchStudents();
      _errorMessage = null;
      developer.log('Added student: $name, $email, ID: $uuid');
    } catch (e) {
      _errorMessage = 'Failed to add student: $e';
      developer.log('Add student error: $e');
      notifyListeners();
      rethrow; // Rethrow to allow UI to catch and display error
    }
  }

  Future<void> updateStudent(String id, String name, String email) async {
    try {
      final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
      if (!emailRegex.hasMatch(email)) {
        throw 'Invalid email format';
      }
      await _supabase.from('users').update({
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
      }).eq('id', id);
      await fetchStudents();
      _errorMessage = null;
      developer.log('Updated student: $id');
    } catch (e) {
      _errorMessage = 'Failed to update student: $e';
      developer.log('Update student error: $e');
      notifyListeners();
    }
  }

  Future<void> deleteStudent(String id) async {
    try {
      await _supabase.from('tasks').delete().eq('assigned_to', id);
      await _supabase.from('users').delete().eq('id', id);
      await fetchStudents();
      _errorMessage = null;
      developer.log('Deleted student and tasks: $id');
    } catch (e) {
      _errorMessage = 'Failed to delete student: $e';
      developer.log('Delete student error: $e');
      notifyListeners();
    }
  }

  Future<void> fetchReports() async {
    try {
      final response = await _supabase.from('reports').select();
      _reports = (response as List<dynamic>).map((json) => Report.fromJson(json)).toList();
      _errorMessage = null;
      developer.log('Fetched ${_reports.length} reports');
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to fetch reports: $e';
      developer.log('Fetch reports error: $e');
      notifyListeners();
    }
  }

  Future<void> subscribeToReports() async {
    try {
      _supabase.from('reports').stream(primaryKey: ['student_id']).listen((List<Map<String, dynamic>> data) {
        _reports = data.map((json) => Report.fromJson(json)).toList();
        developer.log('Reports stream updated: ${_reports.length} reports');
        notifyListeners();
      });
      developer.log('Subscribed to reports');
    } catch (e) {
      developer.log('Subscribe to reports error: $e');
    }
  }
}