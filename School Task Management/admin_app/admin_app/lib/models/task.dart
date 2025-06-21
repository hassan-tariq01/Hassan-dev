class Task {
  final String id;
  final String title;
  final String? description;
  final String assignedTo;
  final DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.assignedTo,
    this.dueDate,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      assignedTo: json['assigned_to']?.toString() ?? '',
      dueDate: json['due_date'] != null ? DateTime.parse(json['due_date']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'assigned_to': assignedTo,
      'due_date': dueDate?.toIso8601String(),
    };
  }
}