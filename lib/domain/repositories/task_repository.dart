import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/entities/task.dart';

final taskRepositoryProvider = Provider<TaskRepository>(
  (_) => throw UnimplementedError(),
);

abstract interface class TaskRepository {
  /// タスク一覧を取得
  Future<List<Task>> getTasks();

  /// タスクを取得
  Future<Task> getTask(String id);

  /// タスクを作成
  Future<Task> createTask(Task task);

  /// タスクを更新
  Future<Task> updateTask(Task task);

  /// タスクを削除
  Future<void> deleteTask(String id);
}

