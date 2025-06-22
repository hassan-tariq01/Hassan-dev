class Batch {
  final String id;
  final String name;
  final String departmentId;
  final String? advisorId;

  Batch({
    required this.id,
    required this.name,
    required this.departmentId,
    this.advisorId,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'] as String,
      name: json['name'] as String,
      departmentId: json['department_id'] as String,
      advisorId: json['advisor_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'department_id': departmentId,
      'advisor_id': advisorId,
    };
  }
}