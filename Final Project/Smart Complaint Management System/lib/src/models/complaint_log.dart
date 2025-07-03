class ComplaintLog {
  final String id;
  final String complaintId;
  final String userId;
  final String? advisorId;
  final String action;
  final String? comment;
  final DateTime timestamp;

  ComplaintLog({
    required this.id,
    required this.complaintId,
    required this.userId,
    this.advisorId,
    required this.action,
    this.comment,
    required this.timestamp,
  });

  factory ComplaintLog.fromJson(Map<String, dynamic> json) {
    return ComplaintLog(
      id: json['id'] as String,
      complaintId: json['complaint_id'] as String,
      userId: json['user_id'] as String,
      advisorId: json['advisor_id'] as String?,
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
      'advisor_id': advisorId,
      'action': action,
      'comment': comment,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  ComplaintLog copyWith({
    String? id,
    String? complaintId,
    String? userId,
    String? advisorId,
    String? action,
    String? comment,
    DateTime? timestamp,
  }) {
    return ComplaintLog(
      id: id ?? this.id,
      complaintId: complaintId ?? this.complaintId,
      userId: userId ?? this.userId,
      advisorId: advisorId ?? this.advisorId,
      action: action ?? this.action,
      comment: comment ?? this.comment,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'ComplaintLog(id: $id, complaintId: $complaintId, action: $action, userId: $userId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ComplaintLog && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
} 