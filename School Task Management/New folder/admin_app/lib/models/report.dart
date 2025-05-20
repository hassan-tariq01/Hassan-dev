class Report {
  final String studentId;
  final double completionRate;
  final int completedTasks;
  final int totalTasks;

  Report({
    required this.studentId,
    required this.completionRate,
    required this.completedTasks,
    required this.totalTasks,
  });

  factory Report.fromJson(Map<String, dynamic> json) {
    return Report(
      studentId: json['student_id']?.toString() ?? '',
      completionRate: (json['completion_rate'] as num?)?.toDouble() ?? 0.0,
      completedTasks: (json['completed_tasks'] as num?)?.toInt() ?? 0,
      totalTasks: (json['total_tasks'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'completion_rate': completionRate,
      'completed_tasks': completedTasks,
      'total_tasks': totalTasks,
    };
  }
}