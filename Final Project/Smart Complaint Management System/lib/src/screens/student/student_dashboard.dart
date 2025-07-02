import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({Key? key}) : super(key: key);

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  bool _isLoading = true;
  Map<String, int> _stats = {};
  List<Map<String, dynamic>> _recentComplaints = [];
  String? _studentName;
  String? _batchName;
  String? _advisorName;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) {
        AppRoutes.goToLogin(context);
        return;
      }

      // Get student details
      final users = await SupabaseService().getUsers();
      final student = users.where((u) => u['id'] == currentUser.id).firstOrNull;

      if (student != null) {
        setState(() {
          _studentName = student['name'];
        });

        // Get student's complaints
        final complaints = await SupabaseService().getComplaints(
          filters: {'student_id': currentUser.id},
        );

        // Get batch and advisor details
        final batches = await SupabaseService().getBatches();
        final advisors = await SupabaseService().getUsers(role: AppConstants.roleBatchAdvisor);

        if (student['batch_id'] != null) {
          final batch = batches.where((b) => b['id'] == student['batch_id']).firstOrNull;
          if (batch != null) {
            setState(() {
              _batchName = batch['name'];
            });

            if (batch['advisor_id'] != null) {
              final advisor = advisors.where((a) => a['id'] == batch['advisor_id']).firstOrNull;
              if (advisor != null) {
                setState(() {
                  _advisorName = advisor['name'];
                });
              }
            }
          }
        }

        setState(() {
          _stats = {
            'total_complaints': complaints.length,
            'submitted': complaints.where((c) => c['status'] == AppConstants.statusSubmitted).length,
            'in_progress': complaints.where((c) => c['status'] == AppConstants.statusInProgress).length,
            'escalated': complaints.where((c) => c['status'] == AppConstants.statusEscalatedToHOD).length,
            'resolved': complaints.where((c) => c['status'] == AppConstants.statusResolved).length,
            'rejected': complaints.where((c) => c['status'] == AppConstants.statusRejected).length,
          };
          _recentComplaints = complaints.take(5).toList(); // Show last 5 complaints
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading dashboard: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
        title: const Text('Student Dashboard'),
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
                    'Welcome, ${_studentName ?? 'Student'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (_batchName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Batch: $_batchName',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(AppConstants.primaryColor),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                  if (_advisorName != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Advisor: $_advisorName',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                  const SizedBox(height: 24),
                  _buildStatsGrid(),
                  const SizedBox(height: 32),
                  _buildRecentComplaints(),
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
        _buildStatCard('Submitted', _stats['submitted'] ?? 0, Icons.schedule),
        _buildStatCard('In Progress', _stats['in_progress'] ?? 0, Icons.pending),
        _buildStatCard('Resolved', _stats['resolved'] ?? 0, Icons.check_circle),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    Color cardColor = const Color(AppConstants.primaryColor);
    if (title == 'Submitted') cardColor = const Color(AppConstants.submittedColor);
    if (title == 'In Progress') cardColor = const Color(AppConstants.inProgressColor);
    if (title == 'Resolved') cardColor = const Color(AppConstants.resolvedColor);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: cardColor),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: cardColor,
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

  Widget _buildRecentComplaints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Complaints',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        if (_recentComplaints.isEmpty)
          const Card(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('No complaints submitted yet.'),
            ),
          )
        else
          ..._recentComplaints.map((complaint) => Card(
            margin: const EdgeInsets.only(bottom: 8.0),
            child: ListTile(
              title: Text(complaint['title']),
              subtitle: Text('Status: ${complaint['status']}'),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  color: _getStatusColor(complaint['status']),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  complaint['status'],
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              onTap: () {
                AppRoutes.goToComplaintStatus(context, complaint['id']);
              },
            ),
          )).toList(),
      ],
    );
  }

  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'Submit New Complaint',
          'Create a new complaint with title, description, and optional media',
          Icons.add_circle,
          () => context.go(AppRoutes.complaintSubmission),
        ),
        _buildFeatureCard(
          'View Complaint History',
          'See all your submitted complaints and their current status',
          Icons.history,
          () => context.go(AppRoutes.complaintHistory),
        ),
        _buildFeatureCard(
          'Check Status',
          'Track the progress of your complaints in real-time',
          Icons.track_changes,
          () => context.go(AppRoutes.complaintHistory),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return const Color(AppConstants.submittedColor);
      case AppConstants.statusInProgress:
        return const Color(AppConstants.inProgressColor);
      case AppConstants.statusEscalatedToHOD:
        return const Color(AppConstants.escalatedColor);
      case AppConstants.statusResolved:
        return const Color(AppConstants.resolvedColor);
      case AppConstants.statusRejected:
        return const Color(AppConstants.rejectedColor);
      default:
        return Colors.grey;
    }
  }
} 