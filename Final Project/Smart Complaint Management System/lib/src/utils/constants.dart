class AppConstants {
  // Supabase Configuration
  static const String supabaseUrl = 'https://otjafmqqvijxljkbjqvs.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im90amFmbXFxdmlqeGxqa2JqcXZzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA1NjE3NTksImV4cCI6MjA2NjEzNzc1OX0.6cJzWrXosZPmgpMzZ83_F8YDERMX3ziYla5OpyrcXcY';

  // Single Department
  static const String singleDepartmentName = 'Computer Science';
  static const String singleDepartmentId = '550e8400-e29b-41d4-a716-446655440000';

  // User Roles
  static const String roleAdmin = 'Admin';
  static const String roleBatchAdvisor = 'Batch Advisor';
  static const String roleHOD = 'HOD';
  static const String roleStudent = 'Student';

  // Complaint Statuses
  static const String statusSubmitted = 'Submitted';
  static const String statusInProgress = 'In Progress';
  static const String statusEscalatedToHOD = 'Escalated to HOD';
  static const String statusResolved = 'Resolved';
  static const String statusRejected = 'Rejected';

  // Complaint Actions
  static const String actionComment = 'Comment';
  static const String actionStatusChange = 'Status Change';
  static const String actionEscalation = 'Escalation';

  // App Colors
  static const int primaryColor = 0xFF2196F3;
  static const int secondaryColor = 0xFF1976D2;
  static const int accentColor = 0xFF64B5F6;
  static const int backgroundColor = 0xFFF5F5F5;
  static const int errorColor = 0xFFD32F2F;
  static const int successColor = 0xFF388E3C;
  static const int warningColor = 0xFFFFA000;

  // Status Colors
  static const int submittedColor = 0xFF2196F3;
  static const int inProgressColor = 0xFFFFA000;
  static const int escalatedColor = 0xFFE91E63;
  static const int resolvedColor = 0xFF388E3C;
  static const int rejectedColor = 0xFFD32F2F;

  // App Text
  static const String appName = 'Smart Complaint Management';
  static const String appVersion = '1.0.0';

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String emailInvalid = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordMinLength = 'Password must be at least 6 characters';
  static const String titleRequired = 'Title is required';
  static const String descriptionRequired = 'Description is required';
  static const String nameRequired = 'Name is required';

  // Error Messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String authError = 'Authentication failed. Please try again.';
  static const String generalError = 'Something went wrong. Please try again.';
  static const String fileUploadError = 'File upload failed. Please try again.';

  // Success Messages
  static const String loginSuccess = 'Login successful';
  static const String complaintSubmitted = 'Complaint submitted successfully';
  static const String complaintUpdated = 'Complaint updated successfully';
  static const String fileUploaded = 'File uploaded successfully';

  // Database Table Names
  static const String tableUsers = 'users';
  static const String tableComplaints = 'complaints';
  static const String tableBatches = 'batches';
  static const String tableDepartments = 'departments';
  static const String tableComplaintLogs = 'complaint_logs';
  static const String tableNotifications = 'notifications';

  // Storage Buckets
  static const String mediaBucket = 'complaint-media';

  // Excel Headers
  static const List<String> excelHeaders = [
    'Student Name',
    'Email',
    'Batch',
    'Department',
    'Advisor Email'
  ];

  // Pagination
  static const int itemsPerPage = 20;

  // Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds
} 