import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../models/batch.dart';
import '../../models/complaint.dart';
import '../../models/user.dart' as app_user;
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import 'complaint_status.dart';
import 'package:go_router/go_router.dart';

class ComplaintHistory extends StatefulWidget {
  const ComplaintHistory({Key? key}) : super(key: key);

  @override
  State<ComplaintHistory> createState() => _ComplaintHistoryState();
}

class _ComplaintHistoryState extends State<ComplaintHistory> {
  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  List<app_user.User> _advisors = [];
  List<Batch> _batches = [];
  bool _isLoading = true;
  String? _selectedStatus;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadComplaintHistory();
  }

  Future<void> _loadComplaintHistory() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return;

      // Get student's complaints
      final complaintsData = await SupabaseService().getComplaints(
        filters: {'student_id': currentUser.id},
      );

      // Get advisors and batches for reference
      final usersData = await SupabaseService().getUsers();
      final batchesData = await SupabaseService().getBatches();

      setState(() {
        _complaints = complaintsData.map((json) => Complaint.fromJson(json)).toList();
        _filteredComplaints = List.from(_complaints);
        _advisors = usersData.where((u) => u['role'] == 'Batch Advisor').map((json) => app_user.User.fromJson(json)).toList();
        _batches = batchesData.map((json) => Batch.fromJson(json)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading complaint history: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredComplaints = _complaints.where((complaint) {
        // Status filter
        if (_selectedStatus != null && complaint.status != _selectedStatus) {
          return false;
        }

        // Search query
        if (_searchQuery.isNotEmpty) {
          if (!complaint.title.toLowerCase().contains(_searchQuery.toLowerCase()) &&
              !complaint.description.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }

        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _searchQuery = '';
      _filteredComplaints = List.from(_complaints);
    });
  }

  String _getAdvisorName(String advisorId) {
    final advisor = _advisors.where((a) => a.id == advisorId).firstOrNull;
    return advisor?.name ?? 'Unknown';
  }

  String _getBatchName(String batchId) {
    final batch = _batches.where((b) => b.id == batchId).firstOrNull;
    return batch?.name ?? 'Unknown';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint History'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.studentDashboard),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComplaints.isEmpty
                ? const Center(child: Text('No complaints found.'))
                : ListView.builder(
              itemCount: _filteredComplaints.length,
              itemBuilder: (context, index) {
                final complaint = _filteredComplaints[index];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(complaint.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Status: ${complaint.status}'),
                        Text('Advisor: ${_getAdvisorName(complaint.advisorId)}'),
                        Text('Batch: ${_getBatchName(complaint.batchId)}'),
                        Text('Submitted: ${complaint.createdAt.toString().split(' ')[0]}'),
                        if (complaint.hasMedia) ...[
                          const SizedBox(height: 4),
                          const Text('📎 Has Media', style: TextStyle(fontSize: 12)),
                        ],
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: _getStatusColor(complaint.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        complaint.status,
                        style: const TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ComplaintStatus(complaintId: complaint.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Search by title or description',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (value) {
              _searchQuery = value;
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Statuses')),
                    DropdownMenuItem(value: AppConstants.statusSubmitted, child: Text(AppConstants.statusSubmitted)),
                    DropdownMenuItem(value: AppConstants.statusInProgress, child: Text(AppConstants.statusInProgress)),
                    DropdownMenuItem(value: AppConstants.statusEscalatedToHOD, child: Text(AppConstants.statusEscalatedToHOD)),
                    DropdownMenuItem(value: AppConstants.statusResolved, child: Text(AppConstants.statusResolved)),
                    DropdownMenuItem(value: AppConstants.statusRejected, child: Text(AppConstants.statusRejected)),
                  ],
                  onChanged: (value) {
                    _selectedStatus = value;
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}