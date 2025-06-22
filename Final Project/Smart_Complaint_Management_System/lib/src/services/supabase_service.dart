import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final _supabase = Supabase.instance.client;

  // TODO: Implement CRUD operations for departments, users, batches, complaints
  Future<List<Map<String, dynamic>>> getDepartments() async {
    return await _supabase.from('departments').select();
  }

// TODO: Add methods for complaints, batches, notifications, etc.
}