class ComplaintLog {
  final String id;
  final String complaintId;
  final String userId;
  final String action;
  final String? comment;
  final DateTime timestamp;

  ComplaintLog({
    required this.id,
    required this.complaintId,
    required this.userId,
    required this.action,
    this.comment,
    required this.timestamp,
  });

  factory ComplaintLog.fromJson(Map<String, dynamic> json) {
    return ComplaintLog(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      userId: json['user_id'] as String,
      action: json['action'] as String,
      comment: json['comment'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'complaint_id': complaintId,
      'user_id': userId,
      'action': action,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}