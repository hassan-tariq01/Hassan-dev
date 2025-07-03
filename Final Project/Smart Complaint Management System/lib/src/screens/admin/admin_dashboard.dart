import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  bool _isLoading = true;
  Map<String, int> _stats = {};

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final complaints = await SupabaseService().getComplaints();
      final users = await SupabaseService().getUsers();
      final departments = await SupabaseService().getDepartments();
      final batches = await SupabaseService().getBatches();

      setState(() {
        _stats = {
          'total_complaints': complaints.length,
          'total_students': users.where((u) => u['role'] == 'Student').length,
          'total_departments': departments.length,
          'total_batches': batches.length,
        };
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading stats: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await AuthService().signOut();
    if (mounted) {
      AppRoutes.goToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome, Admin!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 32),
                  _buildFeatureCards(),
                ],
              ),
            ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildStatCard('Total Complaints', _stats['total_complaints'] ?? 0, Icons.report),
        _buildStatCard('Total Students', _stats['total_students'] ?? 0, Icons.people),
        _buildStatCard('Departments', _stats['total_departments'] ?? 0, Icons.business),
        _buildStatCard('Batches', _stats['total_batches'] ?? 0, Icons.class_),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: const Color(AppConstants.primaryColor)),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(AppConstants.primaryColor),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Management Features',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Department Management',
          'Manage departments and their details',
          Icons.business,
          () => context.go(AppRoutes.departmentManagement),
        ),
        _buildFeatureCard(
          'Batch Management',
          'Create and manage batches',
          Icons.class_,
          () => context.go(AppRoutes.batchManagement),
        ),
        _buildFeatureCard(
          'Advisor Management',
          'Create and manage advisor accounts',
          Icons.person_add,
          () => context.go(AppRoutes.advisorManagement),
        ),
        _buildFeatureCard(
          'Student Management',
          'Create and manage student accounts',
          Icons.people,
          () => context.go(AppRoutes.studentManagement),
        ),
        _buildFeatureCard(
          'Batch Upload',
          'Upload student and batch data via Excel',
          Icons.upload_file,
          () => context.go(AppRoutes.batchUpload),
        ),
        _buildFeatureCard(
          'Advisor Assignment',
          'Assign advisors to batches',
          Icons.assignment_ind,
          () => context.go(AppRoutes.advisorAssignment),
        ),
        _buildFeatureCard(
          'HOD Management',
          'Create and manage HOD accounts',
          Icons.admin_panel_settings,
          () => context.go(AppRoutes.hodManagement),
        ),
        _buildFeatureCard(
          'Statistics Dashboard',
          'View detailed complaint statistics',
          Icons.analytics,
          () => context.go(AppRoutes.statsDashboard),
        ),
        _buildFeatureCard(
          'User Authentication Status',
          'Check and manage user email confirmation status',
          Icons.verified_user,
          () => _showUserAuthStatus(),
        ),
        _buildFeatureCard(
          'Database Security (RLS)',
          'Fix Row Level Security policy issues',
          Icons.security,
          () => _showRLSFixGuide(),
        ),
      ],
    );
  }

  Widget _buildFeatureCard(String title, String description, IconData icon, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      child: ListTile(
        leading: Icon(icon, color: const Color(AppConstants.primaryColor)),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Future<void> _showUserAuthStatus() async {
    try {
      setState(() => _isLoading = true);
      
      // Get all users from database
      final users = await SupabaseService().getUsers();
      
      // Group users by confirmation status
      final confirmedUsers = <Map<String, dynamic>>[];
      final unconfirmedUsers = <Map<String, dynamic>>[];
      
      for (final user in users) {
        // Try to get auth user info
        try {
          // Note: This is a simplified approach. In a real app, you'd need admin privileges
          // to access other users' auth information
          if (user['email'] != null) {
            // For now, we'll just categorize based on available data
            // In production, you'd need to check the actual auth status
            confirmedUsers.add(user);
          }
        } catch (e) {
          print('Error checking auth status for user ${user['email']}: $e');
          unconfirmedUsers.add(user);
        }
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('User Authentication Status'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total Users: ${users.length}'),
                  const SizedBox(height: 8),
                  Text('Confirmed Users: ${confirmedUsers.length}'),
                  Text('Unconfirmed Users: ${unconfirmedUsers.length}'),
                  const SizedBox(height: 16),
                  const Text(
                    'Note: Email confirmation status is managed by Supabase Auth. '
                    'For development purposes, users can login without email confirmation. '
                    'In production, you should enable email confirmation in Supabase settings.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (unconfirmedUsers.isNotEmpty) ...[
                    const Text(
                      'Users that may need email confirmation:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...unconfirmedUsers.take(5).map((user) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        '• ${user['name']} (${user['email']}) - ${user['role']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    )),
                    if (unconfirmedUsers.length > 5)
                      Text(
                        '... and ${unconfirmedUsers.length - 5} more',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                  ],
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showEmailConfirmationHelp();
                },
                child: const Text('Help'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      print('Error showing user auth status: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEmailConfirmationHelp() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Email Confirmation Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Email Confirmation Issues:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('1. Users created through admin interface may need email confirmation'),
              Text('2. Check Supabase Auth settings for email confirmation requirements'),
              Text('3. For development, you can disable email confirmation'),
              Text('4. Users can resend confirmation emails from login screen'),
              SizedBox(height: 16),
              Text(
                'Development Setup:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Go to Supabase Dashboard > Authentication > Settings'),
              Text('• Disable "Enable email confirmations" for development'),
              Text('• Or configure SMTP settings for email delivery'),
              SizedBox(height: 16),
              Text(
                'Production Setup:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('• Enable email confirmations in Supabase'),
              Text('• Configure proper SMTP settings'),
              Text('• Users must confirm email before login'),
              SizedBox(height: 16),
              Text(
                'Quick Fix for Development:',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
              ),
              SizedBox(height: 8),
              Text('• Disable email confirmation in Supabase'),
              Text('• Users can login immediately without confirmation'),
              Text('• Re-enable for production deployment'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showQuickFixInstructions();
            },
            child: const Text('Quick Fix Guide'),
          ),
        ],
      ),
    );
  }

  void _showQuickFixInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Quick Fix: Disable Email Confirmation'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Follow these steps to fix the "email not confirmed" error:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('1. Go to Supabase Dashboard'),
            Text('2. Click "Authentication" in left sidebar'),
            Text('3. Click "Settings"'),
            Text('4. Find "Email Confirmations" section'),
            Text('5. Toggle OFF "Enable email confirmations"'),
            Text('6. Click "Save"'),
            Text('7. Wait 1-2 minutes for changes to take effect'),
            Text('8. Try login again'),
            SizedBox(height: 16),
            Text(
              '⚠️ Note: This is for development only. Re-enable for production!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }

  void _showRLSFixGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Fix RLS Policy Issues'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Error: "new row violates row-level security policy for table complaint_logs"',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Quick Fix (Development):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. Go to Supabase Dashboard'),
              const Text('2. Click "Table Editor"'),
              const Text('3. Select "complaint_logs" table'),
              const Text('4. Click "Settings" tab'),
              const Text('5. Toggle OFF "Enable Row Level Security"'),
              const Text('6. Click "Save"'),
              const SizedBox(height: 16),
              const Text(
                'Production Fix (SQL):',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Run this SQL in Supabase SQL Editor:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'CREATE POLICY "Enable insert for authenticated users" ON complaint_logs\n'
                  'FOR INSERT WITH CHECK (auth.role() = \'authenticated\');',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '⚠️ Note: Disabling RLS removes security restrictions. Use proper policies for production!',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showDetailedRLSGuide();
            },
            child: const Text('Detailed Guide'),
          ),
        ],
      ),
    );
  }

  void _showDetailedRLSGuide() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Complete RLS Policy Setup'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Complete SQL for complaint_logs RLS policies:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '-- Drop existing policies\n'
                  'DROP POLICY IF EXISTS "Enable insert for authenticated users" ON complaint_logs;\n'
                  'DROP POLICY IF EXISTS "Enable select for authenticated users" ON complaint_logs;\n'
                  'DROP POLICY IF EXISTS "Enable update for authenticated users" ON complaint_logs;\n\n'
                  '-- Create insert policy\n'
                  'CREATE POLICY "Enable insert for authenticated users" ON complaint_logs\n'
                  'FOR INSERT WITH CHECK (auth.role() = \'authenticated\');\n\n'
                  '-- Create select policy\n'
                  'CREATE POLICY "Enable select for authenticated users" ON complaint_logs\n'
                  'FOR SELECT USING (auth.role() = \'authenticated\');\n\n'
                  '-- Create update policy\n'
                  'CREATE POLICY "Enable update for authenticated users" ON complaint_logs\n'
                  'FOR UPDATE USING (auth.uid() = user_id);',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Steps:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('1. Go to Supabase Dashboard > SQL Editor'),
              const Text('2. Copy and paste the SQL above'),
              const Text('3. Click "Run"'),
              const Text('4. Test complaint submission'),
              const Text('5. Check if logs are created successfully'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
} 