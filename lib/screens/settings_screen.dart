import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/task.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

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
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      body: Column(
        spacing: 2,
        children: [
          Text("Ustawienia aplikacji", style: TextStyle(fontSize: 18)),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
            onPressed: () =>
                _eraseDatabase(context), // Wywołanie funkcji asynchronicznej
            child: Text('Erase database'),
          ),
          ListTile(
            title: Text("Tryb ciemny"),
            trailing: Switch(
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
            ),
          ),
        ],
      ),
    );
  }
}
