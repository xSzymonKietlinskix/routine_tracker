import 'package:flutter/material.dart';
import '../models/task.dart';
import '../db/firestore_db.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});
  
  @override
  _AddTaskScreen createState() => _AddTaskScreen();
}

class _AddTaskScreen extends State<AddTaskScreen> {
  final _nameController = TextEditingController();
  bool _recurring = false;
  DateTime? _date;  // Data dla pojedynczego zadania
  List<int>? _daysOfWeek = []; // Dni tygodnia (1 = poniedziałek, 7 = niedziela)
  TimeOfDay? _time;
  bool _isCompleted = false;
  int? _recurringMonths; // Liczba miesięcy, przez które zadanie ma się powtarzać

  // Utwórz obiekt FirestoreDb do dodawania zadań
  final FirestoreDb firestoreDb = FirestoreDb();

  void _saveTask() async {
    // Tworzymy nowe zadanie
    final newTask = Task(
      name: _nameController.text,
      recurring: _recurring,
      date: _date,
      daysOfWeek: _daysOfWeek,
      time: _time,
      isCompleted: _isCompleted,
      recurringMonths: _recurringMonths,
    );

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
        await firestoreDb.addTask(task); // Dodajemy każde wygenerowane zadanie
      }
    } else {
      await firestoreDb.addTask(newTask); // Dodajemy jedno zadanie, jeśli nie jest powtarzające się
    }

    // Po zapisaniu zadania wracamy do poprzedniego ekranu
    Navigator.pop(context);
  }

  DateTime _getNextDayOfWeek(DateTime from, int dayOfWeek) {
    int daysToAdd = (dayOfWeek - from.weekday + 7) % 7;
    // Jeżeli obliczona data jest wstecz, to bierzemy kolejny tydzień
    if (daysToAdd == 0) {
      daysToAdd = 7;
    }
    return from.add(Duration(days: daysToAdd));
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
                    label: Text(["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"][index]),
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
            ],
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
              trailing:
                  Text(_date != null ? "${_date!.toLocal()}".split(' ')[0] : "Pick Date"),
            ),
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
