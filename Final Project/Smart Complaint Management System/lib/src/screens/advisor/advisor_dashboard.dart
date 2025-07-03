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
  String? _debugInfo;
  int _totalComplaintsInBatch = 0;
  int _complaintsWithCorrectAdvisor = 0;
  List<Map<String, dynamic>> _batchStudents = [];
  int _totalStudentsInBatch = 0;

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

          // Get ALL complaints in this batch (show everything to advisor)
          final allComplaintsInBatch = await SupabaseService().getComplaints(
            filters: {'batch_id': advisorBatch['id']},
          );

          // Also get complaints where advisor_id matches current advisor (for comparison)
          final complaintsWithCorrectAdvisor = await SupabaseService().getComplaints(
            filters: {'batch_id': advisorBatch['id'], 'advisor_id': currentUser.id},
          );

          // Get students in this batch
          final allUsers = await SupabaseService().getUsers();
          final studentsInBatch = allUsers.where((u) => 
            u['role'] == 'Student' && u['batch_id'] == advisorBatch['id']
          ).toList();

          setState(() {
            _stats = {
              'total_complaints': allComplaintsInBatch.length,
              'submitted': allComplaintsInBatch.where((c) => c['status'] == AppConstants.statusSubmitted).length,
              'in_progress': allComplaintsInBatch.where((c) => c['status'] == AppConstants.statusInProgress).length,
              'escalated': allComplaintsInBatch.where((c) => c['status'] == AppConstants.statusEscalatedToHOD).length,
              'resolved': allComplaintsInBatch.where((c) => c['status'] == AppConstants.statusResolved).length,
              'rejected': allComplaintsInBatch.where((c) => c['status'] == AppConstants.statusRejected).length,
            };
            _totalComplaintsInBatch = allComplaintsInBatch.length;
            _complaintsWithCorrectAdvisor = complaintsWithCorrectAdvisor.length;
            _batchStudents = studentsInBatch;
            _totalStudentsInBatch = studentsInBatch.length;
            _debugInfo = 'Showing ${allComplaintsInBatch.length} total complaints in batch (${complaintsWithCorrectAdvisor.length} with correct advisor_id)';
          });
        } else {
          // No batch assigned - clear all data
          setState(() {
            _batchName = null;
            _stats = {
              'total_complaints': 0,
              'submitted': 0,
              'in_progress': 0,
              'escalated': 0,
              'resolved': 0,
              'rejected': 0,
            };
            _totalComplaintsInBatch = 0;
            _complaintsWithCorrectAdvisor = 0;
            _batchStudents = [];
            _totalStudentsInBatch = 0;
            _debugInfo = 'No batch assigned to this advisor';
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
        actions: [
          if (_debugInfo != null)
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showDebugInfo(),
              tooltip: 'Debug Info',
            ),
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
            ] else ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No batch assigned to this advisor. Please contact the administrator.',
                        style: TextStyle(
                          color: Colors.orange[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (_batchName != null) ...[
            _buildStatsGrid(),
              const SizedBox(height: 16),
              _buildStudentStatsCard(),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(Icons.assignment_ind, size: 48, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text(
                        'No Batch Assigned',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Statistics and student data will appear here once a batch is assigned to you.',
                        style: TextStyle(color: Colors.grey[600]),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (_debugInfo != null && _totalComplaintsInBatch > _complaintsWithCorrectAdvisor) ...[
              const SizedBox(height: 16),
              _buildDebugSection(),
            ],
            const SizedBox(height: 32),
            _buildStudentsSection(),
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

  Widget _buildStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Batch Students',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(AppConstants.primaryColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$_totalStudentsInBatch',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_batchName == null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'No batch assigned. Students will appear here once a batch is assigned to you.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
        if (_batchStudents.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Text(
                    'No students found in your batch',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _batchStudents.length,
            itemBuilder: (context, index) {
              final student = _batchStudents[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(AppConstants.primaryColor),
                    child: Text(
                      (student['name'] ?? 'S')[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(student['name'] ?? 'Unknown Student'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Email: ${student['email'] ?? 'N/A'}'),
                      Text('Student ID: ${student['id'] ?? 'N/A'}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.visibility),
                    onPressed: () => _viewStudentComplaints(student),
                    tooltip: 'View Student Complaints',
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildStudentStatsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.people, color: Color(AppConstants.primaryColor)),
                const SizedBox(width: 8),
                Text(
                  'Student Overview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Students',
                    '$_totalStudentsInBatch',
                    Icons.person,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Active Students',
                    '${_batchStudents.where((s) => s['is_active'] != false).length}',
                    Icons.person_add,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Students with Complaints',
                    '${_batchStudents.where((s) => _complaintsWithCorrectAdvisor > 0).length}',
                    Icons.report,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(AppConstants.primaryColor)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(AppConstants.primaryColor),
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  void _viewStudentComplaints(Map<String, dynamic> student) {
    // Navigate to complaint list filtered by this student
    context.go(AppRoutes.advisorComplaintList, extra: {'student_id': student['id']});
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
        if (_batchName != null) ...[
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
        ] else ...[
          _buildFeatureCard(
            'View All Complaints',
            'No batch assigned - will show all complaints for debugging',
            Icons.list_alt,
                () => context.go(AppRoutes.advisorComplaintList),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Complaint management features will be available once a batch is assigned to you.',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
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

  void _showDebugInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Debug Information'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Advisor Name: ${_advisorName ?? 'Not loaded'}'),
              Text('Batch Name: ${_batchName ?? 'No batch assigned'}'),
              const SizedBox(height: 8),
              Text('Total Students in Batch: $_totalStudentsInBatch'),
              Text('Total Complaints in Batch: $_totalComplaintsInBatch'),
              Text('Complaints with Correct Advisor: $_complaintsWithCorrectAdvisor'),
              const SizedBox(height: 8),
              if (_debugInfo != null) ...[
                const Text('Debug Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(_debugInfo!),
              ],
              const SizedBox(height: 8),
              const Text('Troubleshooting Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
              const Text('1. Check if advisor is assigned to a batch'),
              const Text('2. Check if students are in the batch'),
              const Text('3. Check if complaints exist in the batch'),
              const Text('4. Check if complaints have correct advisor_id'),
              const SizedBox(height: 8),
              const Text('For detailed SQL queries and fixes, see:'),
              const Text('ABDULLAH_ADVISOR_FIX.md', style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDebugSection() {
    return Card(
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Data Integrity Issue Detected',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(_debugInfo ?? ''),
            const SizedBox(height: 8),
            Text('Total complaints in batch: $_totalComplaintsInBatch'),
            Text('Complaints with correct advisor: $_complaintsWithCorrectAdvisor'),
            Text('Complaints needing fix: ${_totalComplaintsInBatch - _complaintsWithCorrectAdvisor}'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.advisorComplaintList),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Go to Complaints to Fix'),
            ),
          ],
        ),
      ),
    );
  }
}