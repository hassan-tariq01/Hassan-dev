class Notification {
  final String id;
  final String userId;
  final String? complaintId;
  final String message;
  final DateTime timestamp;

  Notification({
    required this.id,
    required this.userId,
    this.complaintId,
    required this.message,
    required this.timestamp,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      complaintId: json['complaint_id'] as String?,
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'complaint_id': complaintId,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}