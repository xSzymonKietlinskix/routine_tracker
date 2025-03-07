import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';
import 'dart:developer' as developer;
import '../db/firestore_db.dart';

class TaskList extends StatelessWidget {
  final DateTime selectedDate;

  TaskList({required this.selectedDate});

  @override
  Widget build(BuildContext context) {
    // Ustawiamy godzinę na 00:00:00 dla selectedDate
    DateTime startOfDay =
        DateTime(selectedDate.year, selectedDate.month, selectedDate.day);

    // Ustawiamy godzinę na 23:59:59 dla końca dnia
    DateTime endOfDay =
        startOfDay.add(Duration(days: 1)).subtract(Duration(milliseconds: 1));

    // Pobieramy aktualnie zalogowanego użytkownika
    User? currentUser = FirebaseAuth.instance.currentUser;

    // Sprawdzamy, czy użytkownik jest zalogowany
    if (currentUser == null) {
      return Center(child: Text("Zaloguj się, aby zobaczyć zadania"));
    }

    // Używamy UID użytkownika, aby pobrać jego zadania
    String userId = currentUser.uid;

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        var allTasks = snapshot.data!.docs.map((doc) {
          return Task.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        var oneTimeTasks = allTasks.where((task) => !task.recurring).toList()
          ..sort((a, b) {
            // Jeśli jedno z zadań nie ma priorytetu (np. null, 0, -1), traktuj je jako najniższy priorytet
            int priorityA = a.priority ??
                -1; // Jeżeli nie ma priorytetu, traktuj jako najniższy
            int priorityB = b.priority ??
                -1; // Jeżeli nie ma priorytetu, traktuj jako najniższy

            // Najpierw sortowanie według priorytetu (od najwyższego do najniższego)
            int priorityComparison = priorityB.compareTo(priorityA);
            if (priorityComparison != 0) {
              return priorityComparison;
            }
            // Jeśli priorytety są równe, sortowanie według nazwy
            return a.name.compareTo(b.name);
          });

        var recurringTasks = allTasks.where((task) => task.recurring).toList()
          ..sort((a, b) {
            // Jeśli jedno z zadań nie ma priorytetu (np. null, 0, -1), traktuj je jako najniższy priorytet
            int priorityA = a.priority ??
                -1; // Jeżeli nie ma priorytetu, traktuj jako najniższy
            int priorityB = b.priority ??
                -1; // Jeżeli nie ma priorytetu, traktuj jako najniższy

            // Najpierw sortowanie według priorytetu (od najwyższego do najniższego)
            int priorityComparison = priorityB.compareTo(priorityA);
            if (priorityComparison != 0) {
              return priorityComparison;
            }
            // Jeśli priorytety są równe, sortowanie według nazwy
            return a.name.compareTo(b.name);
          });

        return ListView(
          shrinkWrap: true,
          children: [
            if (oneTimeTasks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Single tasks:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...oneTimeTasks
                  .map((task) => buildTaskItem(task, userId, context))
                  .toList(),
            ],
            if (recurringTasks.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  "Routine:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              ...recurringTasks
                  .map((task) => buildTaskItem(task, userId, context))
                  .toList(),
            ],
          ],
        );
      },
    );
  }

  Widget buildTaskItem(Task task, String userId, BuildContext context) {
    Future<void> singleDeleteDialog(context, userId, task) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Do you want to delete task?'),
            content: const SingleChildScrollView(),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Delete'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteSingleTask(userId, task);
                },
              ),
            ],
          );
        },
      );
    }

    Future<void> recurringDeleteDialog(context, userId, task) async {
      return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Do you want to delete one task or all of them?'),
            content: const SingleChildScrollView(),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('One'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteSingleTask(userId, task);
                },
              ),
              TextButton(
                child: const Text('All'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _deleteAllRerecurringTasks(userId, task);
                },
              ),
            ],
          );
        },
      );
    }

    return Dismissible(
      key: Key(task.name + task.date.toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (!task.recurring) {
          singleDeleteDialog(context, userId, task);
        } else {
          recurringDeleteDialog(context, userId, task);
        }
      },
      child: ListTile(
        title: AnimatedDefaultTextStyle(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            color: task.isCompleted
                ? Theme.of(context).disabledColor // Kolor dla ukończonych zadań
                : Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.color, // Domyślny kolor tekstu
            fontSize: 16.0,
          ),
          child: Text(task.name),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.category != null)
              Text(
                task.category!,
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
            if (task.priority != null)
              Text(
                'Priority: ${task.priority}',
                style: TextStyle(
                  fontSize: 14.0,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        trailing: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            task.isCompleted = value ?? false;
            _updateTask(userId, task);
          },
        ),
      ),
    );
  }

  Future<void> _updateTask(String userId, Task task) async {
    try {
      Timestamp _date = Timestamp.fromDate(task.date!);
      var taskDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('tasks')
          .where('name', isEqualTo: task.name)
          .where('date', isEqualTo: _date)
          .get();

      FirestoreDb firestoreDb = FirestoreDb();
      firestoreDb.getTasksToBeDoneForToday();

      if (taskDoc.docs.isNotEmpty) {
        // Aktualizujemy zadanie
        await taskDoc.docs.first.reference.update({
          'isCompleted': task.isCompleted,
        });
      }
    } catch (e) {
      developer.log("Błąd aktualizacji zadania: $e", name: "TaskList");
    }
  }
}

Future<void> _deleteSingleTask(String userId, Task task) async {
  try {
    Timestamp _date = Timestamp.fromDate(task.date!);
    var taskDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('name', isEqualTo: task.name)
        .where('date', isEqualTo: _date)
        .get();

    FirestoreDb firestoreDb = FirestoreDb();
    firestoreDb.getTasksToBeDoneForToday();

    if (taskDoc.docs.isNotEmpty) {
      await taskDoc.docs.first.reference.delete();
    }
  } catch (e) {
    developer.log("Błąd usuwania zadania: $e", name: "TaskList");
  }
}

Future<void> _deleteAllRerecurringTasks(String userId, Task task) async {
  try {
    var taskDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('tasks')
        .where('name', isEqualTo: task.name)
        .get();

    for (var t in taskDoc.docs) {
      await t.reference.delete();
    }

    FirestoreDb firestoreDb = FirestoreDb();
    firestoreDb.getTasksToBeDoneForToday();
  } catch (e) {
    developer.log("Błąd usuwania zadań: $e", name: "TaskList");
  }
}
