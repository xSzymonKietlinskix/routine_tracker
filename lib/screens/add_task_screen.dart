import 'package:flutter/material.dart';
import '../widgets/task_form.dart';

class AddTaskScreen extends StatelessWidget {
  final DateTime selectedDate;
  const AddTaskScreen({super.key, required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TaskForm(selectedDate: selectedDate),
      ),
    );
  }
}
