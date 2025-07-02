import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class HODDashboard extends StatefulWidget {
  const HODDashboard({Key? key}) : super(key: key);

  @override
  State<HODDashboard> createState() => _HODDashboardState();
}

class _HODDashboardState extends State<HODDashboard> {
  bool _isLoading = true;
  Map<String, int> _stats = {};
  String? _hodName;

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

      // Get HOD details
      final users = await SupabaseService().getUsers();
      final hod = users.where((u) => u['id'] == currentUser.id).firstOrNull;

      if (hod != null) {
        setState(() {
          _hodName = hod['name'];
        });

        // Get escalated complaints
        final complaints = await SupabaseService().getComplaints(
          filters: {'status': AppConstants.statusEscalatedToHOD},
        );

        setState(() {
          _stats = {
            'escalated_complaints': complaints.length,
            'resolved': complaints.where((c) => c['status'] == AppConstants.statusResolved).length,
            'rejected': complaints.where((c) => c['status'] == AppConstants.statusRejected).length,
            'pending_review': complaints.where((c) => c['status'] == AppConstants.statusEscalatedToHOD).length,
          };
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
        title: const Text('HOD Dashboard'),
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
              'Welcome, ${_hodName ?? 'HOD'}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Head of Department - Computer Science',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: const Color(AppConstants.primaryColor),
                fontWeight: FontWeight.bold,
              ),
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
        _buildStatCard('Escalated Complaints', _stats['escalated_complaints'] ?? 0, Icons.escalator_warning),
        _buildStatCard('Pending Review', _stats['pending_review'] ?? 0, Icons.pending),
        _buildStatCard('Resolved', _stats['resolved'] ?? 0, Icons.check_circle),
        _buildStatCard('Rejected', _stats['rejected'] ?? 0, Icons.cancel),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    Color cardColor = const Color(AppConstants.primaryColor);
    if (title == 'Escalated Complaints') cardColor = const Color(AppConstants.escalatedColor);
    if (title == 'Pending Review') cardColor = const Color(AppConstants.inProgressColor);
    if (title == 'Resolved') cardColor = const Color(AppConstants.resolvedColor);
    if (title == 'Rejected') cardColor = const Color(AppConstants.rejectedColor);

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

  Widget _buildFeatureCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Complaint Management',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          'View Escalated Complaints',
          'Review and manage complaints escalated by advisors',
          Icons.escalator_warning,
              () => context.go(AppRoutes.hodComplaintList),
        ),
        _buildFeatureCard(
          'Filter by Batch/Advisor',
          'Filter complaints by specific batches or advisors',
          Icons.filter_list,
              () => context.go(AppRoutes.hodComplaintList),
        ),
        _buildFeatureCard(
          'Resolution Actions',
          'Resolve or reject escalated complaints',
          Icons.gavel,
              () => context.go(AppRoutes.hodComplaintList),
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
}