import 'package:go_router/go_router.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/advisor/advisor_dashboard.dart';
import '../screens/hod/hod_dashboard.dart';
import '../screens/student/student_dashboard.dart';
import '../auth/login_screen.dart';

final router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/admin_dashboard',
      builder: (context, state) => const AdminDashboard(),
    ),
    GoRoute(
      path: '/advisor_dashboard',
      builder: (context, state) => const AdvisorDashboard(),
    ),
    GoRoute(
      path: '/hod_dashboard',
      builder: (context, state) => const HodDashboard(),
    ),
    GoRoute(
      path: '/student_dashboard',
      builder: (context, state) => const StudentDashboard(),
    ),
    // TODO: Add routes for other screens (e.g., complaint_submission, complaint_list)
  ],
);