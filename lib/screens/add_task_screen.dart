import 'package:flutter/material.dart';
import '../models/task.dart';
import '../db/firestore_db.dart';

class AddTaskScreen extends StatefulWidget {
  final DateTime selectedDate;
  const AddTaskScreen({super.key, required this.selectedDate});

  @override
  _AddTaskScreen createState() => _AddTaskScreen();
}

class _AddTaskScreen extends State<AddTaskScreen> {
  final _nameController = TextEditingController();
  bool _recurring = false;
  DateTime? _date; // Data dla pojedynczego zadania
  List<int>? _daysOfWeek = []; // Dni tygodnia (1 = poniedziałek, 7 = niedziela)
  TimeOfDay? _time;
  bool _isCompleted = false;
  int?
      _recurringMonths; // Liczba miesięcy, przez które zadanie ma się powtarzać

  // Utwórz obiekt FirestoreDb do dodawania zadań
  final FirestoreDb firestoreDb = FirestoreDb();

  @override
  void initState() {
    super.initState();
    _date = widget.selectedDate;
  }

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
          recurring: true,
          date: taskDate,
          time: newTask.time,
          isCompleted: newTask.isCompleted,
          streak: newTask.streak,
        );
        await firestoreDb.addTask(task); // Dodajemy każde wygenerowane zadanie
      }
    } else {
      await firestoreDb.addTask(
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
        child: SingleChildScrollView(
          // Umożliwia przewijanie formularza
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: "Task Name",
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
              SizedBox(height: 16), // Dodajemy więcej przestrzeni
              SwitchListTile(
                title: Text("Recurring Task"),
                value: _recurring,
                onChanged: (value) {
                  setState(() {
                    _recurring = value;
                  });
                },
              ),
              SizedBox(height: 16), // Dodajemy więcej przestrzeni
              if (_recurring) ...[
                Text("Select Days of the Week", style: TextStyle(fontSize: 16)),
                SizedBox(
                    height: 8), // Odstęp między tytułem a przyciskami wyboru
                Wrap(
                  spacing: 10, // Większa przestrzeń między chipami
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
                          _date = null;
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
                SizedBox(
                    height: 16), // Dodajemy przestrzeń po wyborze dni tygodnia
                Text("Repeat for how many months?",
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
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
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                ),
              ],
              SizedBox(
                  height: 16), // Dodajemy przestrzeń po polu wyboru miesięcy
              if (!_recurring) ...[
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
              SizedBox(height: 16), // Dodajemy przestrzeń po dacie
              ElevatedButton(
                onPressed: _saveTask,
                child: Text("Save Task"),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                      vertical: 14), // Większa przestrzeń w przycisku
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
