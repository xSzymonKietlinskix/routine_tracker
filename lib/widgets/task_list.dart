import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

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
          .collection('users') // Kolekcja użytkowników
          .doc(userId) // Dokument użytkownika
          .collection('tasks') // Podkolekcja z zadaniami
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        // Konwertujemy dane z Firestore do obiektów Task
        var tasksForDay = snapshot.data!.docs.map((doc) {
          return Task.fromMap(doc.data() as Map<String, dynamic>);
        }).toList();

        return ListView.builder(
          itemCount: tasksForDay.length,
          itemBuilder: (context, index) {
            Task task = tasksForDay[index];
            return ListTile(
              title: Text(task.name),
              trailing: Checkbox(
                value: task.isCompleted,
                onChanged: (bool? value) {
                  task.isCompleted = value ?? false;
                  _updateTask(userId, task); // Przekazujemy UID użytkownika
                },
              ),
            );
          },
        );
      },
    );
  }

  // Funkcja do aktualizacji zadania w Firestore
  Future<void> _updateTask(String userId, Task task) async {
    try {
      // Znajdujemy dokument zadania po ID
      var taskDoc = await FirebaseFirestore.instance
          .collection('users') // Kolekcja użytkowników
          .doc(userId) // Dokument użytkownika
          .collection('tasks') // Podkolekcja z zadaniami
          .where('name', isEqualTo: task.name) // Wyszukiwanie po nazwie
          .get();

      if (taskDoc.docs.isNotEmpty) {
        // Aktualizujemy zadanie
        await taskDoc.docs.first.reference.update({
          'isCompleted': task.isCompleted,
        });
      }
    } catch (e) {
      print("Błąd aktualizacji zadania: $e");
    }
  }
}
