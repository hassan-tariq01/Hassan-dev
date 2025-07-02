import 'package:flutter/material.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import 'package:go_router/go_router.dart';

import '../../utils/routes.dart';

class AdvisorAssignment extends StatefulWidget {
  const AdvisorAssignment({Key? key}) : super(key: key);

  @override
  State<AdvisorAssignment> createState() => _AdvisorAssignmentState();
}

class _AdvisorAssignmentState extends State<AdvisorAssignment> {
  String? _selectedDepartmentId;
  String? _selectedBatchId;
  String? _selectedAdvisorId;
  List<Map<String, dynamic>> _departments = [];
  List<Map<String, dynamic>> _batches = [];
  List<Map<String, dynamic>> _advisors = [];
  bool _isLoading = true;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _loadDepartmentsAndAdvisors();
  }

  Future<void> _loadDepartmentsAndAdvisors() async {
    setState(() => _isLoading = true);
    try {
      final advisors = await SupabaseService().getUsers(role: AppConstants.roleBatchAdvisor);
      final batches = await SupabaseService().getBatches();
      setState(() {
        _advisors = advisors;
        _batches = batches;
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error loading data: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadBatches() async {
    setState(() {
      _isLoading = true;
      _batches = [];
      _selectedBatchId = null;
    });
    try {
      final batches = await SupabaseService().getBatches();
      setState(() {
        _batches = batches;
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error loading batches: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _assignAdvisor() async {
    if (_selectedBatchId == null || _selectedAdvisorId == null) return;
    setState(() {
      _isLoading = true;
      _resultMessage = null;
    });
    try {
      // Check if advisor is already assigned to another batch
      final existingAssignment = await SupabaseService().client
          .from(AppConstants.tableBatches)
          .select('name')
          .eq('advisor_id', _selectedAdvisorId as Object)
          .neq('id', _selectedBatchId as Object)
          .maybeSingle();

      if (existingAssignment != null) {
        setState(() {
          _resultMessage = 'Error: This advisor is already assigned to batch "${existingAssignment['name']}". Each advisor can only be assigned to one batch.';
        });
        return;
      }

      // Check if batch already has an advisor
      final currentBatch = await SupabaseService().client
          .from(AppConstants.tableBatches)
          .select('advisor_id, name')
          .eq('id', _selectedBatchId as Object)
          .single();

      if (currentBatch['advisor_id'] != null) {
        // Get advisor name for confirmation
        final currentAdvisor = _advisors.where((a) => a['id'].toString() == currentBatch['advisor_id'].toString()).firstOrNull;
        final currentAdvisorName = currentAdvisor?['name'] ?? 'Unknown Advisor';
        
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Replace Current Advisor'),
            content: Text('Batch "${currentBatch['name']}" is currently assigned to "$currentAdvisorName". Do you want to replace them with the new advisor?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Replace'),
              ),
            ],
          ),
        );

        if (confirm != true) {
          setState(() => _isLoading = false);
          return;
        }
      }

      // Assign the advisor
      await SupabaseService().client
          .from(AppConstants.tableBatches)
          .update({'advisor_id': _selectedAdvisorId as Object})
          .eq('id', _selectedBatchId as Object);

      // Clear selections
      setState(() {
        _selectedBatchId = null;
        _selectedAdvisorId = null;
        _batches = [];
        _resultMessage = 'Advisor assigned successfully!';
      });

      // Reload data to show updated assignments
      _loadDepartmentsAndAdvisors();
    } catch (e) {
      setState(() {
        _resultMessage = 'Error assigning advisor: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _getStringValue(dynamic value) {
    return value?.toString() ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advisor Assignment'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Current Assignments Section
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue[700]),
                            const SizedBox(width: 8),
                            Text(
                              'Current Advisor Assignments',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[700],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Each advisor can only be assigned to one batch. View current assignments below.',
                          style: TextStyle(color: Colors.blue[600]),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Assignment Form
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assign New Advisor',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[200]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.business, color: Colors.blue[700]),
                              const SizedBox(width: 8),
                              Text(
                                'Department: ${AppConstants.singleDepartmentName}',
                                style: TextStyle(
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedBatchId,
                    decoration: const InputDecoration(
                      labelText: 'Select Batch',
                      border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.class_),
                    ),
                    items: _batches
                        .map((b) => DropdownMenuItem<String>(
                              value: _getStringValue(b['id']),
                              child: Text(_getStringValue(b['name'])),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedBatchId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedAdvisorId,
                    decoration: const InputDecoration(
                      labelText: 'Select Advisor',
                      border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                    ),
                    items: _advisors
                        .map((a) => DropdownMenuItem<String>(
                              value: _getStringValue(a['id']),
                              child: Text('${_getStringValue(a['name'])} (${_getStringValue(a['email'])})'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedAdvisorId = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                    onPressed: (_selectedBatchId != null && _selectedAdvisorId != null && !_isLoading)
                        ? _assignAdvisor
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryColor),
                      foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Assign Advisor'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  if (_resultMessage != null) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _resultMessage!.startsWith('Error') ? Colors.red[50] : Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _resultMessage!.startsWith('Error') ? Colors.red[200]! : Colors.green[200]!,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _resultMessage!.startsWith('Error') ? Icons.error : Icons.check_circle,
                            color: _resultMessage!.startsWith('Error') ? Colors.red[600] : Colors.green[600],
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                      _resultMessage!,
                      style: TextStyle(
                                color: _resultMessage!.startsWith('Error') ? Colors.red[700] : Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 24),
                  
                  // Current Assignments List
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Assignments',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 16),
                        _buildAssignmentsList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildAssignmentsList() {
    final assignedBatches = _batches.where((b) => b['advisor_id'] != null).toList();
    
    if (assignedBatches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'No advisor assignments found',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return Column(
      children: assignedBatches.map((batch) {
        final advisor = _advisors.where((a) => a['id'].toString() == batch['advisor_id'].toString()).firstOrNull;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(AppConstants.primaryColor),
              child: Icon(Icons.person, color: Colors.white),
            ),
            title: Text(advisor?['name'] ?? 'Unknown Advisor'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Batch: ${batch['name']}'),
                Text('Department: ${AppConstants.singleDepartmentName}'),
                Text('Email: ${advisor?['email'] ?? 'N/A'}'),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeAssignment(batch['id']),
              tooltip: 'Remove Assignment',
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _removeAssignment(String batchId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Assignment'),
        content: const Text('Are you sure you want to remove this advisor assignment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService().client
            .from(AppConstants.tableBatches)
            .update({'advisor_id': null})
            .eq('id', batchId as Object);
        
        setState(() {
          _resultMessage = 'Assignment removed successfully!';
        });
        
        // Reload data
        _loadDepartmentsAndAdvisors();
      } catch (e) {
        setState(() {
          _resultMessage = 'Error removing assignment: $e';
        });
      }
    }
  }
} 