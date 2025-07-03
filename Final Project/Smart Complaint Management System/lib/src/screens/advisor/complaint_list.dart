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
  final Map<String, dynamic>? extra;
  
  const ComplaintList({Key? key, this.extra}) : super(key: key);

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
  String? _debugInfo;
  Map<String, dynamic>? _dataIntegrityInfo;

  @override
  void initState() {
    super.initState();
    _loadData();
    
    // Set student filter if provided
    if (widget.extra != null && widget.extra!['student_id'] != null) {
      _selectedStudent = widget.extra!['student_id'];
      // Apply filter after data is loaded
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _applyFilters();
      });
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return;

      // Get advisor's batch
      final batches = await SupabaseService().getBatches();
      final advisorBatch = batches.where((b) => b['advisor_id'] == currentUser.id).firstOrNull;

      List<Map<String, dynamic>> complaintsData;

      if (advisorBatch != null) {
        _advisorBatchId = advisorBatch['id'];

        // Get ALL complaints for this batch (show everything to debug)
        complaintsData = await SupabaseService().getComplaints(
          filters: {'batch_id': _advisorBatchId},
        );
        
        // Also get complaints where advisor_id matches current advisor
        final advisorComplaints = await SupabaseService().getComplaints(
          filters: {'batch_id': _advisorBatchId, 'advisor_id': currentUser.id},
        );
        
        _debugInfo = 'Advisor assigned to batch: ${advisorBatch['name']} (${complaintsData.length} total complaints in batch, ${advisorComplaints.length} with correct advisor_id) - Check console for detailed debug info';
        
        // Check data integrity
        await _checkDataIntegrity(currentUser.id, advisorBatch['id']);
        
        // Debug: Print all complaints in batch
        print('=== DEBUG: All complaints in batch ${advisorBatch['name']} ===');
        print('Batch ID: ${advisorBatch['id']}');
        print('Advisor ID: ${currentUser.id}');
        print('Total complaints found: ${complaintsData.length}');
        
        if (complaintsData.isEmpty) {
          print('❌ NO COMPLAINTS FOUND IN BATCH!');
          print('Possible issues:');
          print('1. No students have submitted complaints');
          print('2. Complaints have wrong batch_id');
          print('3. Students not assigned to this batch');
        } else {
          for (var complaint in complaintsData) {
            print('✅ Complaint: ${complaint['title']}');
            print('   - Batch: ${complaint['batch_id']}');
            print('   - Advisor: ${complaint['advisor_id']}');
            print('   - Student: ${complaint['student_id']}');
            print('   - Status: ${complaint['status']}');
          }
        }
        print('=== END DEBUG ===');
        
      } else {
        // If no batch assigned, show all complaints (for debugging)
        complaintsData = await SupabaseService().getComplaints();
        _debugInfo = 'No batch assigned to advisor. Showing all complaints (${complaintsData.length} total)';
      }

        // Get students and batches for reference
        final usersData = await SupabaseService().getUsers();
        final batchesData = await SupabaseService().getBatches();

        setState(() {
          _complaints = complaintsData.map((json) => Complaint.fromJson(json)).toList();
          _filteredComplaints = List.from(_complaints);
          _students = usersData.where((u) => u['role'] == 'Student').map((json) => app_user.User.fromJson(json)).toList();
          _batches = batchesData.map((json) => Batch.fromJson(json)).toList();
        });

        // Debug: Print final complaint list
        print('=== FINAL COMPLAINT LIST ===');
        print('Total complaints loaded: ${_complaints.length}');
        print('Filtered complaints: ${_filteredComplaints.length}');
        for (var complaint in _complaints.take(5)) {
          print('Final Complaint: ${complaint.title} - Status: ${complaint.status} - Student: ${complaint.studentId}');
        }
        print('=== END FINAL LIST ===');

      // Debug: Print complaint details
      print('Debug: Found ${_complaints.length} complaints');
      for (var complaint in _complaints.take(3)) {
        print('Debug: Complaint ${complaint.id} - Batch: ${complaint.batchId}, Advisor: ${complaint.advisorId}');
      }

      print('Advisor Batch ID: $_advisorBatchId');
      print('Current User ID: ${currentUser.id}');

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

  Future<void> _checkDataIntegrity(String advisorId, String batchId) async {
    try {
      // Check if there are complaints in this batch that don't have the correct advisor_id
      final allComplaintsInBatch = await SupabaseService().getComplaints(
        filters: {'batch_id': batchId},
      );
      
      final complaintsWithWrongAdvisor = allComplaintsInBatch.where((c) => 
        c['advisor_id'] != advisorId && c['advisor_id'] != null && c['advisor_id'].toString().isNotEmpty
      ).toList();
      
      final complaintsWithNullAdvisor = allComplaintsInBatch.where((c) => 
        c['advisor_id'] == null || c['advisor_id'].toString().isEmpty
      ).toList();

      // Get students in this batch
      final studentsInBatch = await SupabaseService().getUsers();
      final studentsInThisBatch = studentsInBatch.where((u) => 
        u['role'] == 'Student' && u['batch_id'] == batchId
      ).toList();

      setState(() {
        _dataIntegrityInfo = {
          'total_complaints_in_batch': allComplaintsInBatch.length,
          'complaints_with_wrong_advisor': complaintsWithWrongAdvisor.length,
          'complaints_with_null_advisor': complaintsWithNullAdvisor.length,
          'students_in_batch': studentsInThisBatch.length,
          'complaints_visible_to_advisor': _complaints.length,
          'batch_id': batchId,
          'advisor_id': advisorId,
        };
      });

      print('Data Integrity Check:');
      print('- Total complaints in batch: ${allComplaintsInBatch.length}');
      print('- Complaints with wrong advisor: ${complaintsWithWrongAdvisor.length}');
      print('- Complaints with null advisor: ${complaintsWithNullAdvisor.length}');
      print('- Students in batch: ${studentsInThisBatch.length}');
      print('- Complaints visible to advisor: ${_complaints.length}');

    } catch (e) {
      print('Error checking data integrity: $e');
    }
  }

  Future<void> _fixComplaintAdvisorIds() async {
    try {
      if (_dataIntegrityInfo == null) return;
      
      final batchId = _dataIntegrityInfo!['batch_id'];
      final advisorId = _dataIntegrityInfo!['advisor_id'];
      
      // Update complaints with null or wrong advisor_id
      await SupabaseService().client
          .from(AppConstants.tableComplaints)
          .update({'advisor_id': advisorId})
          .eq('batch_id', batchId)
          .or('advisor_id.is.null,advisor_id.neq.$advisorId');
      
      // Refresh data
      await _loadData();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complaints updated successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fixing complaints: $e')),
      );
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
    
    // Debug print
    print('Filter applied:');
    print('- Selected student: $_selectedStudent');
    print('- Total complaints: ${_complaints.length}');
    print('- Filtered complaints: ${_filteredComplaints.length}');
    if (_selectedStudent != null) {
      final studentComplaints = _complaints.where((c) => c.studentId == _selectedStudent).toList();
      print('- Complaints for selected student: ${studentComplaints.length}');
      for (var complaint in studentComplaints.take(3)) {
        print('  - Complaint: ${complaint.title} (ID: ${complaint.id})');
      }
    }
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

  IconData getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return Icons.mark_email_unread;
      case AppConstants.statusInProgress:
        return Icons.autorenew;
      case AppConstants.statusEscalatedToHOD:
        return Icons.arrow_upward;
      case AppConstants.statusResolved:
        return Icons.check_circle;
      case AppConstants.statusRejected:
        return Icons.cancel;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = AuthService().currentUser;
    final noBatchAssigned = _advisorBatchId == null;
    final isViewingSpecificStudent = _selectedStudent != null;
    
    // Get student name for title
    String? studentName;
    if (isViewingSpecificStudent) {
      final student = _students.where((s) => s.id == _selectedStudent).firstOrNull;
      studentName = student?.name;
    }
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isViewingSpecificStudent 
          ? '${studentName ?? 'Student'}\'s Complaints' 
          : 'Batch Complaints'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.advisorDashboard),
        ),
        actions: [
          if (isViewingSpecificStudent)
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                setState(() {
                  _selectedStudent = null;
                });
                _applyFilters();
              },
              tooltip: 'Clear Student Filter',
            ),
          if (_dataIntegrityInfo != null)
            IconButton(
              icon: const Icon(Icons.warning),
              onPressed: () => _showDataIntegrityInfo(),
            ),
          if (_debugInfo != null)
            IconButton(
              icon: const Icon(Icons.info),
              onPressed: () => _showDebugInfo(),
            ),
        ],
      ),
      body: Column(
        children: [
          if (isViewingSpecificStudent)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.person, color: Colors.blue),
                      const SizedBox(width: 8),
                      Text(
                        'Viewing ${studentName ?? 'Student'}\'s Complaints',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Showing ${_filteredComplaints.length} complaints from this student',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            )
          else if (noBatchAssigned)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.orange[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ No Batch Assigned',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'You are not assigned to any batch. Contact admin to get assigned.',
                    style: TextStyle(fontSize: 12),
                  ),
                  if (_complaints.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Showing all complaints (${_complaints.length}) for debugging purposes.',
                      style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                    ),
                  ],
                ],
              ),
            )
          else if (currentUser != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue[50],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.blue),
                      const SizedBox(width: 8),
                      const Text(
                        'Batch Overview',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Total complaints in your batch: ${_complaints.length}'),
                  Text('Complaints with correct advisor: ${_complaints.where((c) => c.advisorId == currentUser.id).length}'),
                  Text('Complaints needing fix: ${_complaints.where((c) => c.advisorId != currentUser.id).length}'),
                  if (_complaints.where((c) => c.advisorId != currentUser.id).isNotEmpty) ...[
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _fixComplaintAdvisorIds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      child: const Text('Fix All Advisor Assignments'),
                    ),
                  ],
                ],
              ),
            ),
          if (_dataIntegrityInfo != null && _dataIntegrityInfo!['complaints_with_wrong_advisor'] > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              color: Colors.red[100],
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '⚠️ Data Integrity Issue Detected',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_dataIntegrityInfo!['complaints_with_wrong_advisor']} complaints have wrong advisor_id. '
                    '${_dataIntegrityInfo!['complaints_with_null_advisor']} complaints have null advisor_id.',
                    style: const TextStyle(fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showDataIntegrityInfo(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    child: const Text('View Details & Fix'),
                  ),
                ],
              ),
            ),
          _buildFilters(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredComplaints.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              'No complaints found',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'No complaints match your current filters.',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredComplaints.length,
                        itemBuilder: (context, index) {
                          final complaint = _filteredComplaints[index];
                          final student = _students.where((s) => s.id == complaint.studentId).firstOrNull;
                          final batch = _batches.where((b) => b.id == complaint.batchId).firstOrNull;
                          final hasCorrectAdvisor = complaint.advisorId == currentUser?.id;
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue[100],
                                child: Icon(Icons.person, color: Colors.blue),
                              ),
                              title: Text(
                                complaint.title,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Student: ${student?.name ?? 'Unknown'}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Batch: ${batch?.name ?? 'Unknown'}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Status: ${complaint.status}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  Text(
                                    'Created: ${complaint.createdAt.toString().split(' ')[0]}',
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  if (!hasCorrectAdvisor)
                                    Text(
                                      '⚠️ Wrong advisor assigned',
                                      style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                ],
                              ),
                              trailing: AnimatedContainer(
                                duration: Duration(milliseconds: 400),
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Color(int.parse(_getStatusColor(complaint.status).substring(1), radix: 16) + 0xFF000000),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(getStatusIcon(complaint.status), color: Colors.white, size: 16),
                                    SizedBox(width: 4),
                                    Text(
                                      complaint.status,
                                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                    ),
                                  ],
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

  void _showDataIntegrityInfo() {
    if (_dataIntegrityInfo == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Data Integrity Check'),
        content: SingleChildScrollView(
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
        children: [
              const Text(
                'Issue: Some complaints have incorrect advisor_id',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
              const SizedBox(height: 16),
              Text('Total complaints in your batch: ${_dataIntegrityInfo!['total_complaints_in_batch']}'),
              Text('Complaints visible to you: ${_dataIntegrityInfo!['complaints_visible_to_advisor']}'),
              Text('Complaints with wrong advisor_id: ${_dataIntegrityInfo!['complaints_with_wrong_advisor']}'),
              Text('Complaints with null advisor_id: ${_dataIntegrityInfo!['complaints_with_null_advisor']}'),
              Text('Students in your batch: ${_dataIntegrityInfo!['students_in_batch']}'),
              const SizedBox(height: 16),
              const Text(
                'Solution:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text('Run this SQL query in Supabase SQL Editor:'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'UPDATE complaints \n'
                  'SET advisor_id = \'${_dataIntegrityInfo!['advisor_id']}\' \n'
                  'WHERE batch_id = \'${_dataIntegrityInfo!['batch_id']}\' \n'
                  'AND (advisor_id IS NULL OR advisor_id != \'${_dataIntegrityInfo!['advisor_id']}\');',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 10,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'After running the query, refresh this page to see all complaints.',
                style: TextStyle(fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (_dataIntegrityInfo!['complaints_with_null_advisor'] > 0 || 
              _dataIntegrityInfo!['complaints_with_wrong_advisor'] > 0)
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _fixComplaintAdvisorIds();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
              child: const Text('Fix Issues'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _loadData(); // Refresh data
            },
            child: const Text('Refresh'),
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
              Text('Advisor batch ID: ${_advisorBatchId ?? 'None'}'),
              const SizedBox(height: 16),
              const Text('Complaint breakdown:'),
              ..._complaints.fold<Map<String, int>>({}, (map, complaint) {
                map[complaint.status] = (map[complaint.status] ?? 0) + 1;
                return map;
              }).entries.map((entry) => Text('${entry.key}: ${entry.value}')),
              if (_dataIntegrityInfo != null) ...[
                const SizedBox(height: 16),
                const Text('Data Integrity Info:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._dataIntegrityInfo!.entries.map((entry) => 
                  Text('${entry.key}: ${entry.value}')
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