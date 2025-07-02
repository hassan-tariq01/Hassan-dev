class Batch {
  final String id;
  final String name;
  final String departmentId;
  final String? advisorId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Batch({
    required this.id,
    required this.name,
    required this.departmentId,
    this.advisorId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    try {
      return Batch(
        id: json['id']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        departmentId: json['department_id']?.toString() ?? '',
        advisorId: json['advisor_id']?.toString(),
        createdAt: json['created_at'] != null 
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
        updatedAt: json['updated_at'] != null 
            ? DateTime.parse(json['updated_at'].toString())
            : DateTime.now(),
      );
    } catch (e) {
      print('Error parsing batch JSON: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department_id': departmentId,
      'advisor_id': advisorId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Batch copyWith({
    String? id,
    String? name,
    String? departmentId,
    String? advisorId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Batch(
      id: id ?? this.id,
      name: name ?? this.name,
      departmentId: departmentId ?? this.departmentId,
      advisorId: advisorId ?? this.advisorId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Batch(id: $id, name: $name, departmentId: $departmentId, advisorId: $advisorId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Batch && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  // Helper methods
  bool get hasAdvisor => advisorId != null && advisorId!.isNotEmpty;
} 