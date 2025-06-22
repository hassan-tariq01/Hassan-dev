class Complaint {
  final String id;
  final String studentId;
  final String batchId;
  final String? advisorId;
  final String? hodId;
  final String title;
  final String description;
  final String? mediaUrl;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Complaint({
    required this.id,
    required this.studentId,
    required this.batchId,
    this.advisorId,
    this.hodId,
    required this.title,
    required this.description,
    this.mediaUrl,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      batchId: json['batch_id'] as String,
      advisorId: json['advisor_id'] as String?,
      hodId: json['hod_id'] as String?,
      title: json['title'] as String,
      description: json['description'] as String,
      mediaUrl: json['media_url'] as String?,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'batch_id': batchId,
      'advisor_id': advisorId,
      'hod_id': hodId,
      'title': title,
      'description': description,
      'media_url': mediaUrl,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}