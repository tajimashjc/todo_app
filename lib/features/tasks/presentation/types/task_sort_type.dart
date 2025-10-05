import 'package:flutter/material.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';

/// ------------------------------------------------------------
/// タスクのソート種類
enum TaskSortType {
  none('通常順'),
  priority('優先度順'),
  createdAt('作成日順'),
  dueDate('期限日順');

  const TaskSortType(this.displayName);
  final String displayName;

  /// ### [Description]
  /// - ソート種類に応じたアイコンを取得する
  /// 
  /// ### [Returns]
  /// - IconData
  IconData get icon {
    switch (this) {
      case TaskSortType.none:
        return Icons.sort;
      case TaskSortType.priority:
        return Icons.priority_high;
      case TaskSortType.createdAt:
        return Icons.access_time;
      case TaskSortType.dueDate:
        return Icons.event;
    }
  }

  /// ### [Description]
  /// - タスクリストをソートする
  /// 
  /// ### [Parameters]
  /// - [tasks] タスクリスト
  /// 
  /// ### [Returns]
  /// - List<Task>
  List<Task> sortTasks(List<Task> tasks) {
    if (this == TaskSortType.none) {
      return tasks;
    }

    List<Task> sortedTasks = List.from(tasks);
    
    switch (this) {
      case TaskSortType.priority:
        // 優先度の高い順（3=High, 2=Medium, 1=Low）でソート
        sortedTasks.sort((a, b) => b.priority.compareTo(a.priority));
        break;
      case TaskSortType.createdAt:
        // 作成日の新しい順でソート
        sortedTasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortType.dueDate:
        // 期限日の近い順でソート（期限なしは最後）
        sortedTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSortType.none:
        // 何もしない
        break;
    }
    
    return sortedTasks;
  }
}