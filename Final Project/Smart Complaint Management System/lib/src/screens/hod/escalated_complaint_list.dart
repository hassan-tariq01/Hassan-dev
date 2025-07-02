import 'package:flutter/material.dart';
import '../../models/batch.dart';
import '../../models/complaint.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import 'complaint_detail.dart';
import 'package:go_router/go_router.dart';

class EscalatedComplaintList extends StatefulWidget {
  const EscalatedComplaintList({Key? key}) : super(key: key);

  @override
  State<EscalatedComplaintList> createState() => _EscalatedComplaintListState();
}

class _EscalatedComplaintListState extends State<EscalatedComplaintList> {
  List<Complaint> _complaints = [];
  List<Complaint> _filteredComplaints = [];
  List<User> _students = [];
  List<User> _advisors = [];
  List<Batch> _batches = [];
  bool _isLoading = true;
  String? _selectedBatch;
  String? _selectedAdvisor;
  String? _selectedStudent;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Get escalated complaints
      final complaintsData = await SupabaseService().getComplaints(
        filters: {'status': AppConstants.statusEscalatedToHOD},
      );
      
      // Get users and batches for reference
      final usersData = await SupabaseService().getUsers();
      final batchesData = await SupabaseService().getBatches();

      setState(() {
        _complaints = complaintsData.map((json) => Complaint.fromJson(json)).toList();
        _filteredComplaints = List.from(_complaints);
        _students = usersData.where((u) => u['role'] == 'Student').map((json) => User.fromJson(json)).toList();
        _advisors = usersData.where((u) => u['role'] == 'Batch Advisor').map((json) => User.fromJson(json)).toList();
        _batches = batchesData.map((json) => Batch.fromJson(json)).toList();
      });
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
        // Batch filter
        if (_selectedBatch != null && complaint.batchId != _selectedBatch) {
          return false;
        }
        
        // Advisor filter
        if (_selectedAdvisor != null && complaint.advisorId != _selectedAdvisor) {
          return false;
        }
        
        // Student filter
        if (_selectedStudent != null && complaint.studentId != _selectedStudent) {
          return false;
        }
        
        // Search query
        if (_searchQuery.isNotEmpty) {
          final student = _students.firstWhere(
            (s) => s.id == complaint.studentId,
            orElse: () => User(id: '', name: 'Unknown', email: '', role: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
          );
          if (!student.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
              !complaint.title.toLowerCase().contains(_searchQuery.toLowerCase())) {
            return false;
          }
        }
        
        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedBatch = null;
      _selectedAdvisor = null;
      _selectedStudent = null;
      _searchQuery = '';
      _filteredComplaints = List.from(_complaints);
    });
  }

  String _getUserName(String userId) {
    final user = _students.firstWhere(
      (s) => s.id == userId,
      orElse: () => _advisors.firstWhere(
        (a) => a.id == userId,
        orElse: () => User(id: '', name: 'Unknown', email: '', role: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
      ),
    );
    return user.name;
  }

  String _getBatchName(String batchId) {
    final batch = _batches.firstWhere(
      (b) => b.id == batchId,
      orElse: () => Batch(id: '', name: 'Unknown', departmentId: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    return batch.name;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escalated Complaints'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.hodDashboard),
        ),
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComplaints.isEmpty
                    ? const Center(child: Text('No escalated complaints found.'))
                    : ListView.builder(
                        itemCount: _filteredComplaints.length,
                        itemBuilder: (context, index) {
                          final complaint = _filteredComplaints[index];
                          final student = _students.firstWhere(
                            (s) => s.id == complaint.studentId,
                            orElse: () => User(id: '', name: 'Unknown', email: '', role: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
                          );
                          final advisor = _advisors.firstWhere(
                            (a) => a.id == complaint.advisorId,
                            orElse: () => User(id: '', name: 'Unknown', email: '', role: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
                          );
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                            child: ListTile(
                              title: Text(complaint.title),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Student: ${student.name}'),
                                  Text('Batch: ${_getBatchName(complaint.batchId)}'),
                                  Text('Advisor: ${advisor.name}'),
                                  Text('Escalated: ${complaint.updatedAt.toString().split(' ')[0]}'),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                decoration: BoxDecoration(
                                  color: const Color(AppConstants.escalatedColor),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Text(
                                  'Escalated',
                                  style: TextStyle(color: Colors.white, fontSize: 12),
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
                  value: _selectedBatch,
                  decoration: const InputDecoration(
                    labelText: 'Batch',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Batches')),
                    ..._batches.map((batch) => DropdownMenuItem(
                      value: batch.id,
                      child: Text(batch.name),
                    )).toList(),
                  ],
                  onChanged: (value) {
                    _selectedBatch = value;
                    _applyFilters();
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedAdvisor,
                  decoration: const InputDecoration(
                    labelText: 'Advisor',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Advisors')),
                    ..._advisors.map((advisor) => DropdownMenuItem(
                      value: advisor.id,
                      child: Text(advisor.name),
                    )).toList(),
                  ],
                  onChanged: (value) {
                    _selectedAdvisor = value;
                    _applyFilters();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
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