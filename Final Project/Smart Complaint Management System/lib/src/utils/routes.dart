import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import '../auth/login_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/department_management.dart';
import '../screens/admin/batch_management.dart';
import '../screens/admin/advisor_management.dart';
import '../screens/admin/student_management.dart';
import '../screens/admin/batch_upload.dart';
import '../screens/admin/advisor_assignment.dart';
import '../screens/admin/hod_management.dart';
import '../screens/admin/stats_dashboard.dart';
import '../screens/advisor/advisor_dashboard.dart';
import '../screens/advisor/complaint_list.dart';
import '../screens/advisor/complaint_detail.dart';
import '../screens/hod/hod_dashboard.dart';
import '../screens/hod/escalated_complaint_list.dart';
import '../screens/student/student_dashboard.dart';
import '../screens/student/complaint_submission.dart';
import '../screens/student/complaint_history.dart';
import '../screens/student/complaint_status.dart';

class AppRoutes {
  // Route names
  static const String login = '/login';
  static const String adminDashboard = '/admin/dashboard';
  static const String departmentManagement = '/admin/departments';
  static const String batchManagement = '/admin/batches';
  static const String advisorManagement = '/admin/advisors';
  static const String studentManagement = '/admin/students';
  static const String batchUpload = '/admin/batch-upload';
  static const String advisorAssignment = '/admin/advisor-assignment';
  static const String hodManagement = '/admin/hod-management';
  static const String statsDashboard = '/admin/stats';
  static const String advisorDashboard = '/advisor/dashboard';
  static const String advisorComplaintList = '/advisor/complaints';
  static const String advisorComplaintDetail = '/advisor/complaint-detail';
  static const String hodDashboard = '/hod/dashboard';
  static const String hodComplaintList = '/hod/complaints';
  static const String hodComplaintDetail = '/hod/complaint-detail';
  static const String studentDashboard = '/student/dashboard';
  static const String complaintSubmission = '/student/submit-complaint';
  static const String complaintHistory = '/student/complaint-history';
  static const String complaintStatus = '/student/complaint-status';

  static GoRouter get router => GoRouter(
    initialLocation: login,
    routes: [
      // Auth Routes
      GoRoute(
        path: login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Admin Routes
      GoRoute(
        path: adminDashboard,
        name: 'adminDashboard',
        builder: (context, state) => const AdminDashboard(),
      ),
      GoRoute(
        path: departmentManagement,
        name: 'departmentManagement',
        builder: (context, state) => const DepartmentManagement(),
      ),
      GoRoute(
        path: batchManagement,
        name: 'batchManagement',
        builder: (context, state) => const BatchManagement(),
      ),
      GoRoute(
        path: advisorManagement,
        name: 'advisorManagement',
        builder: (context, state) => const AdvisorManagement(),
      ),
      GoRoute(
        path: studentManagement,
        name: 'studentManagement',
        builder: (context, state) => const StudentManagement(),
      ),
      GoRoute(
        path: batchUpload,
        name: 'batchUpload',
        builder: (context, state) => const BatchUpload(),
      ),
      GoRoute(
        path: advisorAssignment,
        name: 'advisorAssignment',
        builder: (context, state) => const AdvisorAssignment(),
      ),
      GoRoute(
        path: hodManagement,
        name: 'hodManagement',
        builder: (context, state) => const HODManagement(),
      ),
      GoRoute(
        path: statsDashboard,
        name: 'statsDashboard',
        builder: (context, state) => const StatsDashboard(),
      ),

      // Advisor Routes
      GoRoute(
        path: advisorDashboard,
        name: 'advisorDashboard',
        builder: (context, state) => const AdvisorDashboard(),
      ),
      GoRoute(
        path: advisorComplaintList,
        name: 'advisorComplaintList',
        builder: (context, state) => const ComplaintList(),
      ),
      GoRoute(
        path: '$advisorComplaintDetail/:complaintId',
        name: 'advisorComplaintDetail',
        builder: (context, state) {
          final complaintId = state.pathParameters['complaintId']!;
          return ComplaintDetail(complaintId: complaintId);
        },
      ),

      // HOD Routes
      GoRoute(
        path: hodDashboard,
        name: 'hodDashboard',
        builder: (context, state) => const HODDashboard(),
      ),
      GoRoute(
        path: hodComplaintList,
        name: 'hodComplaintList',
        builder: (context, state) => const EscalatedComplaintList(),
      ),
      GoRoute(
        path: '$hodComplaintDetail/:complaintId',
        name: 'hodComplaintDetail',
        builder: (context, state) {
          final complaintId = state.pathParameters['complaintId']!;
          return ComplaintDetail(complaintId: complaintId);
        },
      ),

      // Student Routes
      GoRoute(
        path: studentDashboard,
        name: 'studentDashboard',
        builder: (context, state) => const StudentDashboard(),
      ),
      GoRoute(
        path: complaintSubmission,
        name: 'complaintSubmission',
        builder: (context, state) => const ComplaintSubmission(),
      ),
      GoRoute(
        path: complaintHistory,
        name: 'complaintHistory',
        builder: (context, state) => const ComplaintHistory(),
      ),
      GoRoute(
        path: '$complaintStatus/:complaintId',
        name: 'complaintStatus',
        builder: (context, state) {
          final complaintId = state.pathParameters['complaintId']!;
          return ComplaintStatus(complaintId: complaintId);
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'The page you are looking for does not exist.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );

  // Helper methods for navigation
  static void goToLogin(BuildContext context) {
    context.go(login);
  }

  static void goToAdminDashboard(BuildContext context) {
    context.go(adminDashboard);
  }

  static void goToAdvisorDashboard(BuildContext context) {
    context.go(advisorDashboard);
  }

  static void goToHODDashboard(BuildContext context) {
    context.go(hodDashboard);
  }

  static void goToStudentDashboard(BuildContext context) {
    context.go(studentDashboard);
  }

  static void goToComplaintDetail(BuildContext context, String complaintId, String role) {
    if (role == 'Batch Advisor') {
      context.go('$advisorComplaintDetail/$complaintId');
    } else if (role == 'HOD') {
      context.go('$hodComplaintDetail/$complaintId');
    }
  }

  static void goToComplaintStatus(BuildContext context, String complaintId) {
    context.go('$complaintStatus/$complaintId');
  }
}