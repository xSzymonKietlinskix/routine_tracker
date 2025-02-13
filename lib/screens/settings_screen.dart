import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';

class SettingsScreen extends StatelessWidget {
  Future<void> _eraseDatabase(BuildContext context) async {
    await Hive.deleteBoxFromDisk('tasks'); // Usuń bazę danych
    await Hive.openBox<Task>('tasks'); // Poczekaj, aż się otworzy ponownie

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Baza danych została wyczyszczona')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Text("Ustawienia aplikacji", style: TextStyle(fontSize: 18)),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            onPressed: () => _eraseDatabase(context), // Wywołanie funkcji asynchronicznej
            child: Text('Erase database'),
          )
        ],
      ),
    );
  }
}
