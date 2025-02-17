import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../db/firestore_db.dart';
import '../auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatelessWidget {
  final FirestoreDb firestoreDb = FirestoreDb();
  final AuthService _authService = AuthService();

  Future<void> _eraseDatabase(BuildContext context) async {
    try {
      // Usuwamy wszystkie dokumenty z kolekcji 'tasks'
      await firestoreDb.clearAllTasks();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Baza danych została wyczyszczona')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas czyszczenia bazy danych')),
      );
    }
  }

  // Funkcja do wylogowania użytkownika
  Future<void> _signOut(BuildContext context) async {
    await _authService.signOut(); // Wylogowanie przez AuthService

    // Przekierowanie na ekran logowania po wylogowaniu
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Ustawienia aplikacji")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Ustawienia aplikacji", style: TextStyle(fontSize: 18)),
            SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () => _eraseDatabase(context),
              child: Text('Wyczyść bazę danych'),
            ),
            // Przycisk logowania
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue,
              ),
              onPressed: () => _signOut(context), // Wylogowanie
              child: Text('Log out'),
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
      ),
    );
  }
}
