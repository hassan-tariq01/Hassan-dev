import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:excel/excel.dart';
import '../providers/student_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:developer' as developer;

class StudentManagementScreen extends StatefulWidget {
  const StudentManagementScreen({super.key});

  @override
  _StudentManagementScreenState createState() => _StudentManagementScreenState();
}

class _StudentManagementScreenState extends State<StudentManagementScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isAdding = false;
  bool _isImporting = false;
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
    try {
      final studentProvider = Provider.of<StudentProvider>(context, listen: false);
      studentProvider.fetchStudents();
      developer.log('Fetching students on init');
    } catch (e) {
      developer.log('Fetch students on init failed: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addStudent(BuildContext context, StudentProvider studentProvider) async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (name.isEmpty || !emailRegex.hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Please enter a valid name and email (e.g., user@example.com)')),
      );
      return;
    }
    setState(() {
      _isAdding = true;
    });
    try {
      await studentProvider.addStudent(name, email);
      _nameController.clear();
      _emailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Student added successfully')),
      );
      developer.log('Added student via UI: $name, $email');
    } catch (e) {
      developer.log('Add student failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to add student: $e')),
      );
    } finally {
      setState(() {
        _isAdding = false;
      });
    }
  }

  Future<void> _editStudent(BuildContext context, StudentProvider studentProvider,
      String id, String currentName, String currentEmail) async {
    _nameController.text = currentName;
    _emailController.text = currentEmail;
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Student'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final name = _nameController.text.trim();
              final email = _emailController.text.trim();
              final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
              if (name.isEmpty || !emailRegex.hasMatch(email)) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter a valid name and email')),
                );
                return;
              }
              try {
                await studentProvider.updateStudent(id, name, email);
                _nameController.clear();
                _emailController.clear();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Student updated successfully')),
                );
                developer.log('Updated student: $id');
              } catch (e) {
                developer.log('Update student failed: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update student: $e')),
                );
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<bool> _checkPermission() async {
    if (!Platform.isAndroid) return true;

    final deviceInfo = DeviceInfoPlugin();
    final androidInfo = await deviceInfo.androidInfo;
    final sdkInt = androidInfo.version.sdkInt ?? 0;

    Permission permission;
    if (sdkInt >= 33) {
      // Android 13+ (API 33+)
      permission = Permission.photos;
    } else {
      // Android 12 and below
      permission = Permission.storage;
    }

    bool permissionGranted = await permission.isGranted;
    if (!permissionGranted) {
      permissionGranted = await permission.request().isGranted;
    }

    // Fallback to manageExternalStorage for broader access if needed
    if (!permissionGranted) {
      permissionGranted = await Permission.manageExternalStorage.isGranted;
      if (!permissionGranted) {
        permissionGranted = await Permission.manageExternalStorage.request().isGranted;
      }
    }

    return permissionGranted;
  }

  Future<void> _importStudentsFromExcel(
      BuildContext context, StudentProvider studentProvider) async {
    setState(() {
      _isImporting = true;
    });
    try {
      bool permissionGranted = await _checkPermission();
      if (!permissionGranted) {
        final retry = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Permission Required'),
            content: const Text(
                'Storage access is needed to import Excel files. Please grant permission in settings.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await openAppSettings();
                  Navigator.pop(context, true);
                },
                child: const Text('Open Settings'),
              ),
            ],
          ),
        );

        if (retry == true) {
          permissionGranted = await _checkPermission();
          if (!permissionGranted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Storage permission denied')),
            );
            return;
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Storage permission denied')),
          );
          return;
        }
      }

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx', 'xls'],
      );
      if (result == null || result.files.single.path == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No file selected')),
        );
        return;
      }

      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);
      final sheet = excel.tables.keys.first;
      final rows = excel.tables[sheet]?.rows ?? [];

      int importedCount = 0;
      for (var row in rows.skip(1)) {
        final name = row[0]?.value?.toString();
        final email = row[1]?.value?.toString();
        if (name != null &&
            email != null &&
            RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          try {
            await studentProvider.addStudent(name, email);
            importedCount++;
          } catch (e) {
            developer.log('Failed to import student $email: $e');
          }
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Imported $importedCount students successfully')),
      );
      developer.log('Imported $importedCount students from Excel');
    } catch (e) {
      developer.log('Import students failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to import students: $e')),
      );
    } finally {
      setState(() {
        _isImporting = false;
      });
    }
  }

  Future<void> _exportStudents(
      BuildContext context, StudentProvider studentProvider) async {
    setState(() {
      _isExporting = true;
    });
    try {
      bool permissionGranted = false;
      if (Platform.isAndroid) {
        if (await Permission.manageExternalStorage.isGranted ||
            await Permission.manageExternalStorage.request().isGranted) {
          permissionGranted = true;
        } else if (await Permission.storage.isGranted ||
            await Permission.storage.request().isGranted) {
          permissionGranted = true;
        }
      } else {
        permissionGranted = true;
      }
      if (!permissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
              Text('Storage permission denied. Please grant permission in settings.')),
        );
        await openAppSettings();
        return;
      }

      final excel = Excel.createExcel();
      final sheet = excel['Students'];

      sheet.appendRow([
         TextCellValue('ID'),
         TextCellValue('Name'),
         TextCellValue('Email'),
         TextCellValue('Role'),
      ]);

      for (final student in studentProvider.students) {
        sheet.appendRow([
          TextCellValue(student.id),
          TextCellValue(student.name),
          TextCellValue(student.email),
          TextCellValue(student.role),
        ]);
      }

      final directory = await getTemporaryDirectory();
      final timestamp =
      DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final path = '${directory.path}/students_export_$timestamp.xlsx';
      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Students exported to $path')),
      );
      developer.log('Exported students to $path');
    } catch (e) {
      developer.log('Export students failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export students: $e')),
      );
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Students'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: AppConstants.primaryGradient,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.cardGradient,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16.0),
                margin: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Student Name',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Student Email',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isAdding ? null : () => _addStudent(context, studentProvider),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ).copyWith(
                              foregroundColor: WidgetStateProperty.all(Colors.white),
                              backgroundColor: WidgetStateProperty.all(Colors.transparent),
                              overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppConstants.primaryGradient,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: _isAdding
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Add Student',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isImporting
                                ? null
                                : () => _importStudentsFromExcel(context, studentProvider),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ).copyWith(
                              foregroundColor: WidgetStateProperty.all(Colors.white),
                              backgroundColor: WidgetStateProperty.all(Colors.transparent),
                              overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                gradient: AppConstants.primaryGradient,
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              child: _isImporting
                                  ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                                  : const Text(
                                'Import from Excel',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed:
                      _isExporting ? null : () => _exportStudents(context, studentProvider),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ).copyWith(
                        foregroundColor: WidgetStateProperty.all(Colors.white),
                        backgroundColor: WidgetStateProperty.all(Colors.transparent),
                        overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
                      ),
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: AppConstants.primaryGradient,
                          borderRadius: BorderRadius.all(Radius.circular(8)),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: _isExporting
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text(
                          'Export Students to Excel',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: studentProvider.students.isEmpty
                    ? const Center(
                  child: Text(
                    'No students available',
                    style: AppConstants.headingStyle,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.all(8.0),
                  itemCount: studentProvider.students.length,
                  itemBuilder: (context, index) {
                    final student = studentProvider.students[index];
                    return Card(
                      margin: Dareiosymmetric(vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppConstants.cardGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            student.name,
                            style: AppConstants.headingStyle.copyWith(fontSize: 18),
                          ),
                          subtitle: Text(
                            student.email,
                            style: AppConstants.subheadingStyle,
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                onPressed: () => _editStudent(
                                    context,
                                    studentProvider,
                                    student.id,
                                    student.name,
                                    student.email),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  try {
                                    await studentProvider.deleteStudent(student.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Student and tasks deleted')),
                                    );
                                    developer.log(
                                        'Deleted student and tasks: ${student.id}');
                                  } catch (e) {
                                    developer.log('Delete student failed: $e');
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                          Text('Failed to delete student: $e')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Dareiosymmetric({required int vertical}) {
}