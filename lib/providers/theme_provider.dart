import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadTheme(); // Ładujemy zapisany motyw przy starcie aplikacji
  }

  Future<void> toggleTheme(bool isDark) async {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();

    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String userId = currentUser.uid; // Poprawione pobranie UID użytkownika

      try {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('settings')
            .doc('theme')
            .set({
          'isDarkMode': isDark,
        });
      } catch (e) {
        developer.log("Error while saving theme: $e", name: "ThemeProvider");
      }
    }
  }

  Future<void> _loadTheme() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    String userId = currentUser.uid; // Poprawione pobranie UID użytkownika

    try {
      DocumentSnapshot docSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('theme')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        bool isDarkMode =
            (docSnapshot.data() as Map<String, dynamic>)['isDarkMode'] ?? false;
        _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
        notifyListeners();
      }
    } catch (e) {
      developer.log("Error while loading theme: $e", name: "ThemeProvider");
      _themeMode = ThemeMode.light;
      notifyListeners();
    }
  }
}
