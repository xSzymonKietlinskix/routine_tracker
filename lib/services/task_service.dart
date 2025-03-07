import '../models/task.dart';
import '../db/firestore_db.dart';

class TaskService {
  final FirestoreDb firestoreDb = FirestoreDb();

  Future<Map<DateTime, List<Task>>> getTasksByDate() async {
    final tasks = await firestoreDb.getTasks();
    Map<DateTime, List<Task>> newTasksByDate = {};

    for (var task in tasks) {
      DateTime taskDate = DateTime(
        task.date!.year,
        task.date!.month,
        task.date!.day,
      );
      newTasksByDate.putIfAbsent(taskDate, () => []).add(task);
    }

    return newTasksByDate;
  }

  bool isSameDay(DateTime? date1, DateTime? date2) {
    if (date1 == null || date2 == null) return false;
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }
}
