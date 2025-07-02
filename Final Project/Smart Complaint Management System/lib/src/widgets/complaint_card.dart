import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../models/complaint.dart';

class ComplaintCard extends StatelessWidget {
  final Complaint complaint;
  final String studentName;
  final String? advisorName;
  final String? batchName;
  final VoidCallback? onTap;
  final bool showDetails;
  final bool showActions;

  const ComplaintCard({
    Key? key,
    required this.complaint,
    required this.studentName,
    this.advisorName,
    this.batchName,
    this.onTap,
    this.showDetails = true,
    this.showActions = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      complaint.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(),
                ],
              ),
              if (showDetails) ...[
                const SizedBox(height: 8),
                _buildDetails(),
              ],
              const SizedBox(height: 8),
              _buildFooter(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: _getStatusColor(complaint.status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        complaint.status,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (advisorName != null) ...[
          _buildDetailRow('Advisor', advisorName!),
        ],
        if (batchName != null) ...[
          _buildDetailRow('Batch', batchName!),
        ],
        _buildDetailRow('Student', studentName),
        _buildDetailRow('Submitted', complaint.createdAt.toString().split(' ')[0]),
        if (complaint.hasMedia) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.attach_file, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                'Has Media',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 12),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'ID: ${complaint.id.substring(0, 8)}...',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
        if (showActions) ...[
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.visibility, size: 16),
                onPressed: onTap,
                tooltip: 'View Details',
              ),
            ],
          ),
        ],
      ],
    );
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
} 