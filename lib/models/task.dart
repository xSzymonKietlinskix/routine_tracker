import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class Task {
  String name;
  bool recurring;
  DateTime? date;
  List<int>? daysOfWeek;
  TimeOfDay? time;
  bool isCompleted;
  int streak;
  int? recurringMonths;
  String? category; // Nowe pole kategorii (opcjonalne)
  int? priority; // Nowe pole istotności (opcjonalne)

  Task({
    required this.name,
    required this.recurring,
    this.date,
    this.daysOfWeek,
    this.time,
    this.streak = 0,
    this.isCompleted = false,
    this.recurringMonths,
    this.category, // Opcjonalne
    this.priority, // Opcjonalne
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      name: map['name'],
      recurring: map['recurring'],
      date: (map['date'] as Timestamp?)?.toDate(),
      daysOfWeek: List<int>.from(map['daysOfWeek'] ?? []),
      time: map['time'] != null
          ? TimeOfDay(hour: map['time']['hour'], minute: map['time']['minute'])
          : null,
      isCompleted: map['isCompleted'] ?? false,
      streak: map['streak'] ?? 0,
      recurringMonths: map['recurringMonths'],
      category: map['category'], // Odczyt kategorii
      priority: map['priority'], // Odczyt istotności
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'recurring': recurring,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'time':
          time != null ? {'hour': time!.hour, 'minute': time!.minute} : null,
      'isCompleted': isCompleted,
      'streak': streak,
      'recurringMonths': recurringMonths,
      'category': category, // Zapis kategorii
      'priority': priority, // Zapis istotności
    };
  }

  List<DateTime> generateRecurringTasks() {
    List<DateTime> generatedDates = [];

    if (recurringMonths != null && recurringMonths! > 0 && daysOfWeek != null) {
      DateTime startDate = DateTime.now();

      for (int i = 0; i < recurringMonths!; i++) {
        DateTime monthStart = DateTime(startDate.year, startDate.month + i, 1);
        if (i == 0) {
          monthStart = DateTime(startDate.year, startDate.month, startDate.day);
        }

        for (int dayOfWeek in daysOfWeek!) {
          DateTime nextDayOfWeek = _getNextDayOfWeek(monthStart, dayOfWeek);
          while (nextDayOfWeek.month == monthStart.month) {
            generatedDates.add(nextDayOfWeek);
            nextDayOfWeek = nextDayOfWeek.add(Duration(days: 7));
          }
        }
      }
    }

    return generatedDates;
  }

  DateTime _getNextDayOfWeek(DateTime startOfMonth, int targetWeekday) {
    if (startOfMonth.weekday == targetWeekday) {
      return startOfMonth;
    }
    int daysToAdd = (targetWeekday - startOfMonth.weekday + 7) % 7;
    if (daysToAdd == 0) {
      daysToAdd = 7;
    }
    return startOfMonth.add(Duration(days: daysToAdd));
  }
}
