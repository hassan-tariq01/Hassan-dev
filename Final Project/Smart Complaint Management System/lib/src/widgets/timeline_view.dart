import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/complaint_log.dart';

class TimelineView extends StatelessWidget {
  final List<ComplaintLog> logs;
  final Map<String, String> userNames;
  final Map<String, String> userRoles;

  const TimelineView({
    Key? key,
    required this.logs,
    required this.userNames,
    required this.userRoles,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (logs.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('No activity recorded yet.'),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...logs.map((log) => _buildTimelineItem(log)).toList(),
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
          _buildTimelineDot(log.action),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTimelineHeader(log),
                const SizedBox(height: 4),
                _buildTimelineContent(log),
                const SizedBox(height: 4),
                _buildTimelineFooter(log),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineDot(String action) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getActionColor(action),
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineHeader(ComplaintLog log) {
    final userName = userNames[log.userId] ?? 'Unknown';
    final userRole = userRoles[log.userId] ?? 'Unknown';

    return Row(
      children: [
        Text(
          userName,
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
            userRole,
            style: const TextStyle(fontSize: 10),
          ),
        ),
      ],
    );
  }

  Widget _buildTimelineContent(ComplaintLog log) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _getActionDescription(log.action),
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        if (log.comment != null) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Text(
              log.comment!,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimelineFooter(ComplaintLog log) {
    return Text(
      _formatTimestamp(log.timestamp),
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey[600],
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

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
} 