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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text("Streak", style: Theme.of(context).textTheme.headlineMedium),
        SizedBox(height: 8),
        ...uniqueTasks.map((task) {
          int streak = _calculateStreak(task);
          return ListTile(
            title: Text(task.name),
            subtitle: Text("Streak: $streak days"),
          );
        }).toList(),
      ],
    );
  }
}
