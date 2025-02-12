import 'package:flutter/material.dart';
import 'package:routine_tracker/screens/tasks_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  Map<DateTime, List<Map<String, dynamic>>> _tasksByDate = {};

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  /// **Ładuje zadania i przypisuje je do dni w kalendarzu**
  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksJson = prefs.getString('tasks');

    if (tasksJson != null) {
      final List<dynamic> tasks = jsonDecode(tasksJson);

      Map<DateTime, List<Map<String, dynamic>>> newTasksByDate = {};

      for (var task in tasks) {
        DateTime? taskDate;
        if (task['isRecurring'] == true) {
          // Powtarzające się zadania -> dodajemy do wszystkich odpowiednich dni
          for (int i = 0; i < 365; i++) {
            DateTime day = DateTime.now().add(Duration(days: i));
            if (task['days']?[day.weekday - 1] == true) {
              newTasksByDate.putIfAbsent(day, () => []).add(task);
            }
          }
        } else {
          // Zadanie jednorazowe
          taskDate = DateTime.parse(task['date']);
          newTasksByDate.putIfAbsent(taskDate, () => []).add(task);
        }
      }

      setState(() {
        _tasksByDate = newTasksByDate;
      });
    }
  }

  /// **Zwraca zadania dla wybranego dnia**
  List<Map<String, dynamic>> _getTasksForDay(DateTime day) {
    return _tasksByDate[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TableCalendar(
          calendarStyle: CalendarStyle(
            defaultTextStyle: TextStyle(color: Colors.black),
            weekendTextStyle: TextStyle(color: Colors.pink),
          ),
          focusedDay: _selectedDay,
          firstDay: DateTime(2020),
          lastDay: DateTime(2030),
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarFormat: _calendarFormat,
          selectedDayPredicate: (day) => isSameDay(day, _selectedDay),
          onDaySelected: (selectedDay, focusedDay) {
            setState(() {
              _selectedDay = selectedDay;
            });
          },
          eventLoader: (day) =>
              _getTasksForDay(day), // Dodajemy eventy do kalendarza
        ),
        Expanded(
          child: ListView(
            children: _getTasksForDay(_selectedDay).map((task) {
              return ListTile(
                title: Text(task['name']),
                subtitle: task['isRecurring']
                    ? Text("Powtarzające się zadanie")
                    : Text("Jednorazowe"),
                trailing: Checkbox(
                  value: task['completed'] ?? false,
                  onChanged: (bool? value) {
                    setState(() {
                      task['completed'] = value ?? false;
                    });
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
