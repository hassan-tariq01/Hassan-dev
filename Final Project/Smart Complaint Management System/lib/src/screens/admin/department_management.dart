import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/department.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/routes.dart';

class DepartmentManagement extends StatefulWidget {
  const DepartmentManagement({Key? key}) : super(key: key);

  @override
  State<DepartmentManagement> createState() => _DepartmentManagementState();
}

class _DepartmentManagementState extends State<DepartmentManagement> {
  List<Department> _departments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final data = await SupabaseService().getDepartments();
      setState(() {
        _departments = data.map((json) => Department.fromJson(json)).toList();
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading departments: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _addDepartment() async {
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Department'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Department Name',
              border: OutlineInputBorder(),
            ),
            validator: Validators.validateDepartmentName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, nameController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result != null) {
      try {
        await SupabaseService().client.from(AppConstants.tableDepartments).insert({
          'name': result,
        });
        _loadDepartments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Department added successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding department: $e')),
        );
      }
    }
  }

  Future<void> _editDepartment(Department department) async {
    final nameController = TextEditingController(text: department.name);
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Department'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: nameController,
            decoration: const InputDecoration(
              labelText: 'Department Name',
              border: OutlineInputBorder(),
            ),
            validator: Validators.validateDepartmentName,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, nameController.text.trim());
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
            .from(AppConstants.tableDepartments)
            .update({'name': result})
            .eq('id', department.id);
        _loadDepartments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Department updated successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating department: $e')),
        );
      }
    }
  }

  Future<void> _deleteDepartment(Department department) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Department'),
        content: Text('Are you sure you want to delete "${department.name}"?'),
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
            .from(AppConstants.tableDepartments)
            .delete()
            .eq('id', department.id);
        _loadDepartments();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Department deleted successfully')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting department: $e')),
        );
      }
    }
  }

  Future<void> _addComputerScienceDepartment() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Computer Science Department'),
        content: const Text('This will create the Computer Science department if it doesn\'t exist. Continue?'),
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
        // Check if department already exists
        final existingDept = await SupabaseService().client
            .from(AppConstants.tableDepartments)
            .select()
            .eq('id', AppConstants.singleDepartmentId)
            .single();

        if (existingDept != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Computer Science department already exists!')),
          );
        }
      } catch (e) {
        // Department doesn't exist, create it
        try {
          await SupabaseService().client.from(AppConstants.tableDepartments).insert({
            'id': AppConstants.singleDepartmentId,
            'name': AppConstants.singleDepartmentName,
          });
          
          _loadDepartments();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Computer Science department created successfully!')),
          );
        } catch (insertError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating department: $insertError')),
          );
        }
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Department Management'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.computer),
            onPressed: _addComputerScienceDepartment,
            tooltip: 'Add Computer Science Department',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _departments.isEmpty
              ? const Center(
                  child: Text('No departments found. Add one to get started.'),
                )
              : ListView.builder(
                  itemCount: _departments.length,
                  itemBuilder: (context, index) {
                    final department = _departments[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 4.0,
                      ),
                      child: ListTile(
                        title: Text(department.name),
                        subtitle: Text('Created: ${department.createdAt.toString().split(' ')[0]}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => _editDepartment(department),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteDepartment(department),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addDepartment,
        backgroundColor: const Color(AppConstants.primaryColor),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
} 