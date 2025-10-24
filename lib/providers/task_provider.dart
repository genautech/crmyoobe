import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/storage_service.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;

  TaskProvider() {
    loadTasks();
  }

  void loadTasks() {
    final box = StorageService.getTasksBox();
    _tasks = box.values.toList();
    // Sort by due date
    _tasks.sort((a, b) => a.dueDate.compareTo(b.dueDate));
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    final box = StorageService.getTasksBox();
    await box.put(task.id, task);
    loadTasks();
  }

  Future<void> updateTask(Task task) async {
    task.updatedAt = DateTime.now();
    final box = StorageService.getTasksBox();
    await box.put(task.id, task);
    loadTasks();
  }

  Future<void> deleteTask(String id) async {
    final box = StorageService.getTasksBox();
    await box.delete(id);
    loadTasks();
  }

  Future<void> toggleTaskComplete(String id) async {
    final task = _tasks.firstWhere((t) => t.id == id);
    task.isCompleted = !task.isCompleted;
    task.status = task.isCompleted ? 'completed' : 'inProgress';
    await updateTask(task);
  }

  List<Task> getTasksByCustomer(String customerId) {
    return _tasks.where((task) => task.customerId == customerId).toList();
  }

  List<Task> getTasksByStatus(String status) {
    return _tasks.where((task) => task.status == status).toList();
  }

  List<Task> getOverdueTasks() {
    final now = DateTime.now();
    return _tasks.where((task) => 
      task.dueDate.isBefore(now) && !task.isCompleted
    ).toList();
  }

  List<Task> getTodayTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    
    return _tasks.where((task) => 
      task.dueDate.isAfter(today) && 
      task.dueDate.isBefore(tomorrow) &&
      !task.isCompleted
    ).toList();
  }
}
