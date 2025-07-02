import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_service.dart';
import '../../models/complaint.dart';
import '../../models/complaint_log.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';

class ComplaintDetail extends StatefulWidget {
  final String complaintId;

  const ComplaintDetail({Key? key, required this.complaintId}) : super(key: key);

  @override
  State<ComplaintDetail> createState() => _ComplaintDetailState();
}

class _ComplaintDetailState extends State<ComplaintDetail> {
  Complaint? _complaint;
  List<ComplaintLog> _logs = [];
  List<User> _users = [];
  bool _isLoading = true;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _loadComplaintDetails();
  }

  Future<void> _loadComplaintDetails() async {
    setState(() => _isLoading = true);
    try {
      // Load complaint details
      final complaints = await SupabaseService().getComplaints(
        filters: {'id': widget.complaintId},
      );
      if (complaints.isNotEmpty) {
        _complaint = Complaint.fromJson(complaints.first);
      }

      // Load complaint logs
      final logsData = await SupabaseService().getComplaintLogs(widget.complaintId);
      _logs = logsData.map((json) => ComplaintLog.fromJson(json)).toList();

      // Load users for reference
      final usersData = await SupabaseService().getUsers();
      _users = usersData.map((json) => User.fromJson(json)).toList();
    } catch (e) {
      setState(() {
        _resultMessage = 'Error loading complaint details: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addComment() async {
    final commentController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Resolution Comment'),
        content: TextField(
          controller: commentController,
          decoration: const InputDecoration(
            labelText: 'Comment',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.pop(context, commentController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final currentUser = AuthService().currentUser;
        if (currentUser != null) {
          await SupabaseService().client.from(AppConstants.tableComplaintLogs).insert({
            'complaint_id': widget.complaintId,
            'user_id': currentUser.id,
            'action': AppConstants.actionComment,
            'comment': result,
            'timestamp': DateTime.now().toIso8601String(),
          });
          _loadComplaintDetails();
          setState(() {
            _resultMessage = 'Comment added successfully!';
          });
        }
      } catch (e) {
        setState(() {
          _resultMessage = 'Error adding comment: $e';
        });
      }
    }
  }

  Future<void> _resolveComplaint() async {
    final commentController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Resolve Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a resolution comment:'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Resolution Comment',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.pop(context, commentController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Resolve'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final currentUser = AuthService().currentUser;
        if (currentUser != null) {
          // Update complaint status
          await SupabaseService().client
              .from(AppConstants.tableComplaints)
              .update({'status': AppConstants.statusResolved})
              .eq('id', widget.complaintId);

          // Add resolution log
          await SupabaseService().client.from(AppConstants.tableComplaintLogs).insert({
            'complaint_id': widget.complaintId,
            'user_id': currentUser.id,
            'action': AppConstants.actionStatusChange,
            'comment': 'Complaint resolved by HOD: $result',
            'timestamp': DateTime.now().toIso8601String(),
          });

          _loadComplaintDetails();
          setState(() {
            _resultMessage = 'Complaint resolved successfully!';
          });
        }
      } catch (e) {
        setState(() {
          _resultMessage = 'Error resolving complaint: $e';
        });
      }
    }
  }

  Future<void> _rejectComplaint() async {
    final commentController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Complaint'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Please provide a rejection reason:'),
            const SizedBox(height: 16),
            TextField(
              controller: commentController,
              decoration: const InputDecoration(
                labelText: 'Rejection Reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (commentController.text.trim().isNotEmpty) {
                Navigator.pop(context, commentController.text.trim());
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        final currentUser = AuthService().currentUser;
        if (currentUser != null) {
          // Update complaint status
          await SupabaseService().client
              .from(AppConstants.tableComplaints)
              .update({'status': AppConstants.statusRejected})
              .eq('id', widget.complaintId);

          // Add rejection log
          await SupabaseService().client.from(AppConstants.tableComplaintLogs).insert({
            'complaint_id': widget.complaintId,
            'user_id': currentUser.id,
            'action': AppConstants.actionStatusChange,
            'comment': 'Complaint rejected by HOD: $result',
            'timestamp': DateTime.now().toIso8601String(),
          });

          _loadComplaintDetails();
          setState(() {
            _resultMessage = 'Complaint rejected successfully!';
          });
        }
      } catch (e) {
        setState(() {
          _resultMessage = 'Error rejecting complaint: $e';
        });
      }
    }
  }

  String _getUserName(String userId) {
    final user = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => User(id: '', name: 'Unknown', email: '', role: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    return user.name;
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_complaint == null) {
      return const Scaffold(
        body: Center(child: Text('Complaint not found')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Escalated Complaint Details'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.hodComplaintList),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildComplaintHeader(),
            const SizedBox(height: 24),
            _buildComplaintContent(),
            const SizedBox(height: 24),
            _buildResolutionActions(),
            const SizedBox(height: 24),
            _buildTimeline(),
            if (_resultMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _resultMessage!,
                style: TextStyle(
                  color: _resultMessage!.startsWith('Error') ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _complaint!.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: const Color(AppConstants.escalatedColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Escalated to HOD',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintContent() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Description',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(_complaint!.description),
            if (_complaint!.hasMedia) ...[
              const SizedBox(height: 16),
              Text(
                'Media',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(_complaint!.mediaUrl!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResolutionActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Resolution Actions',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addComment,
                    icon: const Icon(Icons.comment),
                    label: const Text('Add Comment'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _resolveComplaint,
                    icon: const Icon(Icons.check),
                    label: const Text('Resolve'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _rejectComplaint,
                icon: const Icon(Icons.cancel),
                label: const Text('Reject Complaint'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaint Timeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ..._logs.map((log) => _buildTimelineItem(log)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(ComplaintLog log) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: const BoxDecoration(
              color: Color(AppConstants.primaryColor),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_getUserName(log.userId)} - ${log.action}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (log.comment != null) ...[
                  const SizedBox(height: 4),
                  Text(log.comment!),
                ],
                const SizedBox(height: 4),
                Text(
                  log.timestamp.toString().split(' ')[0],
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 