import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class SupabaseService {
  static final SupabaseService _instance = SupabaseService._internal();
  factory SupabaseService() => _instance;
  SupabaseService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // Users
  Future<List<Map<String, dynamic>>> getUsers({String? role}) async {
    final query = client.from(AppConstants.tableUsers).select();
    if (role != null) {
      query.eq('role', role);
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // Departments
  Future<List<Map<String, dynamic>>> getDepartments() async {
    final response = await client.from(AppConstants.tableDepartments).select();
    return List<Map<String, dynamic>>.from(response);
  }

  // Batches
  Future<List<Map<String, dynamic>>> getBatches({String? departmentId}) async {
    final query = client.from(AppConstants.tableBatches).select();
    if (departmentId != null) {
      query.eq('department_id', departmentId);
    }
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // Complaints
  Future<List<Map<String, dynamic>>> getComplaints({Map<String, dynamic>? filters}) async {
    var query = client.from(AppConstants.tableComplaints).select();
    filters?.forEach((key, value) {
      query = query.eq(key, value);
    });
    final response = await query;
    return List<Map<String, dynamic>>.from(response);
  }

  // Complaint Logs
  Future<List<Map<String, dynamic>>> getComplaintLogs(String complaintId) async {
    final response = await client
        .from(AppConstants.tableComplaintLogs)
        .select()
        .eq('complaint_id', complaintId)
        .order('timestamp');
    return List<Map<String, dynamic>>.from(response);
  }

  // Notifications
  Future<List<Map<String, dynamic>>> getNotifications(String userId) async {
    final response = await client
        .from(AppConstants.tableNotifications)
        .select()
        .eq('user_id', userId)
        .order('timestamp', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Storage: Upload file
  Future<String?> uploadMedia(String path, List<int> bytes) async {
    final uint8List = Uint8List.fromList(bytes);
    final response = await client.storage
        .from(AppConstants.mediaBucket)
        .uploadBinary(path, uint8List, fileOptions: const FileOptions(upsert: true));
    if (response.isEmpty) return null;
    return client.storage.from(AppConstants.mediaBucket).getPublicUrl(path);
  }

  // Storage: Delete file
  Future<void> deleteMedia(String path) async {
    await client.storage.from(AppConstants.mediaBucket).remove([path]);
  }
} 