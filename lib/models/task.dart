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
  List<int>? daysOfWeek;

  @HiveField(4)
  TimeOfDay? time;

  @HiveField(5)
  bool isCompleted;

  @HiveField(6)
  int streak;

  Task({
    required this.name,
    required this.recurring,
    this.date,
    this.daysOfWeek,
    this.time,
    this.streak = 0,
    this.isCompleted = false,
  });

   bool isForDate(DateTime selectedDate) {
    if (date != null && !recurring) {
      return date!.year == selectedDate.year &&
             date!.month == selectedDate.month &&
             date!.day == selectedDate.day;
    }
    else if (daysOfWeek != null && recurring) {
      return daysOfWeek!.contains(selectedDate.weekday);
    }
    return false;
  }
}
