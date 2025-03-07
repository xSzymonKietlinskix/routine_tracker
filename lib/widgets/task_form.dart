import 'package:flutter/material.dart';
import '../models/task.dart';
import '../db/firestore_db.dart';
import 'category_selector.dart';
import 'priority_selector.dart';
import 'task_recurring_options.dart';

class TaskForm extends StatefulWidget {
  final DateTime selectedDate;
  const TaskForm({super.key, required this.selectedDate});

  @override
  _TaskFormState createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final _nameController = TextEditingController();
  bool _recurring = false;
  DateTime? _date;
  List<int>? _daysOfWeek = [];
  TimeOfDay? _time;
  bool _isCompleted = false;
  int? _recurringMonths;
  String? _selectedCategory;
  int? _priority;

  final FirestoreDb firestoreDb = FirestoreDb();

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
  }

  void _saveTask() async {
    final newTask = Task(
      name: _nameController.text,
      recurring: _recurring,
      date: _date,
      daysOfWeek: _daysOfWeek,
      time: _time,
      isCompleted: _isCompleted,
      recurringMonths: _recurringMonths,
      category: _selectedCategory,
      priority: _priority,
    );

    if (_recurring && _recurringMonths != null) {
      List<DateTime> recurringDates = newTask.generateRecurringTasks();
      for (DateTime taskDate in recurringDates) {
        var task = Task(
          name: newTask.name,
          recurring: true,
          date: taskDate,
          time: newTask.time,
          isCompleted: newTask.isCompleted,
          streak: newTask.streak,
          category: newTask.category,
          priority: newTask.priority,
        );
        await firestoreDb.addTask(task);
      }
    } else {
      await firestoreDb.addTask(newTask);
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: "Task Name"),
          ),
          SizedBox(height: 16),
          CategorySelector(
            selectedCategory: _selectedCategory,
            onCategorySelected: (category) {
              setState(() {
                _selectedCategory = category;
              });
            },
          ),
          SizedBox(height: 16),
          PrioritySelector(
            selectedPriority: _priority,
            onPrioritySelected: (priority) {
              setState(() {
                _priority = priority;
              });
            },
          ),
          SizedBox(height: 16),
          SwitchListTile(
            title: Text("Recurring Task"),
            value: _recurring,
            onChanged: (value) {
              setState(() {
                _recurring = value;
              });
            },
          ),
          SizedBox(height: 16),
          if (_recurring)
            TaskRecurringOptions(
              daysOfWeek: _daysOfWeek,
              onDaysSelected: (days) {
                setState(() {
                  _daysOfWeek = days;
                });
              },
              onMonthsSelected: (months) {
                setState(() {
                  _recurringMonths = months;
                });
              },
            ),
          if (!_recurring)
            ListTile(
              title: Text("Select Date"),
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2025, 12, 31),
                );
                if (pickedDate != null) {
                  setState(() {
                    _date = pickedDate;
                  });
                }
              },
              trailing: Text(_date != null
                  ? "${_date!.toLocal()}".split(' ')[0]
                  : "Pick Date"),
            ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: _saveTask,
            child: Text("Save Task"),
          ),
        ],
      ),
    );
  }
}
