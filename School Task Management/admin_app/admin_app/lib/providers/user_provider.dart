import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/supabase_service.dart';
import 'dart:developer' as developer;

class UserProvider with ChangeNotifier {
  User? _user;
  User? get user => _user;

  final SupabaseService _supabaseService = SupabaseService();

  Future<void> setAdmin() async {
    try {
      _user = User(
        id: 'admin',
        name: 'Admin',
        email: 'admin@taskmanagement.com',
        role: 'admin',
        createdAt: DateTime.now(),
      );
      notifyListeners();
      developer.log('Admin set successfully');
    } catch (e) {
      developer.log('Set admin failed: $e');
    }
  }
}