import 'package:flutter/material.dart';
import '../models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  @override
  _AddTaskScreen createState() => _AddTaskScreen();
}

class _AddTaskScreen extends State<AddTaskScreen> {
  final _nameController = TextEditingController();
  bool _recurring = false;
  DateTime? _date;
  List<int>? _daysOfWeek = []; // Days of the week (1 = Monday, 7 = Sunday)
  TimeOfDay? _time;
  bool _isCompleted = false;
  int? _recurringMonths; // Number of months the task should repeat

  void _saveTask() async {
    // Jeśli zadanie jest powtarzające się, generujemy je na konkretne daty
    final newTask = Task(
      name: _nameController.text,
      recurring: _recurring,
      date: _date,
      daysOfWeek: _daysOfWeek,
      time: _time,
      isCompleted: _isCompleted,
      recurringMonths: _recurringMonths,
    );

    var box = await Hive.openBox<Task>('tasks');

    if (_recurring && _recurringMonths != null) {
      // Generowanie zadań na kolejne miesiące
      List<DateTime> recurringDates = newTask.generateRecurringTasks();
      for (DateTime taskDate in recurringDates) {
        var task = Task(
          name: newTask.name,
          recurring: false,
          date: taskDate,
          time: newTask.time,
          isCompleted: newTask.isCompleted,
          streak: newTask.streak,
        );
        await box.add(task); // Dodajemy każde wygenerowane zadanie
      }
    } else {
      await box.add(
          newTask); // Dodajemy jedno zadanie, jeśli nie jest powtarzające się
    }

    // Po zapisaniu zadania wracamy do poprzedniego ekranu
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add New Task")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: "Task Name"),
            ),
            SwitchListTile(
              title: Text("Recurring Task"),
              value: _recurring,
              onChanged: (value) {
                setState(() {
                  _recurring = value;
                });
              },
            ),
            if (_recurring) ...[
              // Jeśli zadanie jest cykliczne, wybieramy dni tygodnia
              Text("Select Days of the Week"),
              Wrap(
                children: List.generate(7, (index) {
                  return ChoiceChip(
                    label: Text([
                      "Mon",
                      "Tue",
                      "Wed",
                      "Thu",
                      "Fri",
                      "Sat",
                      "Sun"
                    ][index]),
                    selected: _daysOfWeek!.contains(index + 1),
                    onSelected: (isSelected) {
                      setState(() {
                        if (isSelected) {
                          _daysOfWeek!.add(index + 1);
                        } else {
                          _daysOfWeek!.remove(index + 1);
                        }
                      });
                    },
                  );
                }),
              ),
              Text("Repeat for how many months?"),
              TextField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    _recurringMonths = int.tryParse(value);
                  });
                },
                decoration: InputDecoration(
                  labelText: "Months",
                  hintText: "Enter number of months",
                ),
              ),
              ListTile(
                title: Text("Starting date"),
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
            ] else ...[
              // Jeśli zadanie nie jest cykliczne, wybieramy datę
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
            ],
            ListTile(
              title: Text("Select Time"),
              onTap: () async {
                TimeOfDay? pickedTime = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                );
                if (pickedTime != null) {
                  setState(() {
                    _time = pickedTime;
                  });
                }
              },
              trailing:
                  Text(_time != null ? _time!.format(context) : "Pick Time"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTask,
              child: Text("Save Task"),
            ),
          ],
        ),
      ),
    );
  }
}
