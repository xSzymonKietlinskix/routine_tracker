import 'package:flutter/material.dart';
import 'package:routine_tracker/screens/tasks_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';
import 'add_task_screen.dart';
import '../widgets/task_list.dart';
import '../models/task.dart';
import 'package:hive_flutter/hive_flutter.dart';

class CalendarScreen extends StatefulWidget {
  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  ValueNotifier<Map<DateTime, List<Task>>> _tasksByDate = ValueNotifier({});

  @override
  void initState() {
    super.initState();
    _loadTasks();
    Hive.box<Task>('tasks').listenable().addListener(_loadTasks);
  }

  @override
  void dispose() {
    Hive.box<Task>('tasks').listenable().removeListener(_loadTasks);
    super.dispose();
  }

  void _loadTasks() {
    final box = Hive.box<Task>('tasks');
    Map<DateTime, List<Task>> newTasksByDate = {};

    for (var task in box.values) {
      if (task.date != null && !task.recurring) {
        DateTime taskDate = DateTime(
          task.date!.year,
          task.date!.month,
          task.date!.day,
        );
        newTasksByDate.putIfAbsent(taskDate, () => []).add(task);
      } else if (task.daysOfWeek != null && task.recurring) {
        for (int weekday in task.daysOfWeek!) {
          for (int i = 0; i < 30; i++) {
            DateTime futureDate = DateTime.now().add(Duration(days: i));
            if (futureDate.weekday == weekday) {
              newTasksByDate.putIfAbsent(futureDate, () => []).add(task);
            }
          }
        }
      }
    }

    _tasksByDate.value = newTasksByDate;
  }

  bool _hasTasks(DateTime day) {
    // Sprawdzamy, czy istnieją zadania przypisane do konkretnego dnia
    if (_tasksByDate.value
        .containsKey(DateTime(day.year, day.month, day.day))) {
      return true;
    }

    // Dodatkowo sprawdzamy, czy mamy zadania cykliczne, które przypadają na dany dzień tygodnia
    for (var task in Hive.box<Task>('tasks').values) {
      if (task.recurring &&
          task.daysOfWeek != null &&
          task.daysOfWeek!.contains(day.weekday)) {
        return true;
      }
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 410,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: ValueListenableBuilder<Map<DateTime, List<Task>>>(
                    valueListenable: _tasksByDate,
                    builder: (context, tasksByDate, _) {
                      return TableCalendar(
                        calendarStyle: CalendarStyle(
                          defaultTextStyle: TextStyle(color: Colors.black),
                          weekendTextStyle: TextStyle(color: Colors.pink),
                        ),
                        focusedDay: _selectedDay,
                        firstDay: DateTime(2020),
                        lastDay: DateTime(2030),
                        startingDayOfWeek: StartingDayOfWeek.monday,
                        calendarFormat: _calendarFormat,
                        selectedDayPredicate: (day) =>
                            isSameDay(day, _selectedDay),
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                          });
                        },
                        calendarBuilders: CalendarBuilders(
                          markerBuilder: (context, date, events) {
                            if (_hasTasks(date)) {
                              return Positioned(
                                bottom: 5,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.pink,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              );
                            }
                            return SizedBox();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: TaskList(selectedDate: _selectedDay),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddTaskScreen()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple,
      ),
    );
  }
}
