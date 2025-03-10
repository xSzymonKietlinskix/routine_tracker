import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'add_task_screen.dart';
import '../widgets/task_list.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _selectedDay = DateTime.now();
  ValueNotifier<Map<DateTime, List<Task>>> _tasksByDate = ValueNotifier({});

  final TaskService taskService = TaskService();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  void _loadTasks() async {
    _tasksByDate.value = await taskService.getTasksByDate();
  }

  bool _hasTasks(DateTime day) {
    if (_tasksByDate.value
        .containsKey(DateTime(day.year, day.month, day.day))) {
      return true;
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
                          selectedDecoration: BoxDecoration(
                            color: Color.fromARGB(185, 131, 31, 162),
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: TextStyle(
                            color: Theme.of(context).brightness ==
                                    Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          weekendTextStyle: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.pinkAccent
                                    : Colors.pink,
                          ),
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
                                    color: Colors.purple,
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
              MaterialPageRoute(
                  builder: (context) =>
                      AddTaskScreen(selectedDate: _selectedDay)),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Color.fromARGB(185, 131, 31, 162)),
    );
  }
}