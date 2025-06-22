class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? batchId;
  final String? departmentId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.batchId,
    this.departmentId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      batchId: json['batch_id'] as String?,
      departmentId: json['department_id'] as String?,
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
    };
  }
}