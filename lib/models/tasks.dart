class Task {
  int? id;
  String title;
  String? description;
  String dueDate;
  String priority;
  int isCompleted;

  Task({
    this.id,
    required this.title,
    this.description,
    required this.dueDate,
    required this.priority,
    this.isCompleted = 0,
  });
  // Convert a Task object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'isCompleted': isCompleted,
    };
  }

  // Create a Task object from a map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'] ?? '',
      description: map['description'],
      dueDate: map['dueDate'] ?? '',
      priority: map['priority'] ?? 'Low',
      isCompleted: map['isCompleted'] ?? 0,
    );
  }
}
