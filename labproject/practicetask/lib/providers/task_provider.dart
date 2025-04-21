import 'package:flutter/foundation.dart';
import '../models/task_model.dart';
import '../services/task_database.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

  Future<void> loadTasks() async {
    _tasks = await TaskDatabase.instance.getTasks();
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final id = await TaskDatabase.instance.insertTask(task);
    task.id = id;
    _tasks.add(task);
    notifyListeners();
  }

  Future<void> updateTask(Task task) async {
    await TaskDatabase.instance.updateTask(task);
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index] = task;
      notifyListeners();
    }
  }

  Future<void> deleteTask(int id) async {
    await TaskDatabase.instance.deleteTask(id);
    _tasks.removeWhere((t) => t.id == id);
    notifyListeners();
  }
}