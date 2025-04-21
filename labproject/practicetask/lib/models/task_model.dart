class Task {
  int? id;
  String title;
  String description;
  DateTime date;
  bool isCompleted;
  bool isRepeated;
  String repeatDays;

  Task({
    this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isCompleted = false,
    this.isRepeated = false,
    this.repeatDays = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'isCompleted': isCompleted ? 1 : 0,
      'isRepeated': isRepeated ? 1 : 0,
      'repeatDays': repeatDays,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      date: DateTime.parse(map['date'] as String),
      isCompleted: (map['isCompleted'] as int?) == 1,
      isRepeated: (map['isRepeated'] as int?) == 1,
      repeatDays: map['repeatDays'] as String? ?? '',
    );
  }
}