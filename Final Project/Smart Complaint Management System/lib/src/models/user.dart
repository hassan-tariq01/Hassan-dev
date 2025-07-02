import 'package:supabase_flutter/supabase_flutter.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? batchId;
  final String? departmentId;
  final String? studentId;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.batchId,
    this.departmentId,
    this.studentId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      batchId: json['batch_id'] as String?,
      departmentId: json['department_id'] as String?,
      studentId: json['student_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'batch_id': batchId,
      'department_id': departmentId,
      'student_id': studentId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? role,
    String? batchId,
    String? departmentId,
    String? studentId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      batchId: batchId ?? this.batchId,
      departmentId: departmentId ?? this.departmentId,
      studentId: studentId ?? this.studentId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, name: $name, email: $email, role: $role, batchId: $batchId, departmentId: $departmentId, studentId: $studentId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  bool get isAdmin => role == 'Admin';
  bool get isBatchAdvisor => role == 'Batch Advisor';
  bool get isHOD => role == 'HOD';
  bool get isStudent => role == 'Student';
} 