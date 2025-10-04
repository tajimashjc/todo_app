import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  /// タスクを作成する
  @override
  Future<Task> createTask(Task task) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  /// タスクを削除
  @override
  Future<void> deleteTask(String id) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  /// タスクを取得
  @override
  Future<Task> getTask(String id) {
    // TODO: implement getTask
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> getTasks() {
    // TODO: implement getTasks
    throw UnimplementedError();
  }

  @override
  Future<Task> updateTask(Task task) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}

