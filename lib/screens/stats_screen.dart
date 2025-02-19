import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../db/firestore_db.dart';
import '../widgets/chart.dart';
import '../widgets/streak_list.dart';
import '../widgets/animated_streak.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({Key? key}) : super(key: key);

  @override
  _StatsScreenState createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final FirestoreDb firestoreDb = FirestoreDb();
  List<Task> tasks = [];
  List<Task> uniqueTasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Pobierz zadania
  Future<void> _loadTasks() async {
    final fetchedTasks = await firestoreDb.getTasks();
    setState(() {
      tasks = fetchedTasks;
    });
    findUniqueTasks();
  }

  // Funkcja do generowania wykresu aktywności w ostatnim tygodniu
  List<Map<String, int>> generateActivityChartData() {
    DateTime now = DateTime.now();
    DateTime startDate =
        DateTime(now.year, now.month, now.day - 6, 0, 0, 1); // 7 dni wstecz
    DateTime endDate =
        DateTime(now.year, now.month, now.day, 23, 59, 59); // Dziś wieczór

    Map<DateTime, int> taskCount = {};
    Map<DateTime, int> completedTaskCount = {};

    // Inicjalizacja map dla każdego dnia z przedziału
    for (int i = 0; i < 7; i++) {
      DateTime day = startDate.add(Duration(days: i));
      taskCount[day] = 0;
      completedTaskCount[day] = 0;
    }

    // Zliczanie tasków
    for (var t in tasks) {
      if (t.date == null) continue; // Bezpieczne sprawdzenie
      DateTime taskDate =
          DateTime(t.date!.year, t.date!.month, t.date!.day, 0, 0, 1);

      if (taskDate.isBefore(startDate) || taskDate.isAfter(endDate)) continue;

      taskCount.update(taskDate, (value) => value + 1);
      if (t.isCompleted) {
        completedTaskCount.update(taskDate, (value) => value + 1);
      }
    }

    // Konwersja do listy
    List<Map<String, int>> taskData = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = startDate.add(Duration(days: i));
      taskData.add({
        'total': taskCount[day] ?? 0,
        'done': completedTaskCount[day] ?? 0,
      });
    }

    return taskData;
  }

  Future<void> findUniqueTasks() async {
    Set<String> seenNames = {}; // Zbiór do śledzenia nazw
    List<Task> buffor = [];

    for (var t in tasks) {
      if (t.recurring && !seenNames.contains(t.name)) {
        seenNames.add(t.name); // Dodaj nazwę do zbioru
        buffor.add(t); // Dodaj unikalne zadanie do listy
      }
    }

    setState(() {
      uniqueTasks = buffor;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: MediaQuery.of(context).size.height * 0.5,

              floating: false, // Chcemy, żeby AppBar się zwijał
              pinned: true, // Trzymamy AppBar na górze
              flexibleSpace: FlexibleSpaceBar(
                // title: Text("Stats"),

                background: Column(
                  children: [
                    SizedBox(height: 20.0), // Pusty box jako odstęp
                    TaskBarChart(taskData: generateActivityChartData()),
                  ],
                ), // Wykres, który się chowa
              ),
            ),
          ];
        },
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedStreakText(),
              SizedBox(height: 8),
              StreakWidget(
                uniqueTasks: uniqueTasks,
                tasks: tasks,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
