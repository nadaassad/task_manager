import 'package:flutter/material.dart';
import 'package:task_manager/database/db_helper.dart';
import 'package:task_manager/models/tasks.dart';

//stateful widget because we need to update the UI when we add/edit/delete tasks
class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

// State class for TasksScreen to manage the state of the tasks list and handle database operations
class _TasksScreenState extends State<TasksScreen> {
  //String -> key, dynamic -> value
  List<Task> tasks = [];

  // Initial fetch of tasks when the screen loads to display existing tasks from the database
  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // Fetch Tasks
  Future<void> fetchTasks() async {
    // Fetch tasks from the database and update the state to display them in the UI
    final data = await DBHelper.getTasks();
    setState(() {
      tasks = data;
    });
  }

  // add Task
  Future<void> addTask({
    required String title,
    String? description,
    required String dueDate,
    required String priority,
  }) async {
    // Insert the new task into the database using the DBHelper and then refresh the task list to show the new task in the UI
    await DBHelper.insertTask({
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'isCompleted': 0,
    });

    fetchTasks();
  }

  //complete Task
  Future<void> completeTask(int id, int currentStatus) async {
    // Toggle the completion status of the task in the database and refresh the task list to reflect the change in the UI
    await DBHelper.updateTask(id, {'isCompleted': currentStatus == 1 ? 0 : 1});
    fetchTasks();
  }

  //edit Task
  Future<void> editTask(int id, Map<String, dynamic> newData) async {
    // Update the task in the database with the new data and refresh the task list to show the updated task in the UI
    await DBHelper.updateTask(id, newData);
    fetchTasks();
  }

  // 🗑️ delete Task
  Future<void> deleteTask(int id) async {
    await DBHelper.deleteTask(id); // ✅ استخدم الـ helper
    fetchTasks();
  }

  void showAddTaskDialog() {
    String title = "";
    String description = "";
    String dueDate = "";
    String priority = "Low";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add New Task"),

          content: SingleChildScrollView(
            child: Column(
              children: [
                //Title input
                TextField(
                  onChanged: (value) => title = value,
                  decoration: const InputDecoration(hintText: "Title"),
                ),
                //Description input
                TextField(
                  onChanged: (value) => description = value,
                  decoration: const InputDecoration(hintText: "Description"),
                ),
                //Due Date input
                TextField(
                  onChanged: (value) => dueDate = value,
                  decoration: const InputDecoration(
                    hintText: "Due Date (YYYY-MM-DD)",
                  ),
                ),
                //priority input
                DropdownButtonFormField<String>(
                  value: priority,
                  items: const [
                    DropdownMenuItem(value: "Low", child: Text("Low")),
                    DropdownMenuItem(value: "Medium", child: Text("Medium")),
                    DropdownMenuItem(value: "High", child: Text("High")),
                  ],
                  onChanged: (value) => {priority = value!},
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (title.isNotEmpty && dueDate.isNotEmpty) {
                  await addTask(
                    title: title,
                    description: description,
                    dueDate: dueDate,
                    priority: priority,
                  );
                }
                Navigator.pop(context);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void showEditTaskDialog(Task task) {
    TextEditingController titleController = TextEditingController(
      text: task.title,
    );

    TextEditingController desController = TextEditingController(
      text: task.description ?? '',
    );

    TextEditingController dateController = TextEditingController(
      text: task.dueDate,
    );

    String priority = task.priority;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Task"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: "Title"),
                ),
                TextField(
                  controller: desController,
                  decoration: const InputDecoration(labelText: "Description"),
                ),
                TextField(
                  controller: dateController,
                  decoration: const InputDecoration(
                    labelText: "Due Date (YYYY-MM-DD)",
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: priority,
                  items: const [
                    DropdownMenuItem(value: "Low", child: Text("Low")),
                    DropdownMenuItem(value: "Medium", child: Text("Medium")),
                    DropdownMenuItem(value: "High", child: Text("High")),
                  ],
                  onChanged: (value) => {priority = value!},
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                await editTask(task.id!, {
                  'title': titleController.text,
                  'description': desController.text,
                  'dueDate': dateController.text,
                  'priority': priority,
                });
                Navigator.pop(context);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("My Tasks")),
      body: tasks.isEmpty
          ? const Center(child: Text("No Tasks Yet"))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];

                return ListTile(
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isCompleted == 1
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),

                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // 🖊️ Edit button
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          showEditTaskDialog(task);
                        },
                      ),
                      // ✅ Complete button
                      IconButton(
                        icon: Icon(
                          Icons.check,
                          color: task.isCompleted == 1
                              ? Colors.green
                              : Colors.grey,
                        ),
                        onPressed: () {
                          completeTask(task.id!, task.isCompleted);
                        },
                      ),

                      // 🗑️ Delete button
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteTask(task.id!),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
