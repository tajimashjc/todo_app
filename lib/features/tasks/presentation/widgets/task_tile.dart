import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/tasks/presentation/viewmodels/task_tile_viewmodel.dart';

class TaskTile extends ConsumerWidget {

  // ------------------------------------------------------------------
  // プロパティ
  final Task task;


  // ------------------------------------------------------------------
  // コンストラクタ
  const TaskTile({
    super.key,
    required this.task,
  });


  // ------------------------------------------------------------------
  // レンダリング
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModelState = ref.watch(taskTileViewModelProvider(task.id));
    
    // タスクをViewModelに設定（mountedチェック付き）
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (context.mounted) {
        ref.read(taskTileViewModelProvider(task.id).notifier).setTask(task);
      }
    });

    // エラーが発生した場合のSnackBar表示
    ref.listen(taskTileViewModelProvider(task.id), (previous, next) {
      if (next.errorMessage != null && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '閉じる',
              onPressed: () {
                if (!context.mounted) return;
                ref.read(taskTileViewModelProvider(task.id).notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    // 表示するタスクを決定（ViewModelの状態があればそれを使用、なければ元のタスクを使用）
    final displayTask = viewModelState.task ?? task;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        // --------------------------------------------------------------
        // チェックボックス
        leading: Checkbox(
          value: displayTask.completed,
          onChanged: viewModelState.isLoading ? null : (_) => _toggleCompleted(ref),
        ),
        // --------------------------------------------------------------
        // タイトル
        title: Text(
          displayTask.title,
          style: TextStyle(
            decoration: displayTask.completed ? TextDecoration.lineThrough : null,
            color: displayTask.completed ? Colors.grey : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --------------------------------------------------------------
            // メモ
            if (displayTask.memo != null && displayTask.memo!.isNotEmpty)
              Text(
                displayTask.memo!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: displayTask.completed ? Colors.grey : null,
                ),
              ),
            const SizedBox(height: 4),
            // --------------------------------------------------------------
            // 期限と優先度
            Row(
              children: [
                if (displayTask.dueDate != null) ...[
                  // 期限
                  Icon(
                    Icons.schedule,
                    size: 16,
                    color: _getDueDateColor(displayTask.dueDate!),
                  ),
                  const SizedBox(width: 4),
                  // 優先度
                  Text(
                    _formatDate(displayTask.dueDate!),
                    style: TextStyle(
                      color: _getDueDateColor(displayTask.dueDate!),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                ],
                _getPriorityChip(displayTask.priority),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _goToTaskDetail(context),
      ),
    );
  }


  // ------------------------------------------------------------------
  // ウィジェット構築

  /// ### [Description]
  /// - 優先度チップを取得する
  /// 
  /// ### [Parameters]
  /// - [priority] 優先度
  /// 
  /// ### [Returns]
  /// - Widget
  Widget _getPriorityChip(int priority) {
    Color color;
    String text;
    
    switch (priority) {
      case 1:
        color = Colors.green;
        text = '低';
        break;
      case 2:
        color = Colors.orange;
        text = '中';
        break;
      case 3:
        color = Colors.red;
        text = '高';
        break;
      default:
        color = Colors.grey;
        text = '中';
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }


  // ------------------------------------------------------------------
  // ヘルパー関数

  /// ### [Description]
  /// - タスク詳細画面に遷移する
  /// 
  /// ### [Parameters]
  /// - [context] コンテキスト
  /// 
  /// ### [Returns]
  /// - void
  void _goToTaskDetail(BuildContext context) {
    context.push('/task/${task.id}');
  }

  /// ### [Description]
  /// - タスクの完了状態を切り替える
  /// 
  /// ### [Parameters]
  /// - [ref] リファレンス
  /// 
  /// ### [Returns]
  /// - void
  void _toggleCompleted(WidgetRef ref) {
    ref.read(taskTileViewModelProvider(task.id).notifier).toggleCompleted(task.id);
  }

  /// ### [Description]
  /// - 期限の色を取得する
  /// 
  /// ### [Parameters]
  /// - [dueDate] 期限
  /// 
  /// ### [Returns]
  /// - Color
  Color _getDueDateColor(DateTime dueDate) {
    final now = DateTime.now();
    final difference = dueDate.difference(now).inDays;
    
    if (difference < 0) {
      return Colors.red; // 期限切れ
    } else if (difference == 0) {
      return Colors.orange; // 今日が期限
    } else if (difference <= 3) {
      return Colors.amber; // 3日以内
    } else {
      return Colors.grey; // 余裕あり
    }
  }

  /// ### [Description]
  /// - 期限のフォーマットを取得する
  /// 
  /// ### [Parameters]
  /// - [date] 期限
  /// 
  /// ### [Returns]
  /// - String
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;
    
    if (difference == 0) {
      return '今日';
    } else if (difference == 1) {
      return '明日';
    } else if (difference == -1) {
      return '昨日';
    } else if (difference > 0) {
      return '$difference日後';
    } else {
      return '$difference日前';
    }
  }
}

