import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // Ładujemy zapisany motyw przy starcie aplikacji
  }

  void toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    // Zapisz motyw w Firebase
    await _firestore.collection('settings').doc('theme').set({
      'isDarkMode': isDark,
    });
  }

  void _loadTheme() async {
    // Pobierz motyw z Firebase
    try {
      DocumentSnapshot docSnapshot = await _firestore.collection('settings').doc('theme').get();

      if (docSnapshot.exists) {
        bool isDarkMode = docSnapshot['isDarkMode'] ?? false;
        _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    } catch (e) {
      // Jeśli wystąpił błąd, możesz ustawić domyślny motyw
      _themeMode = ThemeMode.light;
      notifyListeners();
    }
  }
}
