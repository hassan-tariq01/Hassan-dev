import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_service.dart';
import '../../services/supabase_service.dart';
import '../../utils/constants.dart';
import '../../utils/validators.dart';
import '../../utils/routes.dart';

class HODManagement extends StatefulWidget {
  const HODManagement({Key? key}) : super(key: key);

  @override
  State<HODManagement> createState() => _HODManagementState();
}

class _HODManagementState extends State<HODManagement> {
  List<Map<String, dynamic>> _hods = [];
  bool _isLoading = true;
  String? _resultMessage;

  @override
  void initState() {
    super.initState();
    _loadHODs();
  }

  Future<void> _loadHODs() async {
    setState(() => _isLoading = true);
    try {
      final hods = await SupabaseService().getUsers(role: AppConstants.roleHOD);
      setState(() {
        _hods = hods;
      });
    } catch (e) {
      setState(() {
        _resultMessage = 'Error loading HODs: $e';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _addHOD() async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create HOD Account'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateName,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validateEmail,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                validator: Validators.validatePassword,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(context, true);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    if (result == true) {
      try {
        // Create user in Supabase Auth
        final authRes = await AuthService().signUp(
          emailController.text.trim(),
          passwordController.text.trim(),
        );
        final userId = authRes.user?.id;
        if (userId == null) throw 'Failed to create user in Auth.';
        // Insert user in users table
        await SupabaseService().client.from(AppConstants.tableUsers).insert({
          'id': userId,
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'role': AppConstants.roleHOD,
        });
        _loadHODs();
        setState(() {
          _resultMessage = 'HOD account created successfully!';
        });
      } catch (e) {
        setState(() {
          _resultMessage = 'Error creating HOD: $e';
        });
      }
    }
  }

  Future<void> _deleteHOD(String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete HOD'),
        content: const Text('Are you sure you want to delete this HOD account?'),
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
            .eq('id', userId);
        _loadHODs();
        setState(() {
          _resultMessage = 'HOD deleted successfully!';
        });
      } catch (e) {
        setState(() {
          _resultMessage = 'Error deleting HOD: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HOD Management'),
        backgroundColor: const Color(AppConstants.primaryColor),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.adminDashboard),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Create and Manage HOD Accounts',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _addHOD,
                    icon: const Icon(Icons.add),
                    label: const Text('Create HOD Account'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(AppConstants.primaryColor),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: _hods.isEmpty
                        ? const Center(child: Text('No HOD accounts found.'))
                        : ListView.builder(
                            itemCount: _hods.length,
                            itemBuilder: (context, index) {
                              final hod = _hods[index];
                              return Card(
                                child: ListTile(
                                  title: Text(hod['name'] ?? ''),
                                  subtitle: Text(hod['email'] ?? ''),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteHOD(hod['id']),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_resultMessage != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _resultMessage!,
                      style: TextStyle(
                        color: _resultMessage!.startsWith('Error') ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
} 