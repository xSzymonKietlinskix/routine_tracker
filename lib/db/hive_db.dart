import 'package:hive/hive.dart';
import '../models/task.dart';

class HiveDb{
  final Box<Task> taskBox = Hive.box<Task>('tasks');

  Future<void> addTask(Task task) async{
    await taskBox.add(task);
  }

  List<Task> getTasks() {
    return taskBox.values.toList();
  }

   Future<void> updateTask(int index, Task newTask) async {
    await taskBox.putAt(index, newTask);
  }

  Future<void> deleteTask(int index) async {
    await taskBox.deleteAt(index);
  }
}