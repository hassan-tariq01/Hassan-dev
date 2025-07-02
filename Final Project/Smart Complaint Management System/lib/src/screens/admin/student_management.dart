import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart' as app_user;
import '../../models/batch.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../utils/validators.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide User;

class StudentManagement extends StatefulWidget {
  const StudentManagement({Key? key}) : super(key: key);

  @override
  State<StudentManagement> createState() => _StudentManagementState();
}

class _StudentManagementState extends State<StudentManagement> {
  List<app_user.User> _students = [];
  List<Batch> _batches = [];
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  String? _resultMessage;
  String? _selectedBatchFilter;
  String? _selectedDepartmentFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      print('Loading students, batches, and departments...');
      final studentsData = await SupabaseService().getUsers(role: AppConstants.roleStudent);
      final batchesData = await SupabaseService().getBatches();
      final departmentsData = await SupabaseService().getDepartments();
      
      print('Raw batches data: $batchesData');
      print('Raw departments data: $departmentsData');
      print('Single department ID constant: ${AppConstants.singleDepartmentId}');
      
      setState(() {
        _students = studentsData.map((s) => app_user.User.fromJson(s)).toList();
        _batches = batchesData.map((b) => Batch.fromJson(b)).toList();
        _departments = departmentsData;
      });
      
      print('Processed batches: ${_batches.map((b) => '${b.name} (dept: ${b.departmentId})').toList()}');
      print('Filtered batches for CS department: ${_batches.where((b) => b.departmentId == AppConstants.singleDepartmentId).map((b) => b.name).toList()}');
    } catch (e) {
      print('Error in _loadStudents: $e');
      setState(() {
        _resultMessage = 'Error loading students: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addStudent() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final studentIdController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    String? selectedBatchId;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Student'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      helperText: 'Minimum 6 characters required',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Password is required';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: studentIdController,
                    decoration: const InputDecoration(
                      labelText: 'Student ID',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.badge),
                      helperText: 'Format: CS2024001 (Department + Year + 3-digit number)',
                    ),
                    validator: Validators.validateStudentId,
                  ),
                  const SizedBox(height: 16),
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
                    value: selectedBatchId,
                    decoration: const InputDecoration(
                      labelText: 'Batch',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.class_),
                    ),
                    items: _batches
                        .map((b) => DropdownMenuItem<String>(
                              value: b.id,
                              child: Text('${b.name} (Dept: ${b.departmentId})'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedBatchId = value;
                      });
                      print('Selected batch: $value');
                      if (value != null) {
                        try {
                          final selectedBatch = _batches.firstWhere((b) => b.id == value);
                          print('Selected batch details: ${selectedBatch.toString()}');
                        } catch (e) {
                          print('Error finding selected batch: $e');
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a batch';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && selectedBatchId != null) {
                  Navigator.pop(context, {
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'password': passwordController.text,
                    'studentId': studentIdController.text.trim(),
                    'batchId': selectedBatchId!,
                  });
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        print('Adding student: ${result['name']} with email: ${result['email']}');
        print('Student ID: ${result['studentId']}');
        print('Batch ID: ${result['batchId']}');
        
        // First create authentication user
        final authResponse = await SupabaseService().client.auth.signUp(
          email: result['email']!,
          password: result['password']!,
          // For development, we can disable email confirmation requirement
          // In production, you would want to enable this
          emailRedirectTo: 'io.supabase.flutter://login-callback/',
        );

        if (authResponse.user != null) {
          print('Auth user created: ${authResponse.user!.id}');
          print('Email confirmation status: ${authResponse.user!.emailConfirmedAt}');
          
          // Note: For development purposes, we can proceed even without email confirmation
          // In production, you would want to enforce email confirmation
          if (authResponse.user!.emailConfirmedAt == null) {
            print('Warning: User email not confirmed. This is normal for development.');
            print('In production, users would need to confirm their email before login.');
          }
          
          // Get or create department ID
          final departmentId = await _getOrCreateDepartmentId();
          print('Using department ID: $departmentId');
          
          // Prepare user data
          final userData = {
            'id': authResponse.user!.id,
            'name': result['name'],
            'email': result['email'],
            'role': AppConstants.roleStudent,
            'batch_id': result['batchId'],
            'department_id': departmentId,
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          
          // Try to add student_id if the column exists
          try {
            userData['student_id'] = result['studentId'];
          } catch (e) {
            print('Warning: student_id column may not exist in database');
            print('Student ID will be stored in name field as: ${result['name']} (${result['studentId']})');
            // Store student ID in name field as fallback
            userData['name'] = '${result['name']} (${result['studentId']})';
          }
          
          print('User data to insert: $userData');
          
          // Then add user to database
          final userResponse = await SupabaseService().client
              .from(AppConstants.tableUsers)
              .insert(userData)
              .select();
          
          print('User added to database: $userResponse');

          await _loadStudents();
          if (mounted) {
            // Show success message with email confirmation info
            final emailConfirmed = authResponse.user!.emailConfirmedAt != null;
            final message = emailConfirmed 
                ? 'Student "${result['name']}" added successfully! They can now login with their email and password.'
                : 'Student "${result['name']}" added successfully! They can login with their email and password. '
                  'Note: Email confirmation is not required for development purposes.';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(message),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 6),
              ),
            );
          }
        } else {
          throw Exception('Failed to create authentication user');
        }
      } catch (e) {
        print('Error adding student: $e');
        print('Error details: ${e.toString()}');
        
        // Check if it's a unique constraint error
        if (e.toString().contains('duplicate key') || e.toString().contains('unique constraint')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Student with this email or student ID already exists.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else if (e.toString().contains('foreign key constraint')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Selected batch or department does not exist. Please check your data.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error adding student: $e'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          }
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _editStudent(app_user.User student) async {
    final nameController = TextEditingController(text: student.name);
    final emailController = TextEditingController(text: student.email);
    final formKey = GlobalKey<FormState>();
    String? selectedBatchId = student.batchId;
    String? selectedDepartmentId = student.departmentId;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Student'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validateName,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: Validators.validateEmail,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedDepartmentId,
                    decoration: const InputDecoration(
                      labelText: 'Department',
                      border: OutlineInputBorder(),
                    ),
                    items: _departments
                        .map((d) => DropdownMenuItem<String>(
                              value: d['id'].toString(),
                              child: Text(d['name']),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedDepartmentId = value;
                        selectedBatchId = null;
                      });
                      print('Selected department: $value');
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a department';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedBatchId,
                    decoration: const InputDecoration(
                      labelText: 'Batch',
                      border: OutlineInputBorder(),
                    ),
                    items: _batches
                        .where((b) => selectedDepartmentId == null || b.departmentId == selectedDepartmentId)
                        .map((b) => DropdownMenuItem<String>(
                              value: b.id,
                              child: Text('${b.name} (${b.departmentId})'),
                            ))
                        .toList(),
                    onChanged: (value) {
                      setDialogState(() {
                        selectedBatchId = value;
                      });
                      print('Selected batch: $value');
                      if (value != null) {
                        try {
                          final selectedBatch = _batches.firstWhere((b) => b.id == value);
                          print('Selected batch details: ${selectedBatch.toString()}');
                        } catch (e) {
                          print('Error finding selected batch: $e');
                        }
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select a batch';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate() && selectedBatchId != null && selectedDepartmentId != null) {
                  Navigator.pop(context, {
                    'name': nameController.text.trim(),
                    'email': emailController.text.trim(),
                    'batchId': selectedBatchId!,
                    'departmentId': selectedDepartmentId!,
                  });
                }
              },
              child: const Text('Update'),
            ),
          ],
        ),
      ),
    );

    if (result != null) {
      try {
        await SupabaseService().client
            .from(AppConstants.tableUsers)
            .update({
              'name': result['name'],
              'email': result['email'],
              'batch_id': result['batchId'],
              'department_id': result['departmentId'],
            })
            .eq('id', student.id);
        _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating student: $e')),
        );
      }
    }
  }

  Future<void> _deleteStudent(app_user.User student) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Student'),
        content: Text('Are you sure you want to delete "${student.name}"? This action cannot be undone.'),
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
            .from(AppConstants.tableUsers)
            .delete()
            .eq('id', student.id);
        _loadStudents();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Student deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting student: $e')),
        );
      }
    }
  }

  String _getBatchName(String? batchId) {
    if (batchId == null || batchId.isEmpty) return 'No Batch';
    try {
      final batch = _batches.where((b) => b.id == batchId).firstOrNull;
      return batch?.name ?? 'Unknown Batch';
    } catch (e) {
      print('Error getting batch name for ID $batchId: $e');
      return 'Unknown Batch';
    }
  }

  String _getDepartmentName(String? departmentId) {
    if (departmentId == null || departmentId.isEmpty) {
      return AppConstants.singleDepartmentName;
    }
    try {
      final department = _departments.where((d) => d['id'].toString() == departmentId).firstOrNull;
      return department?['name'] ?? AppConstants.singleDepartmentName;
    } catch (e) {
      print('Error getting department name for ID $departmentId: $e');
      return AppConstants.singleDepartmentName;
    }
  }

  List<app_user.User> get _filteredStudents {
    return _students.where((student) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        if (!student.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !student.email.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
      }

      // Batch filter
      if (_selectedBatchFilter != null && _selectedBatchFilter!.isNotEmpty) {
        if (student.batchId != _selectedBatchFilter) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Future<void> _addSampleStudents() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sample Students'),
        content: const Text('This will create 10 sample students for Computer Science department. Continue?'),
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
        print('Using department ID for sample students: $departmentId');
        
        // Get or create CS batches
        String cs2024ABatchId = await _getOrCreateBatch('CS-2024-A');
        String cs2024BBatchId = await _getOrCreateBatch('CS-2024-B');
        String cs2023ABatchId = await _getOrCreateBatch('CS-2023-A');

        // Sample students for Computer Science
        final sampleStudents = [
          {'name': 'John Smith', 'email': 'john.smith@student.edu', 'studentId': 'CS2024001', 'batchId': cs2024ABatchId},
          {'name': 'Emma Wilson', 'email': 'emma.wilson@student.edu', 'studentId': 'CS2024002', 'batchId': cs2024ABatchId},
          {'name': 'Alex Johnson', 'email': 'alex.johnson@student.edu', 'studentId': 'CS2024003', 'batchId': cs2024ABatchId},
          {'name': 'Sarah Davis', 'email': 'sarah.davis@student.edu', 'studentId': 'CS2024004', 'batchId': cs2024BBatchId},
          {'name': 'Michael Brown', 'email': 'michael.brown@student.edu', 'studentId': 'CS2024005', 'batchId': cs2024BBatchId},
          {'name': 'Lisa Garcia', 'email': 'lisa.garcia@student.edu', 'studentId': 'CS2024006', 'batchId': cs2024BBatchId},
          {'name': 'David Miller', 'email': 'david.miller@student.edu', 'studentId': 'CS2023001', 'batchId': cs2023ABatchId},
          {'name': 'Jennifer Taylor', 'email': 'jennifer.taylor@student.edu', 'studentId': 'CS2023002', 'batchId': cs2023ABatchId},
          {'name': 'Robert Anderson', 'email': 'robert.anderson@student.edu', 'studentId': 'CS2023003', 'batchId': cs2023ABatchId},
          {'name': 'Amanda White', 'email': 'amanda.white@student.edu', 'studentId': 'CS2024007', 'batchId': cs2024ABatchId},
        ];

        for (final student in sampleStudents) {
          try {
            print('Creating sample student: ${student['name']}');
            
            // Create authentication user first
            final authResponse = await SupabaseService().client.auth.signUp(
              email: student['email']!,
              password: 'password123', // Default password
            );

            if (authResponse.user != null) {
              print('Auth user created for ${student['name']}: ${authResponse.user!.id}');
              print('Email confirmation status: ${authResponse.user!.emailConfirmedAt}');
              
              // Then add user to database
              final userData = {
                'id': authResponse.user!.id,
                'name': student['name'],
                'email': student['email'],
                'role': AppConstants.roleStudent,
                'batch_id': student['batchId'],
                'department_id': departmentId,
                'created_at': DateTime.now().toIso8601String(),
                'updated_at': DateTime.now().toIso8601String(),
              };
              
              // Try to add student_id if the column exists
              try {
                userData['student_id'] = student['studentId'];
              } catch (e) {
                print('Warning: student_id column may not exist in database');
                print('Student ID will be stored in name field as: ${student['name']} (${student['studentId']})');
                // Store student ID in name field as fallback
                userData['name'] = '${student['name']} (${student['studentId']})';
              }
              
              final userResponse = await SupabaseService().client
                  .from(AppConstants.tableUsers)
                  .insert(userData)
                  .select();
              
              print('User added to database: $userResponse');
            } else {
              print('Failed to create auth user for ${student['name']}');
            }
          } catch (studentError) {
            print('Error creating student ${student['name']}: $studentError');
            // Continue with other students even if one fails
          }
        }

        await _loadStudents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('10 sample students created successfully! Default password: password123'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error creating sample students: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating sample students: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<String> _getOrCreateBatch(String batchName) async {
    try {
      // First try to find the batch by name
      final existingBatch = await SupabaseService().client
          .from(AppConstants.tableBatches)
          .select()
          .eq('name', batchName);
      
      if (existingBatch.isNotEmpty) {
        print('Found existing batch: ${existingBatch[0]}');
        return existingBatch[0]['id'] as String;
      }
      
      // Get or create department ID
      final departmentId = await _getOrCreateDepartmentId();
      
      // Batch doesn't exist, create it
      print('Creating new batch: $batchName');
      final newBatch = await SupabaseService().client
          .from(AppConstants.tableBatches)
          .insert({
            'name': batchName,
            'department_id': departmentId,
          })
          .select();
      
      print('Batch created: ${newBatch[0]}');
      return newBatch[0]['id'] as String;
    } catch (e) {
      print('Error in _getOrCreateBatch: $e');
      // If it's a duplicate key error, try to find the existing batch
      if (e.toString().contains('duplicate key') || e.toString().contains('unique constraint')) {
        print('Duplicate key error, trying to find existing batch...');
        try {
          final existingBatch = await SupabaseService().client
              .from(AppConstants.tableBatches)
              .select()
              .eq('name', batchName);
          
          if (existingBatch.isNotEmpty) {
            print('Found existing batch after duplicate key error: ${existingBatch[0]}');
            return existingBatch[0]['id'] as String;
          }
        } catch (findError) {
          print('Error finding existing batch: $findError');
        }
      }
      // Re-throw other errors
      rethrow;
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

  Future<void> _checkDatabaseSchema() async {
    try {
      print('=== CHECKING DATABASE SCHEMA ===');
      
      // Check users table structure by trying to select all columns
      print('Checking users table columns...');
      final usersData = await SupabaseService().client
          .from(AppConstants.tableUsers)
          .select('*')
          .limit(1);
      
      if (usersData.isNotEmpty) {
        print('Users table columns: ${usersData[0].keys.toList()}');
        
        // Check if student_id column exists
        final hasStudentId = usersData[0].containsKey('student_id');
        print('Has student_id column: $hasStudentId');
        
        // Check if student_id column exists with different casing
        final hasStudentIdAlt = usersData[0].containsKey('studentId') || 
                               usersData[0].containsKey('student-id') ||
                               usersData[0].containsKey('studentid');
        print('Has alternative student ID column: $hasStudentIdAlt');
        
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Database Schema Check'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Users table columns:'),
                    ...usersData[0].keys.map((key) => Text('  - $key')),
                    const SizedBox(height: 16),
                    Text('Has student_id column: $hasStudentId'),
                    Text('Has alternative student ID column: $hasStudentIdAlt'),
                    const SizedBox(height: 16),
                    if (!hasStudentId && !hasStudentIdAlt)
                      const Text(
                        '⚠️ student_id column is missing! You need to add this column to your users table.',
                        style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                      ),
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
      } else {
        print('Users table is empty or not accessible');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Users table is empty or not accessible'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error checking database schema: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error checking schema: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _checkDatabaseStructure() async {
    try {
      print('=== CHECKING DATABASE STRUCTURE ===');
      
      // Check if users table exists and has correct columns
      print('Checking users table structure...');
      final usersTable = await SupabaseService().client
          .from(AppConstants.tableUsers)
          .select('*')
          .limit(1);
      print('Users table accessible: ${usersTable.isNotEmpty}');
      
      // Check if we can insert a test record
      print('Testing user insertion...');
      final testData = {
        'id': 'test-user-${DateTime.now().millisecondsSinceEpoch}',
        'name': 'Test User',
        'email': 'test@test.com',
        'student_id': 'TEST001',
        'role': AppConstants.roleStudent,
        'batch_id': null,
        'department_id': null,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };
      
      final testInsert = await SupabaseService().client
          .from(AppConstants.tableUsers)
          .insert(testData)
          .select();
      print('Test insert successful: $testInsert');
      
      // Clean up test data
      await SupabaseService().client
          .from(AppConstants.tableUsers)
          .delete()
          .eq('id', testData['id'] as Object);
      print('Test data cleaned up');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Database structure check completed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('Database structure check failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Database structure issue: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _debugDatabase() async {
    try {
      print('=== DEBUG DATABASE ===');
      
      // Check departments
      print('Checking departments...');
      final departments = await SupabaseService().client
          .from(AppConstants.tableDepartments)
          .select();
      print('All departments: $departments');
      
      // Check batches
      print('Checking batches...');
      final batches = await SupabaseService().client
          .from(AppConstants.tableBatches)
          .select();
      print('All batches: $batches');
      
      // Check users
      print('Checking students...');
      final students = await SupabaseService().client
          .from(AppConstants.tableUsers)
          .select()
          .eq('role', AppConstants.roleStudent);
      print('All students: $students');
      
      // Show results in a dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Database Debug Info'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Departments (${departments.length}):'),
                  ...departments.map((d) => Text('  - ${d['name']} (ID: ${d['id']})')),
                  const SizedBox(height: 16),
                  Text('Batches (${batches.length}):'),
                  ...batches.map((b) => Text('  - ${b['name']} (Dept: ${b['department_id']})')),
                  const SizedBox(height: 16),
                  Text('Students (${students.length}):'),
                  ...students.map((s) => Text('  - ${s['name']} (Batch: ${s['batch_id']})')),
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
    } catch (e) {
      print('Error in debug: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Debug error: $e')),
        );
      }
    }
  }

  Future<void> _fixSpecificUserEmail() async {
    try {
      print('=== FIXING SPECIFIC USER EMAIL ===');
      
      final email = 'aliraza@gmail.com';
      print('Checking email confirmation for: $email');
      
      // First check if user exists in database
      final users = await SupabaseService().getUsers();
      final user = users.where((u) => u['email'] == email).firstOrNull;
      
      if (user == null) {
        print('User not found in database: $email');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User $email not found in database')),
          );
        }
        return;
      }
      
      print('User found in database: ${user['name']} (${user['role']})');
      
      // Try to sign in to check confirmation status
      try {
        final authResponse = await SupabaseService().client.auth.signInWithPassword(
          email: email,
          password: 'password123', // Try default password
        );
        
        if (authResponse.user != null) {
          print('Auth user found: ${authResponse.user!.id}');
          print('Email confirmed: ${authResponse.user!.emailConfirmedAt}');
          
          if (authResponse.user!.emailConfirmedAt == null) {
            print('Email not confirmed for: $email');
            if (mounted) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Email Not Confirmed'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('User: aliraza@gmail.com'),
                      Text('Status: Email not confirmed'),
                      const SizedBox(height: 16),
                      const Text(
                        'To fix this:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('1. Go to Supabase Dashboard'),
                      const Text('2. Navigate to Authentication > Users'),
                      const Text('3. Find user: aliraza@gmail.com'),
                      const Text('4. Set "Email confirmed" to true'),
                      const SizedBox(height: 8),
                      const Text(
                        'OR',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('1. Go to Authentication > Settings'),
                      const Text('2. Disable "Enable email confirmations"'),
                    ],
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
          } else {
            print('Email already confirmed for: $email');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Email already confirmed for $email'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          }
        }
        
        // Sign out after checking
        await SupabaseService().client.auth.signOut();
        
      } catch (authError) {
        print('Auth error for $email: $authError');
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Authentication Error'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('User: aliraza@gmail.com'),
                  Text('Error: $authError'),
                  const SizedBox(height: 16),
                  const Text(
                    'Possible issues:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('• Wrong password'),
                  const Text('• User not in auth system'),
                  const Text('• Email not confirmed'),
                  const SizedBox(height: 16),
                  const Text(
                    'Solutions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('1. Check password'),
                  const Text('2. Recreate user account'),
                  const Text('3. Disable email confirmation'),
                ],
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
      }
      
    } catch (e) {
      print('Error fixing specific user email: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _confirmAllUserEmails() async {
    try {
      print('=== CONFIRMING ALL USER EMAILS ===');
      
      // Get all users from database
      final users = await SupabaseService().getUsers();
      print('Found ${users.length} users in database');
      
      int confirmedCount = 0;
      int errorCount = 0;
      
      for (final user in users) {
        try {
          final email = user['email'];
          print('Checking email confirmation for: $email');
          
          // Try to sign in to check confirmation status
          final authResponse = await SupabaseService().client.auth.signInWithPassword(
            email: email,
            password: 'password123', // Default password for sample users
          );
          
          if (authResponse.user != null) {
            if (authResponse.user!.emailConfirmedAt == null) {
              print('Email not confirmed for: $email');
              // For now, we'll just log this - in production you'd want to send confirmation emails
              errorCount++;
            } else {
              print('Email already confirmed for: $email');
              confirmedCount++;
            }
          }
          
          // Sign out after checking
          await SupabaseService().client.auth.signOut();
          
        } catch (userError) {
          print('Error checking user ${user['email']}: $userError');
          errorCount++;
        }
      }
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Email Confirmation Check'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Total users checked: ${users.length}'),
                Text('Emails confirmed: $confirmedCount'),
                Text('Emails not confirmed: $errorCount'),
                const SizedBox(height: 16),
                const Text(
                  'To fix email confirmation issues:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text('1. Go to Supabase Dashboard'),
                const Text('2. Navigate to Authentication > Settings'),
                const Text('3. Disable "Enable email confirmations"'),
                const Text('4. Or manually confirm emails in the Users section'),
              ],
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
    } catch (e) {
      print('Error confirming emails: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error checking emails: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Management'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.email),
            onPressed: _fixSpecificUserEmail,
            tooltip: 'Check Email Confirmations',
          ),
          IconButton(
            icon: const Icon(Icons.schema),
            onPressed: _checkDatabaseSchema,
            tooltip: 'Check Database Schema',
          ),
          IconButton(
            icon: const Icon(Icons.construction),
            onPressed: _checkDatabaseStructure,
            tooltip: 'Check Database Structure',
          ),
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: _debugDatabase,
            tooltip: 'Debug Database',
          ),
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: _addSampleStudents,
            tooltip: 'Add Sample Students',
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Search by name or email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedBatchFilter,
                  decoration: const InputDecoration(
                    labelText: 'Filter by Batch',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.class_),
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All Batches')),
                    ..._batches.map((b) => DropdownMenuItem(
                      value: b.id,
                      child: Text(b.name),
                    )).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedBatchFilter = value;
                    });
                  },
                ),
              ],
            ),
          ),
          // Students List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredStudents.isEmpty
                    ? const Center(
                        child: Text('No students found.'),
                      )
                    : ListView.builder(
                        itemCount: _filteredStudents.length,
                        itemBuilder: (context, index) {
                          final student = _filteredStudents[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 4.0,
                            ),
                            child: ListTile(
                              title: Text(student.name),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Email: ${student.email}'),
                                  if (student.studentId != null)
                                    Text('Student ID: ${student.studentId}'),
                                  Text('Batch: ${_getBatchName(student.batchId)}'),
                                  Text('Department: ${_getDepartmentName(student.departmentId)}'),
                                  Text('Created: ${student.createdAt.toString().split(' ')[0]}'),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () => _editStudent(student),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteStudent(student),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addStudent,
        backgroundColor: const Color(AppConstants.primaryColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 