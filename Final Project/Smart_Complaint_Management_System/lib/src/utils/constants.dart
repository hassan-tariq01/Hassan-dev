class AppConstants {
  // User roles
  static const String roleAdmin = 'Admin';
  static const String roleBatchAdvisor = 'Batch Advisor';
  static const String roleHOD = 'HOD';
  static const String roleStudent = 'Student';
  static const List<String> userRoles = [
    roleAdmin,
    roleBatchAdvisor,
    roleHOD,
    roleStudent,
  ];

  // Complaint statuses
  static const String statusSubmitted = 'Submitted';
  static const String statusInProgress = 'In Progress';
  static const String statusEscalated = 'Escalated to HOD';
  static const String statusResolved = 'Resolved';
  static const String statusRejected = 'Rejected';
  static const List<String> complaintStatuses = [
    statusSubmitted,
    statusInProgress,
    statusEscalated,
    statusResolved,
    statusRejected,
  ];
}