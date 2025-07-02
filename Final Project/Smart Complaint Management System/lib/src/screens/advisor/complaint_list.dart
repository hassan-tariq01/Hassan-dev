import 'package:flutter/material.dart';
import '../../auth/auth_service.dart';
import '../../models/batch.dart';
import '../../models/complaint.dart';
import '../../models/user.dart' as app_user;
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import 'complaint_detail.dart';
import 'package:go_router/go_router.dart';

class ComplaintList extends StatefulWidget {
  const ComplaintList({Key? key}) : super(key: key);

  @override
  State<ComplaintList> createState() => _ComplaintListState();
}

class _ComplaintListState extends State<ComplaintList> {
  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  List<app_user.User> _students = [];
  List<Batch> _batches = [];
  bool _isLoading = true;
  String? _selectedStatus;
  String? _selectedBatch;
  String? _selectedStudent;
  String _searchQuery = '';
  String? _advisorBatchId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return;

      // Get advisor's batch
      final batches = await SupabaseService().getBatches();
      final advisorBatch = batches.where((b) => b['advisor_id'] == currentUser.id).firstOrNull;

      if (advisorBatch != null) {
        _advisorBatchId = advisorBatch['id'];

        // Get complaints for this batch
        final complaintsData = await SupabaseService().getComplaints(
          filters: {'batch_id': _advisorBatchId},
        );

        // Get students and batches for reference
        final usersData = await SupabaseService().getUsers();
        final batchesData = await SupabaseService().getBatches();

        setState(() {
          _complaints = complaintsData.map((json) => Complaint.fromJson(json)).toList();
          _filteredComplaints = List.from(_complaints);
          _students = usersData.where((u) => u['role'] == 'Student').map((json) => app_user.User.fromJson(json)).toList();
          _batches = batchesData.map((json) => Batch.fromJson(json)).toList();
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading complaints: $e')),
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

        // Batch filter
        if (_selectedBatch != null && complaint.batchId != _selectedBatch) {
          return false;
        }

        // Student filter
        if (_selectedStudent != null && complaint.studentId != _selectedStudent) {
          return false;
        }

        // Search query
        if (_searchQuery.isNotEmpty) {
          final student = _students.where((s) => s.id == complaint.studentId).firstOrNull;
          if (student == null ||
              (!student.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                  !complaint.title.toLowerCase().contains(_searchQuery.toLowerCase()))) {
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
      _selectedBatch = null;
      _selectedStudent = null;
      _searchQuery = '';
      _filteredComplaints = List.from(_complaints);
    });
  }

  String _getStatusColor(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return '#${AppConstants.submittedColor.toRadixString(16).substring(2)}';
      case AppConstants.statusInProgress:
        return '#${AppConstants.inProgressColor.toRadixString(16).substring(2)}';
      case AppConstants.statusEscalatedToHOD:
        return '#${AppConstants.escalatedColor.toRadixString(16).substring(2)}';
      case AppConstants.statusResolved:
        return '#${AppConstants.resolvedColor.toRadixString(16).substring(2)}';
      case AppConstants.statusRejected:
        return '#${AppConstants.rejectedColor.toRadixString(16).substring(2)}';
      default:
        return '#000000';
    }
  }

  @override
  Widget build(BuildContext context) {
    final noBatchAssigned = _advisorBatchId == null;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Complaints'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.advisorDashboard),
        ),
      ),
      body: noBatchAssigned
          ? const Center(child: Text('You are not assigned to any batch. Please contact the admin.'))
          : Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComplaints.isEmpty
                ? const Center(child: Text('No complaints found for your batch.'))
                : ListView.builder(
              itemCount: _filteredComplaints.length,
              itemBuilder: (context, index) {
                final complaint = _filteredComplaints[index];
                final student = _students.where((s) => s.id == complaint.studentId).firstOrNull;
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                  child: ListTile(
                    title: Text(complaint.title),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Student: ${student?.name ?? 'Unknown'}'),
                        Text('Status: ${complaint.status}'),
                        Text('Created: ${complaint.createdAt.toString().split(' ')[0]}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                      decoration: BoxDecoration(
                        color: Color(int.parse(_getStatusColor(complaint.status).substring(1), radix: 16) + 0xFF000000),
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
                          builder: (context) => ComplaintDetail(complaintId: complaint.id),
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
              labelText: 'Search by student name or complaint title',
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
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedStudent,
                  decoration: const InputDecoration(
                    labelText: 'Student',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Students')),
                    ..._students.map((student) => DropdownMenuItem(
                      value: student.id,
                      child: Text(student.name),
                    )).toList(),
                  ],
                  onChanged: (value) {
                    _selectedStudent = value;
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}