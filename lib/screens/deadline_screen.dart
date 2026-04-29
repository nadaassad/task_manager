import 'package:flutter/material.dart';
import '../models/tasks.dart';

class DeadlineScreen extends StatelessWidget {
  final Task task;

  const DeadlineScreen({super.key, required this.task});

  String getRemainingTime(String dueDate) {
    final now = DateTime.now();
    final due = DateTime.parse(dueDate);

    final difference = due.difference(now);

    if (difference.isNegative) {
      return "EXPIRED";
    }

    final days = difference.inDays;
    final hours = difference.inHours % 24;

    if (days > 0) {
      return "$days days left";
    } else {
      return "$hours hours left";
    }
  }

  Color getRemainingColor(String remaining) {
    if (remaining == "EXPIRED") {
      return Colors.red;
    } else if (remaining.contains("hours")) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now().toString().split(' ')[0];
    final remaining = getRemainingTime(task.dueDate);

    return Scaffold(
      appBar: AppBar(title: const Text("Deadline Tracker"), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Card(
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "📌 Task: ${task.title}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text("📅 Today: $today"),
                  Text("⏳ Due Date: ${task.dueDate}"),

                  const Divider(height: 25),

                  Text(
                    "⏱ Remaining Time: $remaining",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: getRemainingColor(remaining),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
