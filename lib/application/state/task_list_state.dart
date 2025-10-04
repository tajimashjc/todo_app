import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/entities/task.dart';

/// ------------------------------------------------------------
/// タスク一覧のプロバイダ
final taskListNotifierProvider = NotifierProvider<TaskListNotifier, List<Task>>(() {
  return TaskListNotifier();
});

class TaskListNotifier extends Notifier<List<Task>> {
  @override
  List<Task> build() => [];

  /// ------------------------------------------------------------------
  /// タスク一覧をプロバイダにセットする。
  /// 
  /// ### [Parameters]
  /// - [taskList] タスク一覧
  /// 
  /// ### [Returns]
  /// - void
  Future<void> setTaskList(List<Task> taskList) async {
    state = taskList;
  }
}