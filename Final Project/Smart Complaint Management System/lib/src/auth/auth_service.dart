import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final SupabaseClient client = Supabase.instance.client;

  // Sign in with email and password
  Future<AuthResponse> signIn(String email, String password) async {
    try {
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      // Check if email is confirmed
      if (response.user != null && response.user!.emailConfirmedAt == null) {
        print('Warning: User email not confirmed: ${response.user!.email}');
        // For development/testing purposes, we can allow login even with unconfirmed email
        // In production, you might want to enforce email confirmation
        print('Allowing login despite unconfirmed email for development purposes');
      }
      
      return response;
    } catch (e) {
      print('Sign in error: $e');
      
      // Provide more specific error messages
      if (e.toString().contains('Invalid login credentials')) {
        throw AuthException('Invalid email or password. Please check your credentials.');
      } else if (e.toString().contains('Email not confirmed') || 
                 e.toString().contains('email not confirmed') ||
                 e.toString().contains('Email not verified')) {
        throw AuthException('Email not confirmed. Please check your email and click the confirmation link, or contact your administrator for assistance.');
      } else if (e.toString().contains('email login are disabled') ||
                 e.toString().contains('Email login are disabled') ||
                 e.toString().contains('email signups are disabled')) {
        throw AuthException('Email authentication is disabled. Please contact your administrator to enable email login in Supabase settings.');
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        throw AuthException('Network error. Please check your internet connection.');
      } else if (e.toString().contains('timeout')) {
        throw AuthException('Connection timeout. Please try again.');
      } else {
        rethrow;
      }
    }
  }

  // Sign out
  Future<void> signOut() async {
    await client.auth.signOut();
  }

  // Get current user
  User? get currentUser => client.auth.currentUser;

  // Sign up (for admin use only)
  Future<AuthResponse> signUp(String email, String password, {bool requireEmailConfirmation = false}) async {
    try {
      final response = await client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: requireEmailConfirmation ? null : 'io.supabase.flutter://login-callback/',
      );
      
      print('Sign up response: ${response.user?.email}');
      print('Email confirmed: ${response.user?.emailConfirmedAt}');
      
      return response;
    } catch (e) {
      print('Sign up error: $e');
      rethrow;
    }
  }

  // Resend email confirmation
  Future<void> resendEmailConfirmation(String email) async {
    try {
      await client.auth.resend(
        type: OtpType.signup,
        email: email,
      );
      print('Email confirmation resent to: $email');
    } catch (e) {
      print('Error resending email confirmation: $e');
      rethrow;
    }
  }

  // Check if user email is confirmed
  bool isEmailConfirmed(User user) {
    return user.emailConfirmedAt != null;
  }

  // Get user confirmation status message
  String getEmailConfirmationMessage(User user) {
    if (user.emailConfirmedAt == null) {
      return 'Email not confirmed. Please check your email and click the confirmation link.';
    }
    return 'Email confirmed on ${user.emailConfirmedAt}';
  }

  // Admin function to update user email confirmation status (for development/testing)
  Future<void> updateUserEmailConfirmation(String userId, bool confirmed) async {
    try {
      // This would require admin privileges in Supabase
      // For now, we'll just log the action
      print('Admin action: Update email confirmation for user $userId to $confirmed');
      print('Note: This requires admin privileges in Supabase dashboard');
    } catch (e) {
      print('Error updating email confirmation: $e');
      rethrow;
    }
  }
}

// Custom exception for authentication errors
class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  
  @override
  String toString() => message;
} 