import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../db/firestore_db.dart';

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
  List<FlSpot> _generateActivityChartData() {
    Map<DateTime, int> taskCount = {};
    Map<DateTime, int> completedTaskCount = {};

    DateTime oneWeekAgo = DateTime.now().subtract(Duration(days: 7));
    for (var task in tasks) {
      if (task.date != null && task.date!.isAfter(oneWeekAgo)) {
        DateTime taskDate =
            DateTime(task.date!.year, task.date!.month, task.date!.day);
        taskCount[taskDate] = (taskCount[taskDate] ?? 0) + 1;
        if (task.isCompleted) {
          completedTaskCount[taskDate] =
              (completedTaskCount[taskDate] ?? 0) + 1;
        }
      }
    }

    // Generujemy dane do wykresu
    List<FlSpot> spots = [];
    for (int i = 0; i < 7; i++) {
      DateTime date = DateTime.now().subtract(Duration(days: i));
      int totalTasks = taskCount[date] ?? 0;
      int completedTasks = completedTaskCount[date] ?? 0;
      spots.add(FlSpot(i.toDouble(), totalTasks.toDouble()));
      spots.add(FlSpot(i.toDouble(), completedTasks.toDouble()));
    }

    return spots;
  }

  // Funkcja do obliczenia steak zadania
  int _calculateStreak(Task task) {
    int streak = 0;
    DateTime currentDate = DateTime.now();
    List<Task> recurringTasks = [];
    for (var t in tasks) {
      if (t.name == task.name && t.recurring) {
        recurringTasks.add(t);
      }
    }

    recurringTasks.sort((a, b) {
      int dateComparison = a.date!.compareTo(b.date!);
      if (dateComparison != 0) {
        return dateComparison; // Sortowanie po dacie
      }
      return b.isCompleted ? 1 : 0 - (a.isCompleted ? 1 : 0);
    });

    for (var t in recurringTasks) {
      if (t.date!.isAfter(DateTime.now())) {
        break;
      }
      if (t.isCompleted) {
        streak += 1;
      } else if (t.date!.isBefore(DateTime.now())) {
        streak = 0;
      }
    }

    return streak;
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
    print(uniqueTasks.length);
    return Scaffold(
      appBar: AppBar(title: Text("Stats")),
      body: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // // 1. Wykres aktywności
            // Text("Weekly Activity Chart",
            //     style: Theme.of(context).textTheme.headlineMedium),
            // SizedBox(height: 5),
            // tasks.isEmpty
            //     ? Center(child: CircularProgressIndicator())
            //     : AspectRatio(
            //         aspectRatio: 1.5,
            //         child: LineChart(
            //           LineChartData(
            //             gridData: FlGridData(show: false),
            //             titlesData: FlTitlesData(show: true),
            //             borderData: FlBorderData(show: true),
            //             lineBarsData: [
            //               LineChartBarData(
            //                 spots: _generateActivityChartData(),
            //                 isCurved: true,

            //                 //color: blue
            //                 belowBarData: BarAreaData(show: false),
            //               ),
            //             ],
            //           ),
            //         ),
            //       ),
            // SizedBox(height: 16),

            // 2. Streak dla powtarzającego się zadania
            Text("Streak", style: Theme.of(context).textTheme.headlineMedium),
            SizedBox(height: 8),
            uniqueTasks.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: uniqueTasks.map((task) {
                      int streak = _calculateStreak(task);
                      return ListTile(
                        title: Text(task.name),
                        subtitle: Text("Streak: $streak days"),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}
