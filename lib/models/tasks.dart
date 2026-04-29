class Task {
  int? id;
  int userId; // 👈 أضف ده
  String title;
  String description;
  String dueDate;
  String priority;
  int isCompleted;
  int isFavorite;

  Task({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    this.isFavorite = 0,
  });

  // Convert a Task object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'isCompleted': isCompleted,
      'isFavorite': isFavorite,
    };
  }

  // Create a Task object from a map
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      userId: map['userId'] ?? 0,
      title: map['title'] ?? '',
      description: map['description'],
      dueDate: map['dueDate'] ?? '',
      priority: map['priority'] ?? 'Low',
      isCompleted: map['isCompleted'] ?? 0,
      isFavorite: map['isFavorite'] ?? 0,
    );
  }
}
