import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/tasks.dart';

class FavoriteTasksScreen extends StatelessWidget {
  const FavoriteTasksScreen({super.key});

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;

      case 'Medium':
        return Colors.orange;

      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TaskProvider>(context);
    final favTasks = provider.favoriteTasks;

    return Scaffold(
      appBar: AppBar(title: const Text('Favorite Tasks')),
      body: favTasks.isEmpty
          ? const Center(child: Text('No Favorite Tasks Yet.'))
          : ListView.builder(
              itemCount: favTasks.length,
              itemBuilder: (_, i) {
                final task = favTasks[i];

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  child: ListTile(
                    title: Text(task.title),
                    subtitle: Text('Due: ${task.dueDate}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _priorityColor(task.priority),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            task.priority,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.star, color: Colors.amber),
                          onPressed: () => provider.toggleFavorite(task),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
