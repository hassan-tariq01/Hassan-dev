import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/complaint.dart';
import '../../models/complaint_log.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../widgets/timeline_view.dart';


class ComplaintStatus extends StatefulWidget {
  final String complaintId;

  const ComplaintStatus({Key? key, required this.complaintId}) : super(key: key);

  @override
  State<ComplaintStatus> createState() => _ComplaintStatusState();
}

class _ComplaintStatusState extends State<ComplaintStatus> {
  Complaint? _complaint;
  List<ComplaintLog> _logs = [];
  List<User> _users = [];
  bool _isLoading = true;
  String? _errorMessage;

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
        _errorMessage = 'Error loading complaint details: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getUserName(String userId) {
    final user = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => User(id: '', name: 'Unknown', email: '', role: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    return user.name;
  }

  String _getUserRole(String userId) {
    final user = _users.firstWhere(
      (u) => u.id == userId,
      orElse: () => User(id: '', name: 'Unknown', email: '', role: '', createdAt: DateTime.now(), updatedAt: DateTime.now()),
    );
    return user.role;
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

  IconData _getStatusIcon(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return Icons.schedule;
      case AppConstants.statusInProgress:
        return Icons.pending;
      case AppConstants.statusEscalatedToHOD:
        return Icons.escalator_warning;
      case AppConstants.statusResolved:
        return Icons.check_circle;
      case AppConstants.statusRejected:
        return Icons.cancel;
      default:
        return Icons.info;
    }
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
        title: const Text('Complaint Status'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.complaintHistory),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildComplaintHeader(),
            const SizedBox(height: 24),
            _buildComplaintDetails(),
            const SizedBox(height: 24),
            _buildCurrentStatus(),
            const SizedBox(height: 24),
            _buildTimeline(),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                color: _getStatusColor(_complaint!.status),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _complaint!.status,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintDetails() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Complaint Details',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text(
              _complaint!.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (_complaint!.hasMedia) ...[
              const SizedBox(height: 16),
              Text(
                'Media',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: () {
                  // Open media URL in browser or show media
                  print('Opening media: ${_complaint!.mediaUrl}');
                },
                child: Text(
                  _complaint!.mediaUrl!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Submitted on: ${_complaint!.createdAt.toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentStatus() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Status',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  _getStatusIcon(_complaint!.status),
                  color: _getStatusColor(_complaint!.status),
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _complaint!.status,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: _getStatusColor(_complaint!.status),
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Text(
                        _getStatusDescription(_complaint!.status),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusDescription(String status) {
    switch (status) {
      case AppConstants.statusSubmitted:
        return 'Your complaint has been submitted and is awaiting review by your batch advisor.';
      case AppConstants.statusInProgress:
        return 'Your complaint is being reviewed and processed by your batch advisor.';
      case AppConstants.statusEscalatedToHOD:
        return 'Your complaint has been escalated to the Head of Department for further review.';
      case AppConstants.statusResolved:
        return 'Your complaint has been successfully resolved.';
      case AppConstants.statusRejected:
        return 'Your complaint has been rejected. Please check the comments for details.';
      default:
        return 'Status unknown.';
    }
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
            if (_logs.isEmpty)
              const Text('No activity recorded yet.')
            else
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
            decoration: BoxDecoration(
              color: _getActionColor(log.action),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _getUserName(log.userId),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _getUserRole(log.userId),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _getActionDescription(log.action),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (log.comment != null) ...[
                  const SizedBox(height: 4),
                  Text(log.comment!),
                ],
                const SizedBox(height: 4),
                Text(
                  log.timestamp.toString().split(' ')[0],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case AppConstants.actionComment:
        return Colors.blue;
      case AppConstants.actionStatusChange:
        return Colors.green;
      case AppConstants.actionEscalation:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getActionDescription(String action) {
    switch (action) {
      case AppConstants.actionComment:
        return 'Added a comment';
      case AppConstants.actionStatusChange:
        return 'Updated complaint status';
      case AppConstants.actionEscalation:
        return 'Escalated complaint to HOD';
      default:
        return action;
    }
  }
}