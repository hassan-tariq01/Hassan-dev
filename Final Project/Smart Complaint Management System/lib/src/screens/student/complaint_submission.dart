import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../auth/auth_service.dart';
import '../../models/batch.dart';
import '../../models/user.dart' as app_user;
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/routes.dart';

class ComplaintSubmission extends StatefulWidget {
  const ComplaintSubmission({Key? key}) : super(key: key);

  @override
  State<ComplaintSubmission> createState() => _ComplaintSubmissionState();
}

class _ComplaintSubmissionState extends State<ComplaintSubmission> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _mediaUrlController = TextEditingController();

  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _resultMessage;

  app_user.User? _student;
  Batch? _batch;
  app_user.User? _advisor;

  @override
  void initState() {
    super.initState();
    _loadStudentDetails();
  }

  Future<void> _loadStudentDetails() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return;

      // Get student details
      final users = await SupabaseService().getUsers();
      final student = users.where((u) => u['id'] == currentUser.id).firstOrNull;

      if (student != null) {
        _student = app_user.User.fromJson(student);

        // Get batch details
        if (_student!.batchId != null) {
          final batches = await SupabaseService().getBatches();
          final batch = batches.where((b) => b['id'] == _student!.batchId).firstOrNull;
          if (batch != null) {
            _batch = Batch.fromJson(batch);

            // Get advisor details
            if (_batch!.advisorId != null) {
              final advisor = users.where((u) => u['id'] == _batch!.advisorId).firstOrNull;
              if (advisor != null) {
                _advisor = app_user.User.fromJson(advisor);
              }
            }
          }
        }
      }
    } catch (e) {
      setState(() {
        _resultMessage = 'Error loading student details: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _submitComplaint() async {
    if (!_formKey.currentState!.validate()) return;
    if (_student == null || _batch == null) {
      setState(() {
        _resultMessage = 'You are not assigned to a batch. Please contact the admin.';
      });
      return;
    }
    if (_advisor == null) {
      setState(() {
        _resultMessage = 'Your batch does not have an assigned advisor. Please contact the admin.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _resultMessage = null;
    });

    try {
      final currentUser = AuthService().currentUser;
      if (currentUser == null) return;

      // Create complaint
      final complaintData = {
        'student_id': currentUser.id,
        'batch_id': _batch!.id,
        'advisor_id': _advisor!.id,
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'media_url': _mediaUrlController.text.trim().isEmpty ? null : _mediaUrlController.text.trim(),
        'status': AppConstants.statusSubmitted,
      };

      final response = await SupabaseService().client
          .from(AppConstants.tableComplaints)
          .insert(complaintData)
          .select()
          .single();

      // Add submission log
      try {
        await SupabaseService().client.from(AppConstants.tableComplaintLogs).insert({
          'complaint_id': response['id'],
          'user_id': currentUser.id,
          'action': AppConstants.actionStatusChange,
          'comment': 'Complaint submitted by student',
          'timestamp': DateTime.now().toIso8601String(),
        });
      } catch (logError) {
        print('Error inserting complaint log: ' + logError.toString());
        setState(() {
          _resultMessage = 'Complaint submitted, but failed to log activity. Please contact admin. Error: ' + logError.toString();
        });
        return;
      }

      setState(() {
        _resultMessage = 'Complaint submitted successfully!';
      });

      // Clear form
      _titleController.clear();
      _descriptionController.clear();
      _mediaUrlController.clear();
      _formKey.currentState!.reset();
    } catch (e) {
      setState(() {
        _resultMessage = 'Error submitting complaint: $e';
      });
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Complaint'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.studentDashboard),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStudentInfo(),
              const SizedBox(height: 24),
              _buildComplaintForm(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
              if (_resultMessage != null) ...[
                const SizedBox(height: 16),
                Text(
                  _resultMessage!,
                  style: TextStyle(
                    color: _resultMessage!.startsWith('Error') ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Information',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Text('Name: ${_student?.name ?? 'Not available'}'),
            Text('Batch: ${_batch?.name ?? 'Not assigned'}'),
            Text('Advisor: ${_advisor?.name ?? 'Not assigned'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildComplaintForm() {
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
            const SizedBox(height: 16),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Complaint Title',
                border: OutlineInputBorder(),
                hintText: 'Enter a brief title for your complaint',
              ),
              validator: Validators.validateTitle,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                hintText: 'Provide detailed description of your complaint',
              ),
              maxLines: 4,
              validator: Validators.validateDescription,
              enabled: !_isSubmitting,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _mediaUrlController,
              decoration: const InputDecoration(
                labelText: 'Media URL (Optional)',
                border: OutlineInputBorder(),
                hintText: 'Google Drive link or other media URL',
                helperText: 'You can add images, videos, or documents via URL',
              ),
              validator: Validators.validateMediaUrl,
              enabled: !_isSubmitting,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        onPressed: (_isSubmitting || _student == null || _batch == null || _advisor == null)
            ? null
            : _submitComplaint,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(AppConstants.primaryColor),
          foregroundColor: Colors.white,
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
          'Submit Complaint',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}