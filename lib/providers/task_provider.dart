import 'package:flutter/material.dart';
import '../models/tasks.dart';
import '../database/database_helper.dart';

class TaskProvider extends ChangeNotifier {
  // This class will manage the state of tasks across the app, allowing for easy updates and retrieval of task data
  // You can add methods here to fetch tasks from the database, add new tasks, update existing tasks, and delete tasks
  // Whenever a change is made to the tasks, call notifyListeners() to update the UI}
  List<Task> _tasks = [];
  List<Task> get tasks => _tasks;
  List<Task> get favioriteTasks =>
      _tasks.where((task) => task.isFavorite == 1).toList();

  Future<void> loadTasks() async {
    // Load tasks from the database and update the _tasks list
    // After loading, call notifyListeners() to update the UI
    final data = await DatabaseHelper.instance.getTasks();
    _tasks = data;
    notifyListeners();
  }

  Future<void> addTask(Map<String, dynamic> task) async {
    await DatabaseHelper.instance.insertTask(task);
    await loadTasks();
  }

  Future<void> updateTask(int id, Map<String, dynamic> data) async {
    await DatabaseHelper.instance.updateTask(id, data);
    await loadTasks();
  }

  Future<void> deleteTask(int id) async {
    await DatabaseHelper.instance.deleteTask(id);
    await loadTasks();
  }

  Future<void> toggleComplete(Task task) async {
    await DatabaseHelper.instance.updateTask(task.id!, {
      'isCompleted': task.isCompleted == 1 ? 0 : 1,
    });
    await loadTasks();
  }

  Future<void> toggleFavorite(Task task) async {
    await DatabaseHelper.instance.updateTask(task.id!, {
      'isFavorite': task.isFavorite == 1 ? 0 : 1,
    });
    await loadTasks();
  }
}
