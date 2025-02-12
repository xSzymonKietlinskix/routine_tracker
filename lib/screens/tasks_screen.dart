import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class TasksScreen extends StatefulWidget {
  @override
  _TasksScreenState createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> tasks = []; // Lista map zamiast listy stringów

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }


  /// **Ładuje zapisane taski z pamięci**
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      tasks = List<Map<String, dynamic>>.from(
          jsonDecode(prefs.getString('tasks') ?? '[]'));
    });
  }

  /// **Zapisuje taski do pamięci**
  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasks', jsonEncode(tasks));
  }

  /// **Dodaje lub edytuje task**
  void _showTaskDialog({Map<String, dynamic>? oldTask}) {
    TextEditingController taskController = TextEditingController();
    bool isRecurring = oldTask?['isRecurring'] ?? false;
    DateTime selectedDate = oldTask?['date'] != null
        ? DateTime.parse(oldTask!['date'])
        : DateTime.now();
    List<bool> selectedDays = oldTask?['days'] != null
        ? List<bool>.from(oldTask!['days'])
        : List.filled(7, false);

    if (oldTask != null) taskController.text = oldTask['name'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                  oldTask == null ? "Dodaj nowe zadanie" : "Edytuj zadanie"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: taskController,
                    decoration:
                        InputDecoration(hintText: "Wpisz nazwę zadania"),
                  ),
                  SwitchListTile(
                    title: Text("Zadanie powtarzające się"),
                    value: isRecurring,
                    onChanged: (value) {
                      FocusScope.of(context).unfocus();
                      setDialogState(() {
                        isRecurring = value;
                      });
                    },
                  ),
                  if (!isRecurring)
                    ListTile(
                      title: Text("Wybierz datę: ${selectedDate.toLocal()}"
                          .split(' ')[0]),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                    ),
                  if (isRecurring)
                    Wrap(
                      children: List.generate(7, (index) {
                        return ChoiceChip(
                          label: Text([
                            "Pn",
                            "Wt",
                            "Śr",
                            "Cz",
                            "Pt",
                            "Sb",
                            "Nd"
                          ][index]),
                          selected: selectedDays[index],
                          onSelected: (selected) {
                            setDialogState(() {
                              selectedDays[index] = selected;
                            });
                          },
                        );
                      }),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  child: Text("Anuluj"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("Zapisz"),
                  onPressed: () {
                    setState(() {
                      String newTask = taskController.text.trim();
                      if (newTask.isNotEmpty) {
                        if (oldTask != null) {
                          // Edycja
                          int index = tasks.indexOf(oldTask);
                          tasks[index] = {
                            "name": newTask,
                            "isRecurring": isRecurring,
                            "date": isRecurring
                                ? null
                                : selectedDate.toIso8601String(),
                            "days": isRecurring ? selectedDays : null,
                          };
                        } else {
                          // Nowe zadanie
                          tasks.add({
                            "name": newTask,
                            "isRecurring": isRecurring,
                            "date": isRecurring
                                ? null
                                : selectedDate.toIso8601String(),
                            "days": isRecurring ? selectedDays : null,
                          });
                        }
                        _saveTasks();
                      }
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// **Usuwa task**
  void _removeTask(Map<String, dynamic> task) {
    setState(() {
      tasks.remove(task);
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          Map<String, dynamic> task = tasks[index];
          return Dismissible(
            key: Key(task['name']),
            background: Container(
              color: Colors.blue, // Przesunięcie w prawo (edycja)
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.edit, color: Colors.white),
            ),
            secondaryBackground: Container(
              color: Colors.red, // Przesunięcie w lewo (usunięcie)
              alignment: Alignment.centerRight,
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Icon(Icons.delete, color: Colors.white),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.startToEnd) {
                _showTaskDialog(oldTask: task);
                return false; // Nie usuwaj, tylko edytuj
              } else if (direction == DismissDirection.endToStart) {
                return true;
              }
              return false;
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                _removeTask(task);
              }
            },
            child: ListTile(
              title: Text(task['name']),
              subtitle: task['isRecurring']
                  ? Text(
                      "Powtarza się: " +
                          ["Pn", "Wt", "Śr", "Cz", "Pt", "Sb", "Nd"]
                              .asMap()
                              .entries
                              .where((entry) => task['days'][entry.key])
                              .map((entry) => entry.value)
                              .join(", "),
                    )
                  : Text("Jednorazowe: ${task['date']?.split('T')[0] ?? ''}"),
              trailing: Checkbox(
                value: task['completed'] ?? false,
                onChanged: (bool? value) {
                  setState(() {
                    task['completed'] = value ?? false;
                    _saveTasks();
                  });
                },
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTaskDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.pink,
      ),
    );
  }
}
