import 'package:hive/hive.dart';

part 'task.g.dart';

@HiveType(typeId: 0)
class Task {
  @HiveField(0)
  String title;

  @HiveField(1)
  String description;

  @HiveField(2)
  String type; //single or recurring

  @HiveField(3)
  String? date;

  @HiveField(4)
  List<int>? daysOfWeek;

  @HiveField(5)
  String? time;

  @HiveField(6)
  int streak;

  Task({
    required this.title,
    required this.description,
    required this.type,
    this.date,
    this.daysOfWeek,
    this.time,
    this.streak = 0,
  });
}
