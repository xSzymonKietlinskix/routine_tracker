import 'package:flutter/material.dart';
import 'package:routine_tracker/db/hive_db.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final HiveDb hiveDb = HiveDb(); // Inicjalizujemy bazę

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Lista Zadań")),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Task>('tasks').listenable(),
        builder: (context, Box<Task> box, _) {
          List<Task> tasks = hiveDb.getTasks();

          if (tasks.isEmpty) {
            return Center(child: Text("Brak zadań"));
          }

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              Task task = tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text(task.description),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => _deleteTask(index),
                ),
                onTap: () => _editTask(index, task),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
    );
  }

  void _addTask() async {
    Task newTask = Task(
      title: "Nowe Zadanie",
      description: "Opis zadania",
      type: "single",
    );
    await hiveDb.addTask(newTask);
    setState(() {}); // Odśwież widok
  }

  void _deleteTask(int index) async {
    await hiveDb.deleteTask(index);
    setState(() {}); // Odśwież listę po usunięciu
  }

  void _editTask(int index, Task task) async {
    Task updatedTask = Task(
      title: "${task.title} (Edytowane)",
      description: task.description,
      type: task.type,
      date: task.date,
      daysOfWeek: task.daysOfWeek,
      time: task.time,
      streak: task.streak + 1, // Przykładowa edycja
    );

    await hiveDb.updateTask(index, updatedTask);
    setState(() {}); // Odśwież widok
  }
}
