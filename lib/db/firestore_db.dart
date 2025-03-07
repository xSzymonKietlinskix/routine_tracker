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
            .doc(user.uid) // Dokument użytkownika
            .collection('tasks') // Podkolekcja 'tasks'
            .add(task.toMap());

        await getTasksToBeDoneForToday();
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

  Future<int> getTasksToBeDoneForToday() async {
    try {
      final user = _auth.currentUser;
      DateTime _today = DateTime.now();
      DateTime today = DateTime(_today.year, _today.month, _today.day);

      if (user != null) {
        QuerySnapshot snapshot = await _taskCollection
            .doc(user.uid) // Dokument użytkownika
            .collection('tasks') // Podkolekcja 'tasks'
            .get();

        int taskCount = snapshot.docs
            .map((doc) => Task.fromMap(doc.data() as Map<String, dynamic>))
            .where((task) =>
                task.date!.year == today.year &&
                task.date!.month == today.month &&
                task.date!.day == today.day &&
                task.isCompleted == false)
            .length;

        updateTasksForToday(taskCount);
        return taskCount;
      }
      return 0;
    } catch (e) {
      print("Błąd pobierania zadań: $e");
      return 0;
    }
  }

  // Aktualizacja zadania w Firestore
  Future<void> updateTask(String taskId, Task newTask) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _taskCollection
            .doc(user.uid) // Dokument użytkownika
            .collection('tasks') // Podkolekcja 'tasks'
            .doc(taskId) // Dokument zadania
            .update(newTask.toMap());
        await getTasksToBeDoneForToday();
      }
    } catch (e) {
      print("Błąd aktualizacji zadania: $e");
    }
  }

  Future<void> updateTasksForToday(int tasksToBeDone) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _taskCollection
            .doc(user.uid) // Dokument użytkownika
            .collection('info') // Podkolekcja 'info'
            .doc('tasksForToday') // Dokument 'tasksForToday'
            .set({'count': tasksToBeDone},
                SetOptions(merge: false)); // Aktualizacja lub utworzenie
      }
    } catch (e) {
      print("Błąd aktualizacji licznika zadań: $e");
    }
  }

  // Usunięcie zadania z Firestore
  Future<void> deleteTask(String taskId) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _taskCollection
            .doc(user.uid) // Dokument użytkownika
            .collection('tasks') // Podkolekcja 'tasks'
            .doc(taskId) // Dokument zadania
            .delete();
        await getTasksToBeDoneForToday();
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
      await getTasksToBeDoneForToday();
    } catch (e) {
      throw Exception("Błąd podczas czyszczenia kolekcji: $e");
    }
  }

  // Pobranie kategorii z Firestore
  Future<List<String>> getCategories() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentSnapshot snapshot = await _taskCollection
            .doc(user.uid) // Dokument użytkownika
            .collection('info') // Podkolekcja 'info'
            .doc('categories') // Dokument 'categories'
            .get();

        if (snapshot.exists) {
          List<dynamic> categories = snapshot['categories'] ?? [];
          return List<String>.from(categories);
        }
      }
      return [];
    } catch (e) {
      print("Błąd pobierania kategorii: $e");
      return [];
    }
  }

  // Dodanie nowej kategorii do Firestore
  Future<void> addCategory(String category) async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        DocumentReference categoryDoc = _taskCollection
            .doc(user.uid) // Dokument użytkownika
            .collection('info') // Podkolekcja 'info'
            .doc('categories'); // Dokument 'categories'

        // Pobieramy aktualny stan kategorii
        DocumentSnapshot snapshot = await categoryDoc.get();
        List<String> categories = [];

        if (snapshot.exists) {
          categories = List<String>.from(snapshot['categories'] ?? []);
        }

        // Dodajemy nową kategorię
        if (!categories.contains(category)) {
          categories.add(category);
          await categoryDoc
              .set({'categories': categories}, SetOptions(merge: true));
        }
      }
    } catch (e) {
      print("Błąd dodawania kategorii: $e");
    }
  }
}
