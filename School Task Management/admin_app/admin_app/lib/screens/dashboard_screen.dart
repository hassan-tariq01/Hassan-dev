import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/student_provider.dart';
import 'student_management_screen.dart';
import 'task_management_screen.dart';
import 'performance_screen.dart';
import 'top_performers_screen.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:developer' as developer;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _exportReports(BuildContext context, List<Map<String, dynamic>> reports) async {
    try {
      // Check and request appropriate permission based on Android version
      bool permissionGranted = false;
      if (Platform.isAndroid) {
        // For Android 11+ (API 30+), use manageExternalStorage
        if (await Permission.manageExternalStorage.isGranted) {
          permissionGranted = true;
        } else if (await Permission.manageExternalStorage.request().isGranted) {
          permissionGranted = true;
        } else {
          // Fallback to storage permission for older Android versions
          if (await Permission.storage.isGranted) {
            permissionGranted = true;
          } else if (await Permission.storage.request().isGranted) {
            permissionGranted = true;
          }
        }
      } else {
        // Non-Android platforms (e.g., iOS) don't need explicit storage permission
        permissionGranted = true;
      }

      if (!permissionGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Storage permission denied. Please grant permission in settings.')),
        );
        developer.log('Storage permission denied');
        await openAppSettings(); // Prompt user to open settings
        return;
      }

      var excel = Excel.createExcel();
      Sheet sheet = excel['Task Completion Report'];

      // Headers
      sheet.appendRow([
        TextCellValue('Student ID'),
        TextCellValue('Completion Rate (%)'),
        TextCellValue('Completed Tasks'),
        TextCellValue('Total Tasks'),
      ]);

      // Data
      for (var report in reports) {
        sheet.appendRow([
          TextCellValue(report['student_id']?.toString() ?? ''),
          TextCellValue(report['completion_rate']?.toStringAsFixed(1) ?? '0.0'),
          TextCellValue(report['completed_tasks']?.toString() ?? '0'),
          TextCellValue(report['total_tasks']?.toString() ?? '0'),
        ]);
      }

      // Use temporary directory for file storage
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final path = '${directory.path}/task_completion_report_$timestamp.xlsx';
      File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(excel.encode()!);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report exported to $path')),
      );
      developer.log('Exported report to $path');
    } catch (e) {
      developer.log('Export report failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to export report: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final studentProvider = Provider.of<StudentProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Overview',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          const Icon(Icons.people, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Total Students: ${studentProvider.students.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.task, color: Colors.white, size: 24),
                          const SizedBox(width: 8),
                          Text(
                            'Total Tasks: ${taskProvider.tasks.length}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppConstants.primaryGradient,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Task Completion Reports',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            await studentProvider.fetchReports();
                            await _exportReports(context, studentProvider.reports.map((report) => report.toJson()).toList());
                          } catch (e) {
                            developer.log('Fetch reports failed: $e');
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ).copyWith(
                          foregroundColor: WidgetStateProperty.all(Colors.white),
                          backgroundColor: WidgetStateProperty.all(Colors.transparent),
                          overlayColor: WidgetStateProperty.all(Colors.white.withOpacity(0.2)),
                        ),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: AppConstants.primaryGradient,
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          child: const Text(
                            'Export Reports to Excel',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    children: [
                      _buildDashboardButton(
                        context,
                        'Manage Students',
                        Icons.people,
                        const StudentManagementScreen(),
                      ),
                      _buildDashboardButton(
                        context,
                        'Manage Tasks',
                        Icons.task,
                        const TaskManagementScreen(),
                      ),
                      _buildDashboardButton(
                        context,
                        'View Performance',
                        Icons.bar_chart,
                        const PerformanceScreen(),
                      ),
                      _buildDashboardButton(
                        context,
                        'Top Performers',
                        Icons.star,
                        const TopPerformersScreen(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardButton(
      BuildContext context, String title, IconData icon, Widget destination) {
    return GestureDetector(
      onTap: () {
        try {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => destination),
          );
          developer.log('Navigated to $title');
        } catch (e) {
          developer.log('$title navigation failed: $e');
        }
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: AppConstants.primaryGradient,
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}