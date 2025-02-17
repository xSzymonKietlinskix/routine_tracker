import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import '../db/firestore_db.dart';
import '../widgets/chart.dart';
import '../widgets/streak_list.dart';

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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Stats")),
//       body: Padding(
//         padding: const EdgeInsets.all(5.0),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           TaskBarChart(tasks: tasks),
//           StreakWidget(uniqueTasks: uniqueTasks, tasks: tasks),
//         ]),
//       ),
//     );
//   }
// }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 600.0, // Ustal wysokość wykresu
              floating: false, // Chcemy, żeby AppBar się zwijał
              pinned: true, // Trzymamy AppBar na górze
              flexibleSpace: FlexibleSpaceBar(
                // title: Text("Stats"),
                background:
                    TaskBarChart(tasks: tasks), // Wykres, który się chowa
              ),
            ),
          ];
        },
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Streak",
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium, // Możesz zmienić styl tytułu, np. headline6
              ),
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
