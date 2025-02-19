import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task.dart';

class FirestoreDb {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _taskCollection =
      FirebaseFirestore.instance.collection('users');

  // Dodanie nowego zadania do Firestore
  Future<void> addTask(Task task) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Dodaj zadanie do podkolekcji 'tasks' użytkownika
        await _taskCollection
            .doc(user.uid)  // Dokument użytkownika
            .collection('tasks')  // Podkolekcja 'tasks'
            .add(task.toMap());
      }
    } catch (e) {
      print("Błąd dodawania zadania: $e");
    }
  }

  // Pobranie wszystkich zadań użytkownika z Firestore
  Future<List<Task>> getTasks() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        QuerySnapshot snapshot = await _taskCollection
            .doc(user.uid) // Dokument użytkownika
            .collection('tasks') // Podkolekcja 'tasks'
            .get();
        return snapshot.docs
            .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      print("Błąd pobierania zadań: $e");
      return [];
    }
  }

  // Aktualizacja zadania w Firestore
  Future<void> updateTask(String taskId, Task newTask) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _taskCollection
            .doc(user.uid)  // Dokument użytkownika
            .collection('tasks')  // Podkolekcja 'tasks'
            .doc(taskId)  // Dokument zadania
            .update(newTask.toMap());
      }
    } catch (e) {
      print("Błąd aktualizacji zadania: $e");
    }
  }

  // Usunięcie zadania z Firestore
  Future<void> deleteTask(String taskId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _taskCollection
            .doc(user.uid)  // Dokument użytkownika
            .collection('tasks')  // Podkolekcja 'tasks'
            .doc(taskId)  // Dokument zadania
            .delete();
      }
    } catch (e) {
      print("Błąd usuwania zadania: $e");
    }
  }

  // Czyszczenie wszystkich zadań (tylko dla administratorów)
  Future<void> clearAllTasks() async {
    try {
      // Pobieramy wszystkie dokumenty w kolekcji
      QuerySnapshot snapshot = await _taskCollection.get();
      for (var doc in snapshot.docs) {
        await doc.reference.delete(); // Usuwamy każdy dokument
      }
    } catch (e) {
      throw Exception("Błąd podczas czyszczenia kolekcji: $e");
    }
  }
}
