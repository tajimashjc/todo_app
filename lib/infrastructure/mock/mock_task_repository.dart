import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';

/// ### [Description]
/// - TaskRepositoryのモック実装クラス
class MockTaskRepository implements TaskRepository {
  // ------------------------------------------------------------
  final List<Task> _tasks = [];  // タスク一覧（モックデータ）
  int _nextId = 1;  // 次の新規タスクID

  @override
  Future<List<Task>> getTasks() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_tasks);
  }

  @override
  Future<Task> getTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    
    final task = _tasks.firstWhere(
      (task) => task.id == id,
      orElse: () => throw Exception('Task with id $id not found'),
    );
    return task;
  }

  @override
  Future<Task> createTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 200));
    
    final newTask = task.copyWith(
      id: _nextId.toString(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _nextId++;
    _tasks.add(newTask);
    return newTask;
  }

  @override
  Future<Task> updateTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 150));
    
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index == -1) {
      throw Exception('Task with id ${task.id} not found');
    }
    
    final updatedTask = task.copyWith(updatedAt: DateTime.now());
    _tasks[index] = updatedTask;
    return updatedTask;
  }

  @override
  Future<void> deleteTask(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final index = _tasks.indexWhere((task) => task.id == id);
    if (index == -1) {
      throw Exception('Task with id $id not found');
    }
    
    _tasks.removeAt(index);
  }
}
