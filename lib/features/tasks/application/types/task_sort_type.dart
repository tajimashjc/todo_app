import 'package:flutter/material.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';

/// ------------------------------------------------------------
/// タスクのソート種類
enum TaskSortType {
  createdAt('作成日順'),
  priority('優先度順'),
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
      case TaskSortType.createdAt:
        return Icons.access_time;
      case TaskSortType.priority:
        return Icons.priority_high;
      case TaskSortType.dueDate:
        return Icons.event;
    }
  }

  /// ### [Description]
  /// - タスクリストをソートする
  /// 
  /// ### [Parameters]
  /// - [tasks] タスクリスト
  /// - [isAscending] 昇順かどうか（デフォルト: false）
  /// 
  /// ### [Returns]
  /// - List<Task>
  List<Task> sortTasks(List<Task> tasks, {bool isAscending = false}) {
    List<Task> sortedTasks = List.from(tasks);
    
    switch (this) {
      case TaskSortType.priority:
        // 優先度でソート（昇順: 低→高、降順: 高→低）
        sortedTasks.sort((a, b) => isAscending 
          ? a.priority.compareTo(b.priority)
          : b.priority.compareTo(a.priority));
        break;
      case TaskSortType.createdAt:
        // 作成日でソート（昇順: 古い→新しい、降順: 新しい→古い）
        sortedTasks.sort((a, b) => isAscending 
          ? a.createdAt.compareTo(b.createdAt)
          : b.createdAt.compareTo(a.createdAt));
        break;
      case TaskSortType.dueDate:
        // 期限日でソート（期限なしは最後）
        sortedTasks.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return isAscending 
            ? a.dueDate!.compareTo(b.dueDate!)
            : b.dueDate!.compareTo(a.dueDate!);
        });
        break;
    }
    
    return sortedTasks;
  }
}