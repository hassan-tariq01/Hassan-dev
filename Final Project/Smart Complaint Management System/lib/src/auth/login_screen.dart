import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../utils/routes.dart';
import '../services/supabase_service.dart';
import 'auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String _selectedRole = AppConstants.roleStudent; // Default role

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    
    try {
      print('=== LOGIN ATTEMPT ===');
      print('Email: ${_emailController.text.trim()}');
      print('Selected Role: $_selectedRole');
      
      // First, authenticate with Supabase
      final response = await AuthService().signIn(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      );
      
      print('Auth response: ${response.user?.id}');
      
      if (response.user == null) {
        print('Authentication failed: No user returned');
        setState(() {
          _errorMessage = 'Invalid email or password. Please try again.';
        });
        return;
      }
      
      // Check email confirmation status
      if (response.user!.emailConfirmedAt == null) {
        print('User email not confirmed: ${response.user!.email}');
        // For development, we'll allow login but show a warning
        print('Allowing login despite unconfirmed email for development purposes');
        
        // Show a warning dialog about email confirmation
        if (mounted) {
          final shouldContinue = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Email Not Confirmed'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your email address has not been confirmed yet. '
                    'For development purposes, you can continue to login. '
                    'In production, you would need to confirm your email first.\n\n'
                    'Would you like to continue with login?',
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Email: ${_emailController.text.trim()}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange[200]!),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Quick Solutions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '1. Check your email inbox and spam folder\n'
                          '2. Click "Resend Email" to get a new confirmation\n'
                          '3. Contact admin to disable email confirmation\n'
                          '4. Continue login (development mode)',
                          style: TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                    _resendEmailConfirmation(_emailController.text.trim());
                  },
                  child: const Text('Resend Email'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Continue'),
                ),
              ],
            ),
          );
          
          if (shouldContinue != true) {
            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
      }
      
      // Fetch user data from database
      print('Fetching user data from database...');
        final users = await SupabaseService().getUsers();
      print('Total users in database: ${users.length}');
      
        final user = users.where(
          (u) => u['email'] == _emailController.text.trim(),
        ).firstOrNull;
      
        if (user == null) {
        print('User not found in database');
        setState(() {
          _errorMessage = 'User not found in database. Please contact administrator.';
        });
        return;
      }
      
      print('User found in database: ${user['name']}');
      print('User role in database: ${user['role']}');
      print('User batch_id: ${user['batch_id']}');
      print('User department_id: ${user['department_id']}');
      
      final userRole = user['role'];
      
      // Check if user role matches selected role
      if (userRole != _selectedRole) {
        print('Role mismatch: Expected $_selectedRole, got $userRole');
        setState(() {
          _errorMessage = 'Invalid login type. Please select the correct role: $userRole';
        });
        return;
      }
      
      // Additional role-specific checks
      if (userRole == AppConstants.roleStudent) {
        if (user['batch_id'] == null || user['batch_id'].toString().isEmpty) {
          print('Student has no batch assigned');
          setState(() {
            _errorMessage = 'Student account not properly configured. Please contact administrator.';
          });
          return;
        }
      } else if (userRole == AppConstants.roleBatchAdvisor) {
        if (user['department_id'] == null || user['department_id'].toString().isEmpty) {
          print('Advisor has no department assigned');
          setState(() {
            _errorMessage = 'Advisor account not properly configured. Please contact administrator.';
          });
          return;
        }
      } else if (userRole == AppConstants.roleHOD) {
        if (user['department_id'] == null || user['department_id'].toString().isEmpty) {
          print('HOD has no department assigned');
          setState(() {
            _errorMessage = 'HOD account not properly configured. Please contact administrator.';
          });
          return;
        }
      }
      
      print('Login successful! Navigating to dashboard...');
      
      // Navigate based on role
      if (userRole == AppConstants.roleAdmin) {
            AppRoutes.goToAdminDashboard(context);
      } else if (userRole == AppConstants.roleBatchAdvisor) {
            AppRoutes.goToAdvisorDashboard(context);
      } else if (userRole == AppConstants.roleHOD) {
            AppRoutes.goToHODDashboard(context);
      } else if (userRole == AppConstants.roleStudent) {
            AppRoutes.goToStudentDashboard(context);
          } else {
        print('Unknown user role: $userRole');
            setState(() {
          _errorMessage = 'Unknown user role: $userRole';
        });
      }
      
    } catch (e) {
      print('Login error: $e');
      print('Error details: ${e.toString()}');
      
      // Handle AuthException specifically
      if (e is AuthException) {
        setState(() {
          _errorMessage = e.message;
            });
      } else {
        // Provide more specific error messages for other exceptions
        if (e.toString().contains('Invalid login credentials')) {
          setState(() {
            _errorMessage = 'Invalid email or password. Please check your credentials.';
          });
        } else if (e.toString().contains('Email not confirmed') || e.toString().contains('email not confirmed')) {
          setState(() {
            _errorMessage = 'Email not confirmed. Please check your email and click the confirmation link, or contact administrator.';
          });
        } else if (e.toString().contains('email login are disabled') ||
                   e.toString().contains('Email login are disabled') ||
                   e.toString().contains('email signups are disabled')) {
          setState(() {
            _errorMessage = 'Email authentication is disabled. Please contact your administrator to enable email login in Supabase settings.';
          });
        } else if (e.toString().contains('network') || e.toString().contains('connection')) {
      setState(() {
            _errorMessage = 'Network error. Please check your internet connection.';
          });
        } else if (e.toString().contains('timeout')) {
          setState(() {
            _errorMessage = 'Connection timeout. Please try again.';
      });
        } else {
          setState(() {
            _errorMessage = 'Login failed: ${e.toString()}';
          });
        }
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _debugUserAccounts() async {
    try {
      print('=== DEBUGGING USER ACCOUNTS ===');
      
      final users = await SupabaseService().getUsers();
      print('Total users in database: ${users.length}');
      
      // Group users by role
      final students = users.where((u) => u['role'] == AppConstants.roleStudent).toList();
      final advisors = users.where((u) => u['role'] == AppConstants.roleBatchAdvisor).toList();
      final hods = users.where((u) => u['role'] == AppConstants.roleHOD).toList();
      final admins = users.where((u) => u['role'] == AppConstants.roleAdmin).toList();
      
      print('Students: ${students.length}');
      print('Advisors: ${advisors.length}');
      print('HODs: ${hods.length}');
      print('Admins: ${admins.length}');
      
      // Show sample users for each role
      if (students.isNotEmpty) {
        print('Sample students:');
        for (int i = 0; i < students.length && i < 3; i++) {
          final student = students[i];
          print('  - ${student['name']} (${student['email']}) - Batch: ${student['batch_id']}');
        }
      }
      
      if (advisors.isNotEmpty) {
        print('Sample advisors:');
        for (int i = 0; i < advisors.length && i < 3; i++) {
          final advisor = advisors[i];
          print('  - ${advisor['name']} (${advisor['email']}) - Dept: ${advisor['department_id']}');
        }
      }
      
      if (hods.isNotEmpty) {
        print('Sample HODs:');
        for (int i = 0; i < hods.length && i < 3; i++) {
          final hod = hods[i];
          print('  - ${hod['name']} (${hod['email']}) - Dept: ${hod['department_id']}');
        }
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('User Accounts Debug'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total users: ${users.length}'),
                  const SizedBox(height: 8),
                  Text('Students: ${students.length}'),
                  Text('Advisors: ${advisors.length}'),
                  Text('HODs: ${hods.length}'),
                  Text('Admins: ${admins.length}'),
                  const SizedBox(height: 16),
                  if (students.isNotEmpty) ...[
                    const Text('Sample Students:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...students.take(3).map((s) => Text('  • ${s['name']} (${s['email']})')),
                    const SizedBox(height: 8),
                  ],
                  if (advisors.isNotEmpty) ...[
                    const Text('Sample Advisors:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...advisors.take(3).map((a) => Text('  • ${a['name']} (${a['email']})')),
                    const SizedBox(height: 8),
                  ],
                  if (hods.isNotEmpty) ...[
                    const Text('Sample HODs:', style: TextStyle(fontWeight: FontWeight.bold)),
                    ...hods.take(3).map((h) => Text('  • ${h['name']} (${h['email']})')),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error debugging user accounts: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debug error: $e')),
        );
      }
    }
  }

  // Helper function to resend email confirmation
  Future<void> _resendEmailConfirmation(String email) async {
    try {
      await AuthService().resendEmailConfirmation(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email confirmation resent to $email. Please check your inbox.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Error resending email confirmation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error resending email confirmation: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildRoleChip(String role, IconData icon, String displayName) {
    final isSelected = _selectedRole == role;
    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 18,
            color: isSelected ? Colors.white : const Color(AppConstants.primaryColor),
          ),
          const SizedBox(width: 6),
          Text(
            displayName,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: isSelected ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
      onSelected: (selected) {
        setState(() {
          _selectedRole = role;
        });
      },
      selectedColor: const Color(AppConstants.primaryColor),
      checkmarkColor: Colors.white,
      backgroundColor: Colors.grey[100],
      side: BorderSide(
        color: isSelected ? const Color(AppConstants.primaryColor) : Colors.grey[400]!,
        width: isSelected ? 2 : 1,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: isSelected ? 3 : 1,
      pressElevation: 2,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.backgroundColor),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // App Logo/Title
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.school,
                        size: 60,
                        color: const Color(AppConstants.primaryColor),
                      ),
                      const SizedBox(height: 16),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: const Color(AppConstants.primaryColor),
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Smart Complaint Management System',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                
                // Role Selection
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Login Type',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              fontSize: 18,
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildRoleChip(AppConstants.roleStudent, Icons.person, 'Student'),
                          _buildRoleChip(AppConstants.roleBatchAdvisor, Icons.school, 'Advisor'),
                          _buildRoleChip(AppConstants.roleHOD, Icons.admin_panel_settings, 'HOD'),
                          _buildRoleChip(AppConstants.roleAdmin, Icons.admin_panel_settings, 'Admin'),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                
                // Login Form
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                          labelText: 'Email Address',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          hintText: 'Enter your email address',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(AppConstants.primaryColor),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(
                            Icons.email,
                            color: Color(AppConstants.primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                  ),
                  validator: Validators.validateEmail,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: InputDecoration(
                    labelText: 'Password',
                          labelStyle: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          border: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(AppConstants.primaryColor),
                              width: 2,
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                          prefixIcon: const Icon(
                            Icons.lock,
                            color: Color(AppConstants.primaryColor),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                  ),
                  validator: Validators.validatePassword,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: 24),
                if (_errorMessage != null)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.error, color: Colors.red[600], size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                    child: Text(
                      _errorMessage!,
                                  style: TextStyle(color: Colors.red[700]),
                                ),
                              ),
                            ],
                    ),
                  ),
                      if (_errorMessage != null) const SizedBox(height: 16),
                SizedBox(
                        width: double.infinity,
                        height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryColor),
                      foregroundColor: Colors.white,
                            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                    ),
                    child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                )
                        : const Text('Login'),
                  ),
                      ),
                    ],
                  ),
                ),
                
                // Footer
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '© 2024 Smart Complaint Management System',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    TextButton(
                      onPressed: _debugUserAccounts,
                      child: Text(
                        'Debug Users',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
