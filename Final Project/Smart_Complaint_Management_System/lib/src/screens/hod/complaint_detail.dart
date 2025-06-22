import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/complaint.dart';
import '../models/complaint_log.dart';
import '../services/supabase_service.dart';
import '../utils/constants.dart';
import '../widgets/timeline_view.dart';
import '../widgets/custom_button.dart';
import '../widgets/input_field.dart';

class ComplaintDetail extends StatefulWidget {
  final String complaintId;

  const ComplaintDetail({super.key, required this.complaintId});

  @override
  _ComplaintDetailState createState() => _ComplaintDetailState();
}

class _ComplaintDetailState extends State<ComplaintDetail> {
  Complaint? complaint;
  List<ComplaintLog> logs = [];
  final _commentController = TextEditingController();
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchComplaintDetails();
  }

  Future<void> _fetchComplaintDetails() async {
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    try {
      final complaintData = await supabaseService.getComplaint(widget.complaintId);
      final logData = await supabaseService.getComplaintLogs(widget.complaintId);
      if (mounted) {
        setState(() {
          complaint = Complaint.fromJson(complaintData);
          logs = logData.map((log) => ComplaintLog.fromJson(log)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to load complaint: $e';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _addComment() async {
    if (_commentController.text.isEmpty) {
      setState(() {
        errorMessage = 'Comment cannot be empty';
      });
      return;
    }
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    try {
      await supabaseService.addComplaintLog(
        complaintId: widget.complaintId,
        action: 'Comment',
        comment: _commentController.text,
      );
      _commentController.clear();
      await _fetchComplaintDetails();
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to add comment: $e';
        });
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    final supabaseService = Provider.of<SupabaseService>(context, listen: false);
    try {
      await supabaseService.updateComplaintStatus(widget.complaintId, status);
      await _fetchComplaintDetails();
      if (mounted) {
        setState(() {
          errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Failed to update status: $e';
        });
      }
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Complaint #${widget.complaintId.substring(0, 8)}'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : complaint == null
          ? const Center(child: Text('Complaint not found'))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: ${complaint!.title}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Description: ${complaint!.description}'),
            const SizedBox(height: 8),
            Text('Status: ${complaint!.status}'),
            const SizedBox(height: 8),
            if (complaint!.mediaUrl != null)
              InkWell(
                onTap: () {
                  // TODO: Implement opening media URL (e.g., Google Drive link)
                },
                child: Text(
                  'Media: ${complaint!.mediaUrl}',
                  style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            TimelineView(logs: logs),
            const SizedBox(height: 16),
            if (complaint!.status == AppConstants.statusEscalated) ...[
              const Text(
                'Add Resolution Comment',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InputField(
                controller: _commentController,
                label: 'Comment',
                keyboardType: TextInputType.multiline,
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CustomButton(
                    text: 'Resolve',
                    onPressed: () async {
                      await _addComment();
                      await _updateStatus(AppConstants.statusResolved);
                    },
                  ),
                  CustomButton(
                    text: 'Reject',
                    onPressed: () async {
                      await _addComment();
                      await _updateStatus(AppConstants.statusRejected);
                    },
                  ),
                ],
              ),
            ],
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}