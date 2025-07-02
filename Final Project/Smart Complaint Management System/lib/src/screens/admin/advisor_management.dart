import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/user.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/routes.dart';
import '../../utils/validators.dart';

class AdvisorManagement extends StatefulWidget {
  const AdvisorManagement({Key? key}) : super(key: key);

  @override
  State<AdvisorManagement> createState() => _AdvisorManagementState();
}

class _AdvisorManagementState extends State<AdvisorManagement> {
  List<User> _advisors = [];
  List<Map<String, dynamic>> _departments = [];
  bool _isLoading = true;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _loadAdvisors();
  }

  Future<void> _loadAdvisors() async {
    setState(() => _isLoading = true);
    try {
      final advisorsData = await SupabaseService().getUsers(role: AppConstants.roleBatchAdvisor);
      final departmentsData = await SupabaseService().getDepartments();
      
      setState(() {
        _advisors = advisorsData.map((a) => User.fromJson(a)).toList();
        _departments = departmentsData;
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error loading advisors: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addAdvisor() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.person_add, color: const Color(AppConstants.primaryColor)),
            const SizedBox(width: 8),
            const Text('Add New Advisor'),
          ],
        ),
        content: SingleChildScrollView(
          child: Form(
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
                    labelText: 'Full Name',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    hintText: 'Enter advisor\'s full name',
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
                      Icons.person,
                      color: Color(AppConstants.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: Validators.validateName,
                  autofocus: true,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    hintText: 'Enter advisor\'s email address',
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
                      Icons.email,
                      color: Color(AppConstants.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  validator: Validators.validateEmail,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: passwordController,
                  obscureText: true,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    hintText: 'Enter password (min 6 characters)',
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
                      Icons.lock,
                      color: Color(AppConstants.primaryColor),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    helperText: 'Minimum 6 characters required',
                    helperStyle: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                    ),
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
                  'email': emailController.text.trim(),
                  'password': passwordController.text,
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryColor),
              foregroundColor: Colors.white,
            ),
            child: const Text(
              'Add Advisor',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    if (result != null) {
      setState(() => _isLoading = true);
      try {
        print('Adding advisor: ${result['name']} with email: ${result['email']}');
        
        // First create authentication user
        final authResponse = await SupabaseService().client.auth.signUp(
          email: result['email']!,
          password: result['password']!,
        );

        if (authResponse.user != null) {
          print('Auth user created: ${authResponse.user!.id}');
          
          // Get or create department ID
          final departmentId = await _getOrCreateDepartmentId();
          print('Using department ID: $departmentId');
          
          // Then add user to database with Computer Science department
          final userResponse = await SupabaseService().client.from(AppConstants.tableUsers).insert({
            'id': authResponse.user!.id,
            'name': result['name'],
            'email': result['email'],
            'role': AppConstants.roleBatchAdvisor,
            'department_id': departmentId,
          }).select();
          
          print('User added to database: $userResponse');

          await _loadAdvisors();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Advisor "${result['name']}" added successfully! They can now login with their email and password.'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          throw Exception('Failed to create authentication user');
        }
      } catch (e) {
        print('Error adding advisor: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error adding advisor: $e'),
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

  Future<void> _editAdvisor(User advisor) async {
    final nameController = TextEditingController(text: advisor.name);
    final emailController = TextEditingController(text: advisor.email);
    final formKey = GlobalKey<FormState>();
    String? selectedDepartmentId = advisor.departmentId;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Advisor'),
        content: Form(
          key: formKey,
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
                  selectedDepartmentId = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a department';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate() && selectedDepartmentId != null) {
                Navigator.pop(context, {
                  'name': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'departmentId': selectedDepartmentId!,
                });
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await SupabaseService().client
            .from(AppConstants.tableUsers)
            .update({
              'name': result['name'],
              'email': result['email'],
              'department_id': result['departmentId'],
            })
            .eq('id', advisor.id);
        _loadAdvisors();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advisor updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating advisor: $e')),
        );
      }
    }
  }

  Future<void> _deleteAdvisor(User advisor) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Advisor'),
        content: Text('Are you sure you want to delete "${advisor.name}"? This action cannot be undone.'),
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
            .eq('id', advisor.id);
        _loadAdvisors();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Advisor deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting advisor: $e')),
        );
      }
    }
  }

  String _getDepartmentName(String? departmentId) {
    return AppConstants.singleDepartmentName;
  }

  Future<void> _addSampleAdvisors() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Sample Advisors'),
        content: const Text('This will create 8 sample advisors for Computer Science department. Continue?'),
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
        print('Using department ID for sample advisors: $departmentId');
        
        // Sample advisors for Computer Science
        final sampleAdvisors = [
          {'name': 'Dr. Sarah Johnson', 'email': 'sarah.johnson@university.edu'},
          {'name': 'Prof. Michael Chen', 'email': 'michael.chen@university.edu'},
          {'name': 'Dr. Emily Davis', 'email': 'emily.davis@university.edu'},
          {'name': 'Prof. Robert Wilson', 'email': 'robert.wilson@university.edu'},
          {'name': 'Dr. Lisa Brown', 'email': 'lisa.brown@university.edu'},
          {'name': 'Prof. David Miller', 'email': 'david.miller@university.edu'},
          {'name': 'Dr. James Taylor', 'email': 'james.taylor@university.edu'},
          {'name': 'Prof. Amanda Garcia', 'email': 'amanda.garcia@university.edu'},
        ];

        for (final advisor in sampleAdvisors) {
          try {
            print('Creating sample advisor: ${advisor['name']}');
            
            // Create authentication user first
            final authResponse = await SupabaseService().client.auth.signUp(
              email: advisor['email']!,
              password: 'password123', // Default password
            );

            if (authResponse.user != null) {
              print('Auth user created for ${advisor['name']}: ${authResponse.user!.id}');
              
              // Then add user to database
              final userResponse = await SupabaseService().client.from(AppConstants.tableUsers).insert({
                'id': authResponse.user!.id,
                'name': advisor['name'],
                'email': advisor['email'],
                'role': AppConstants.roleBatchAdvisor,
                'department_id': departmentId,
              }).select();
              
              print('User added to database: $userResponse');
            } else {
              print('Failed to create auth user for ${advisor['name']}');
            }
          } catch (advisorError) {
            print('Error creating advisor ${advisor['name']}: $advisorError');
            // Continue with other advisors even if one fails
          }
        }

        await _loadAdvisors();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('8 sample advisors created successfully! Default password: password123'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        print('Error creating sample advisors: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error creating sample advisors: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isLoading = false);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advisor Management'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _addSampleAdvisors,
            tooltip: 'Add Sample Advisors',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _advisors.isEmpty
              ? const Center(
                  child: Text('No advisors found. Add one to get started.'),
                )
              : ListView.builder(
                  itemCount: _advisors.length,
                  itemBuilder: (context, index) {
                    final advisor = _advisors[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        title: Text(advisor.name),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Email: ${advisor.email}'),
                            Text('Department: ${_getDepartmentName(advisor.departmentId)}'),
                            Text('Created: ${advisor.createdAt.toString().split(' ')[0]}'),
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editAdvisor(advisor),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAdvisor(advisor),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addAdvisor,
        backgroundColor: const Color(AppConstants.primaryColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 