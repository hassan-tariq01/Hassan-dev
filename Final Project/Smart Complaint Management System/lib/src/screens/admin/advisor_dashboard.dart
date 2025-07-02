import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class AdvisorDashboard extends StatefulWidget {
  const AdvisorDashboard({Key? key}) : super(key: key);

  @override
  State<AdvisorDashboard> createState() => _AdvisorDashboardState();
}

class _AdvisorDashboardState extends State<AdvisorDashboard> {
  bool _isLoading = true;
  Map<String, int> _stats = {};
  String? _advisorName;
  String? _batchName;

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

      // Get advisor details
      final users = await SupabaseService().getUsers();
      final advisor = users.where((u) => u['id'] == currentUser.id).firstOrNull;

      if (advisor != null) {
        setState(() {
          _advisorName = advisor['name'];
        });

        // Get advisor's batch
        final batches = await SupabaseService().getBatches();
        final advisorBatch = batches.where((b) => b['advisor_id'] == currentUser.id).firstOrNull;

        if (advisorBatch != null) {
          setState(() {
            _batchName = advisorBatch['name'];
          });

          // Get complaints for this batch
          final complaints = await SupabaseService().getComplaints(
            filters: {'batch_id': advisorBatch['id']},
          );

          setState(() {
            _stats = {
              'total_complaints': complaints.length,
              'submitted': complaints.where((c) => c['status'] == AppConstants.statusSubmitted).length,
              'in_progress': complaints.where((c) => c['status'] == AppConstants.statusInProgress).length,
              'escalated': complaints.where((c) => c['status'] == AppConstants.statusEscalatedToHOD).length,
              'resolved': complaints.where((c) => c['status'] == AppConstants.statusResolved).length,
              'rejected': complaints.where((c) => c['status'] == AppConstants.statusRejected).length,
            };
          });
        }
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
        title: const Text('Advisor Dashboard'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
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
                    'Welcome, ${_advisorName ?? 'Advisor'}!',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (_batchName != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Assigned Batch: $_batchName',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: const Color(AppConstants.primaryColor),
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
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
        _buildStatCard('Submitted', _stats['submitted'] ?? 0, Icons.schedule),
        _buildStatCard('In Progress', _stats['in_progress'] ?? 0, Icons.pending),
        _buildStatCard('Escalated', _stats['escalated'] ?? 0, Icons.escalator_warning),
        _buildStatCard('Resolved', _stats['resolved'] ?? 0, Icons.check_circle),
        _buildStatCard('Rejected', _stats['rejected'] ?? 0, Icons.cancel),
      ],
    );
  }

  Widget _buildStatCard(String title, int count, IconData icon) {
    Color cardColor = const Color(AppConstants.primaryColor);
    if (title == 'Submitted') cardColor = const Color(AppConstants.submittedColor);
    if (title == 'In Progress') cardColor = const Color(AppConstants.inProgressColor);
    if (title == 'Escalated') cardColor = const Color(AppConstants.escalatedColor);
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
          'View All Complaints',
          'View and manage complaints from your assigned batch',
          Icons.list_alt,
          () => context.go(AppRoutes.advisorComplaintList),
        ),
        _buildFeatureCard(
          'Filter Complaints',
          'Filter complaints by status, date, or student',
          Icons.filter_list,
          () => context.go(AppRoutes.advisorComplaintList),
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