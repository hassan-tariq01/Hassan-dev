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
  String? _selectedStatus;
  String _searchQuery = '';
  String? _debugInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Get ALL complaints (not just escalated)
      final complaintsData = await SupabaseService().getComplaints();
      
      // Get users and batches for reference
      final usersData = await SupabaseService().getUsers();
      final batchesData = await SupabaseService().getBatches();

      setState(() {
        _complaints = complaintsData.map((json) => Complaint.fromJson(json)).toList();
        _filteredComplaints = List.from(_complaints);
        _students = usersData.where((u) => u['role'] == 'Student').map((json) => User.fromJson(json)).toList();
        _advisors = usersData.where((u) => u['role'] == 'Batch Advisor').map((json) => User.fromJson(json)).toList();
        _batches = batchesData.map((json) => Batch.fromJson(json)).toList();
        _debugInfo = 'Loaded ${_complaints.length} total complaints';
      });

      // Debug: Print complaint details
      print('Debug: Found ${_complaints.length} complaints');
      for (var complaint in _complaints.take(3)) {
        print('Debug: Complaint ${complaint.id} - Status: ${complaint.status}, Batch: ${complaint.batchId}');
      }

    } catch (e) {
      setState(() {
        _debugInfo = 'Error loading complaints: $e';
      });
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
      _selectedStatus = null;
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
      orElse: () => Batch(id: '', name: 'Unknown', departmentId: '', advisorId: null, createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    return batch.name;
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
        title: const Text('All Complaints'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.hodDashboard),
        ),
        actions: [
          if (_debugInfo != null)
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showDebugInfo(),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComplaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            const Text(
                              'No complaints found',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No complaints match your current filters.',
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => _clearFilters(),
                              child: const Text('Clear Filters'),
                            ),
                          ],
                        ),
                      )
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
                              title: Text(
                                complaint.title,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('Student: ${student.name}', overflow: TextOverflow.ellipsis, maxLines: 1),
                                  Text('Batch: ${_getBatchName(complaint.batchId)}', overflow: TextOverflow.ellipsis, maxLines: 1),
                                  Text('Advisor: ${advisor.name}', overflow: TextOverflow.ellipsis, maxLines: 1),
                                  Text('Status: ${complaint.status}', overflow: TextOverflow.ellipsis, maxLines: 1),
                                  Text('Created: ${complaint.createdAt.toString().split(' ')[0]}', overflow: TextOverflow.ellipsis, maxLines: 1),
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
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
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
              Text(_debugInfo ?? 'No debug info available'),
              const SizedBox(height: 16),
              Text('Total complaints loaded: ${_complaints.length}'),
              Text('Filtered complaints: ${_filteredComplaints.length}'),
              const SizedBox(height: 16),
              const Text('Complaint breakdown:'),
              ..._complaints.fold<Map<String, int>>({}, (map, complaint) {
                map[complaint.status] = (map[complaint.status] ?? 0) + 1;
                return map;
              }).entries.map((entry) => Text('${entry.key}: ${entry.value}')),
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

  Widget _buildFilters() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Filters', style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
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
                        setState(() {
                          _selectedStatus = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedBatch,
                      decoration: const InputDecoration(
                        labelText: 'Batch',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Batches')),
                        ..._batches.map((batch) => 
                          DropdownMenuItem(value: batch.id, child: Text(batch.name))
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedBatch = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedAdvisor,
                      decoration: const InputDecoration(
                        labelText: 'Advisor',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Advisors')),
                        ..._advisors.map((advisor) => 
                          DropdownMenuItem(value: advisor.id, child: Text(advisor.name))
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedAdvisor = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedStudent,
                      decoration: const InputDecoration(
                        labelText: 'Student',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem(value: null, child: Text('All Students')),
                        ..._students.map((student) => 
                          DropdownMenuItem(value: student.id, child: Text(student.name))
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedStudent = value;
                        });
                        _applyFilters();
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
                _applyFilters();
              },
            ),
          ],
        ),
      ),
    );
  }
} 