import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/batch.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../utils/validators.dart';

class BatchManagement extends StatefulWidget {
  const BatchManagement({Key? key}) : super(key: key);

  @override
  State<BatchManagement> createState() => _BatchManagementState();
}

class _BatchManagementState extends State<BatchManagement> {
  List<Batch> _batches = [];
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _loadBatches();
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoading = true);
    try {
      print('Loading batches from database...');
      final batchesData = await SupabaseService().getBatches();
      print('Raw batches data from database: $batchesData');
      print('Number of batches found: ${batchesData.length}');
      
      final departmentsData = await SupabaseService().getDepartments();
      print('Departments data: $departmentsData');
      
      final batches = batchesData.map((b) {
        print('Processing batch: $b');
        return Batch.fromJson(b);
      }).toList();
      
      print('Processed batches: ${batches.length}');
      for (final batch in batches) {
        print('Batch: ${batch.name} (ID: ${batch.id})');
      }
      
      setState(() {
        _batches = batches;
        _departments = departmentsData;
      });
      
      print('State updated with ${_batches.length} batches');
    } catch (e) {
      print('Error loading batches: $e');
      setState(() {
        _resultMessage = 'Error loading batches: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addBatch() async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_circle, color: const Color(AppConstants.primaryColor)),
            const SizedBox(width: 8),
            const Text('Add New Batch'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: 'Batch Name',
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  hintText: 'e.g., CS-2024-A, CS-2023-B',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(AppConstants.primaryColor),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(
                    Icons.class_,
                    color: Color(AppConstants.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Batch name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Batch name must be at least 3 characters';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Department: ${AppConstants.singleDepartmentName}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Add Batch',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        // Get or create department ID
        final departmentId = await _getOrCreateDepartmentId();
        
        print('Adding batch: ${result['name']} with department_id: $departmentId');
        
        final response = await SupabaseService().client.from(AppConstants.tableBatches).insert({
          'name': result['name'],
          'department_id': departmentId,
        }).select();
        
        print('Batch added successfully: $response');
        await _loadBatches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Batch "${result['name']}" added successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error adding batch: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding batch: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _ensureDepartmentExists() async {
    try {
      // Check if department exists
      final existingDept = await SupabaseService().client
          .from(AppConstants.tableDepartments)
          .select()
          .eq('id', AppConstants.singleDepartmentId);
      
      if (existingDept.isNotEmpty) {
        print('Department already exists: ${existingDept[0]}');
        return;
      }
      
      print('Department not found, creating it...');
      // Department doesn't exist, create it
      final newDept = await SupabaseService().client
          .from(AppConstants.tableDepartments)
          .insert({
            'id': AppConstants.singleDepartmentId,
            'name': AppConstants.singleDepartmentName,
          })
          .select();
      print('Department created successfully: $newDept');
    } catch (e) {
      print('Error in _ensureDepartmentExists: $e');
      // If it's a duplicate key error, the department already exists
      if (e.toString().contains('duplicate key') || e.toString().contains('unique constraint')) {
        print('Department already exists (caught duplicate key error)');
        return;
      }
      // Re-throw other errors
      rethrow;
    }
  }

  Future<void> _editBatch(Batch batch) async {
    final nameController = TextEditingController(text: batch.name);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: const Color(AppConstants.primaryColor)),
            const SizedBox(width: 8),
            const Text('Edit Batch'),
          ],
        ),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  labelText: 'Batch Name',
                  labelStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  hintText: 'e.g., CS-2024-A, CS-2023-B',
                  hintStyle: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Color(AppConstants.primaryColor),
                      width: 2,
                    ),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                  prefixIcon: const Icon(
                    Icons.class_,
                    color: Color(AppConstants.primaryColor),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Batch name is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Batch name must be at least 3 characters';
                  }
                  return null;
                },
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.business, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Department: ${AppConstants.singleDepartmentName}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Update Batch',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        await SupabaseService().client
            .from(AppConstants.tableBatches)
            .update({
              'name': result['name'],
              'department_id': AppConstants.singleDepartmentId,
            })
            .eq('id', batch.id);
        await _loadBatches();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Batch "${result['name']}" updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating batch: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBatch(Batch batch) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text('Are you sure you want to delete "${batch.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await SupabaseService().client
            .from(AppConstants.tableBatches)
            .delete()
            .eq('id', batch.id);
        _loadBatches();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Batch deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting batch: $e')),
        );
      }
    }
  }

  String _getDepartmentName(String departmentId) {
    return AppConstants.singleDepartmentName;
  }

  Future<void> _addSampleBatches() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sample Batches'),
        content: const Text('This will create 8 sample batches for Computer Science department. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      try {
        // Get or create department ID
        final departmentId = await _getOrCreateDepartmentId();

        // Sample batches for Computer Science - 8 batches covering different years
        final sampleBatches = [
          {'name': 'CS-2024-A', 'department_id': departmentId, 'description': 'Computer Science 2024 Batch A'},
          {'name': 'CS-2024-B', 'department_id': departmentId, 'description': 'Computer Science 2024 Batch B'},
          {'name': 'CS-2023-A', 'department_id': departmentId, 'description': 'Computer Science 2023 Batch A'},
          {'name': 'CS-2023-B', 'department_id': departmentId, 'description': 'Computer Science 2023 Batch B'},
          {'name': 'CS-2022-A', 'department_id': departmentId, 'description': 'Computer Science 2022 Batch A'},
          {'name': 'CS-2022-B', 'department_id': departmentId, 'description': 'Computer Science 2022 Batch B'},
          {'name': 'CS-2021-A', 'department_id': departmentId, 'description': 'Computer Science 2021 Batch A'},
          {'name': 'CS-2021-B', 'department_id': departmentId, 'description': 'Computer Science 2021 Batch B'},
        ];

        for (final batch in sampleBatches) {
          try {
            print('Inserting batch: ${batch['name']}');
            final batchResponse = await SupabaseService().client.from(AppConstants.tableBatches).insert(batch).select();
            print('Batch inserted: $batchResponse');
          } catch (batchError) {
            print('Error inserting batch ${batch['name']}: $batchError');
            throw batchError;
          }
        }

        _loadBatches();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('8 sample batches created successfully for Computer Science department!'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating sample batches: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _testDatabaseConnection() async {
    try {
      print('Testing database connection...');
      
      // Test departments table
      final deptTest = await SupabaseService().client
          .from(AppConstants.tableDepartments)
          .select()
          .limit(1);
      print('Departments table accessible: ${deptTest.length} records found');
      
      // Test batches table
      final batchTest = await SupabaseService().client
          .from(AppConstants.tableBatches)
          .select()
          .limit(1);
      print('Batches table accessible: ${batchTest.length} records found');
      
      // Test inserting a simple department with unique ID
      final testDeptId = 'test-dept-${DateTime.now().millisecondsSinceEpoch}';
      try {
        final testDept = await SupabaseService().client
            .from(AppConstants.tableDepartments)
            .insert({
              'id': testDeptId,
              'name': 'Test Department',
            })
            .select();
        print('Test department created: $testDept');
        
        // Clean up test data
        await SupabaseService().client
            .from(AppConstants.tableDepartments)
            .delete()
            .eq('id', testDeptId);
        print('Test data cleaned up');
      } catch (e) {
        print('Error creating test department: $e');
        // Try to clean up if it was created
        try {
          await SupabaseService().client
              .from(AppConstants.tableDepartments)
              .delete()
              .eq('id', testDeptId);
          print('Test data cleaned up after error');
        } catch (cleanupError) {
          print('Error cleaning up test data: $cleanupError');
        }
      }
      
    } catch (e) {
      print('Database test failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database test failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  Future<void> _setupDatabase() async {
    try {
      print('Setting up database...');
      
      // 1. Check if departments table exists and has data
      try {
        final deptData = await SupabaseService().client
            .from(AppConstants.tableDepartments)
            .select();
        print('Departments count: ${deptData.length}');
      } catch (e) {
        print('Error checking departments: $e');
      }
      
      // 2. Check if batches table exists and has data
      try {
        final batchData = await SupabaseService().client
            .from(AppConstants.tableBatches)
            .select();
        print('Batches count: ${batchData.length}');
      } catch (e) {
        print('Error checking batches: $e');
      }
      
      // 3. Get or create department
      final departmentId = await _getOrCreateDepartmentId();
      print('Using department ID: $departmentId');
      
      // 4. Test batch insertion
      try {
        final testBatch = await SupabaseService().client
            .from(AppConstants.tableBatches)
            .insert({
              'name': 'TEST-BATCH-${DateTime.now().millisecondsSinceEpoch}',
              'department_id': departmentId,
            })
            .select();
        print('Test batch created: $testBatch');
        
        // Clean up test batch
        await SupabaseService().client
            .from(AppConstants.tableBatches)
            .delete()
            .eq('name', testBatch[0]['name']);
        print('Test batch cleaned up');
        
      } catch (e) {
        print('Error testing batch insertion: $e');
        throw e;
      }
      
      print('Database setup completed successfully');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database setup completed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      
    } catch (e) {
      print('Database setup failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database setup failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 10),
          ),
        );
      }
    }
  }

  Future<String> _getOrCreateDepartmentId() async {
    try {
      // First try to find the department by name
      final existingDept = await SupabaseService().client
          .from(AppConstants.tableDepartments)
          .select()
          .eq('name', AppConstants.singleDepartmentName);
      
      if (existingDept.isNotEmpty) {
        print('Found existing department: ${existingDept[0]}');
        return existingDept[0]['id'] as String;
      }
      
      // Department doesn't exist, create it
      print('Creating new department...');
      final newDept = await SupabaseService().client
          .from(AppConstants.tableDepartments)
          .insert({
            'id': AppConstants.singleDepartmentId,
            'name': AppConstants.singleDepartmentName,
          })
          .select();
      
      print('Department created: ${newDept[0]}');
      return newDept[0]['id'] as String;
    } catch (e) {
      print('Error in _getOrCreateDepartmentId: $e');
      // If it's a duplicate key error, try to find the existing department
      if (e.toString().contains('duplicate key') || e.toString().contains('unique constraint')) {
        print('Duplicate key error, trying to find existing department...');
        try {
          final existingDept = await SupabaseService().client
              .from(AppConstants.tableDepartments)
              .select()
              .eq('name', AppConstants.singleDepartmentName);
          
          if (existingDept.isNotEmpty) {
            print('Found existing department after duplicate key error: ${existingDept[0]}');
            return existingDept[0]['id'] as String;
          }
        } catch (findError) {
          print('Error finding existing department: $findError');
        }
      }
      // Re-throw other errors
      rethrow;
    }
  }

  Future<void> _checkDatabaseBatches() async {
    try {
      print('=== DATABASE BATCH CHECK ===');
      
      // Direct database query
      final directQuery = await SupabaseService().client
          .from(AppConstants.tableBatches)
          .select('*');
      print('Direct query result: $directQuery');
      print('Direct query count: ${directQuery.length}');
      
      // Service method query
      final serviceQuery = await SupabaseService().getBatches();
      print('Service query result: $serviceQuery');
      print('Service query count: ${serviceQuery.length}');
      
      // Check if there are any batches
      if (directQuery.isEmpty) {
        print('No batches found in database!');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No batches found in database. Please add some batches first.'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 5),
            ),
          );
        }
      } else {
        print('Batches found in database:');
        for (final batch in directQuery) {
          print('- ${batch['name']} (ID: ${batch['id']})');
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Found ${directQuery.length} batches in database'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );
        }
      }
      
    } catch (e) {
      print('Error checking database batches: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking database: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Batch Management'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBatches,
            tooltip: 'Refresh Batches',
          ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _checkDatabaseBatches,
            tooltip: 'Check Database',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _setupDatabase,
            tooltip: 'Setup Database',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _testDatabaseConnection,
            tooltip: 'Test Database',
          ),
          IconButton(
            icon: const Icon(Icons.add_chart),
            onPressed: _addSampleBatches,
            tooltip: 'Add Sample Batches',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.class_,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No batches found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add batches to get started with complaint management',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _addSampleBatches,
                        icon: const Icon(Icons.add_chart),
                        label: const Text('Add Sample Batches'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(AppConstants.primaryColor),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _batches.length,
                  itemBuilder: (context, index) {
                    final batch = _batches[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(AppConstants.primaryColor),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    batch.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, color: Colors.blue),
                                      onPressed: () => _editBatch(batch),
                                      tooltip: 'Edit Batch',
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, color: Colors.red),
                                      onPressed: () => _deleteBatch(batch),
                                      tooltip: 'Delete Batch',
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.business, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Department: ${_getDepartmentName(batch.departmentId)}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 4),
                                Text(
                                  'Created: ${batch.createdAt.toString().split(' ')[0]}',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  batch.hasAdvisor ? Icons.person : Icons.person_off,
                                  size: 16,
                                  color: batch.hasAdvisor ? Colors.green : Colors.orange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  batch.hasAdvisor ? 'Advisor: Assigned' : 'Advisor: Not Assigned',
                                  style: TextStyle(
                                    color: batch.hasAdvisor ? Colors.green : Colors.orange,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addBatch,
        backgroundColor: const Color(AppConstants.primaryColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 