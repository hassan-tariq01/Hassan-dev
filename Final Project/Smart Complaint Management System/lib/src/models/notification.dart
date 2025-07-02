class Notification {
  final String id;
  final String userId;
  final String? complaintId;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final DateTime createdAt;

  Notification({
    required this.id,
    required this.userId,
    this.complaintId,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    required this.createdAt,
  });

  factory Notification.fromJson(Map<String, dynamic> json) {
    return Notification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      complaintId: json['complaint_id'] as String?,
      title: json['title'] as String? ?? 'Notification',
      message: json['message'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'complaint_id': complaintId,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Notification copyWith({
    String? id,
    String? userId,
    String? complaintId,
    String? title,
    String? message,
    DateTime? timestamp,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Notification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      complaintId: complaintId ?? this.complaintId,
      title: title ?? this.title,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Notification(id: $id, title: $title, message: $message, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  bool get hasComplaint => complaintId != null && complaintId!.isNotEmpty;
} 