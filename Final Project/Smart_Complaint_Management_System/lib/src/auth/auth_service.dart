import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/constants.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<String?> login(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      final userId = response.user?.id;
      if (userId == null) throw Exception('Login failed: No user ID');

      // Fetch user role from users table
      final userData = await _supabase
          .from('users')
          .select('role')
          .eq('id', userId)
          .single();
      return userData['role'] as String?;
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }
}