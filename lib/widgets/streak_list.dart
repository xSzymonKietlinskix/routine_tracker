// task_streak_widget.dart

import 'package:flutter/material.dart';
import '../models/task.dart';

class StreakWidget extends StatelessWidget {
  final List<Task> tasks;
  final List<Task> uniqueTasks;

  const StreakWidget(
      {super.key, required this.tasks, required this.uniqueTasks});

  int _calculateStreak(Task task) {
    int streak = 0;
    List<Task> recurringTasks = [];
    for (var t in tasks) {
      if (t.name == task.name && t.recurring) {
        recurringTasks.add(t);
      }
    }

    recurringTasks.sort((a, b) {
      int dateComparison = a.date!.compareTo(b.date!);
      if (dateComparison != 0) {
        return dateComparison;
      }
      return b.isCompleted ? 1 : 0 - (a.isCompleted ? 1 : 0);
    });

    for (var t in recurringTasks) {
      if (t.date!.isAfter(DateTime.now())) {
        break;
      }
      if (t.isCompleted) {
        streak += 1;
      } else if (t.date!.isBefore(DateTime.now())) {
        streak = 0;
      }
    }

    return streak;
  }

  @override
  Widget build(BuildContext context) {
    if (uniqueTasks.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding:
          const EdgeInsets.symmetric(horizontal: 50), // Odsunięcie od boków
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),
          ...uniqueTasks.map((task) {
            int streak = _calculateStreak(task);
            return Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(task.name, style: TextStyle(fontSize: 18)),
                    Row(
                      children: [
                        Icon(Icons.local_fire_department, color: Colors.orange),
                        SizedBox(width: 4),
                        Text("$streak days"),
                      ],
                    ),
                  ],
                ),
                Divider(), // Linia oddzielająca taski
              ],
            );
          }).toList(),
        ],
      ),
    );
  }
}
