import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String name;

  @HiveField(1)
  bool recurring;

  @HiveField(2)
  DateTime? date;

  @HiveField(3)
  List<int>? daysOfWeek; // List of days of the week (1 = Monday, 7 = Sunday)

  @HiveField(4)
  TimeOfDay? time;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  int streak;

  @HiveField(7)
  int? recurringMonths; // Number of months the task repeats

  Task({
    required this.name,
    required this.recurring,
    this.date,
    this.daysOfWeek,
    this.time,
    this.streak = 0,
    this.isCompleted = false,
    this.recurringMonths,
  });

  bool isForDate(DateTime selectedDate) {
    if (date != null && !recurring) {
      return date!.year == selectedDate.year &&
          date!.month == selectedDate.month &&
          date!.day == selectedDate.day;
    } else if (daysOfWeek != null && recurring) {
      return daysOfWeek!.contains(selectedDate.weekday);
    }
    return false;
  }

  List<DateTime> generateRecurringTasks() {
    List<DateTime> generatedDates = [];

    if (recurringMonths != null && recurringMonths! > 0 && daysOfWeek != null) {
      DateTime startDate = DateTime.now(); // Rozpoczynamy od dzisiejszej daty

      for (int i = 0; i < recurringMonths!; i++) {
        // Dla każdego miesiąca
        DateTime monthStart = DateTime(startDate.year, startDate.month + i, 1);

        // Generujemy daty dla każdego dnia tygodnia w miesiącu
        for (int dayOfWeek in daysOfWeek!) {
          // Generujemy daty dla każdego tygodnia w miesiącu
          DateTime nextDayOfWeek =
              _getNextDayOfWeekInMonth(monthStart, dayOfWeek);

          // Generujemy wszystkie dni w tygodniu w danym miesiącu
          while (nextDayOfWeek.month == monthStart.month) {
            generatedDates.add(nextDayOfWeek);
            nextDayOfWeek = nextDayOfWeek
                .add(Duration(days: 7)); // Dodajemy kolejny tydzień
          }
        }
      }
    }

    return generatedDates;
  }

  DateTime _getNextDayOfWeekInMonth(DateTime startOfMonth, int targetWeekday) {
    // Szukamy pierwszego dnia tygodnia (poniedziałek, wtorek, itd.) w danym miesiącu
    DateTime firstDayOfMonth =
        DateTime(startOfMonth.year, startOfMonth.month, 1);

    // Obliczamy, ile dni musimy dodać, aby dotrzeć do pierwszego wystąpienia szukanego dnia tygodnia
    int daysToAdd = (targetWeekday - firstDayOfMonth.weekday + 7) % 7;
    DateTime firstTargetDay = firstDayOfMonth.add(Duration(days: daysToAdd));

    return firstTargetDay;
  }
}
