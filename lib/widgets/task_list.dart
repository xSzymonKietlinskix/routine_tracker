import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:routine_tracker/db/hive_db.dart';
import '../models/task.dart';

class TaskList extends StatelessWidget {
  final DateTime selectedDate;

  TaskList({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Box<Task>>(
      valueListenable: Hive.box<Task>('tasks').listenable(),
      builder: (context, box, _) {
        List<Task> tasksForDay =
            box.values.where((task) => task.isForDate(selectedDate)).toList();

        return ListView.builder(
          shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          itemCount: tasksForDay.length,
          itemBuilder: (context, index) {
            Task task = tasksForDay[index];
            return ListTile(
              title: Text(task.name),
              trailing: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) {
                  task.isCompleted = value ?? false;
                  HiveDb().updateTask(index, task);
                },
              ),
            );
          },
        );
      },
    );
  }
}
