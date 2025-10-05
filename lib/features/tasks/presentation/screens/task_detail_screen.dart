import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/presentation/viewmodels/task_detail_viewmodel.dart';

/// ------------------------------------------------------------------
/// タスク詳細画面
class TaskDetailScreen extends ConsumerStatefulWidget {
  final String taskId;

  const TaskDetailScreen({
    super.key,
    required this.taskId,
  });

  @override
  ConsumerState<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends ConsumerState<TaskDetailScreen> {

  // ------------------------------------------------------------------
  // プロパティ
  late TextEditingController _titleController;
  late TextEditingController _memoController;


  // ------------------------------------------------------------------
  // ライフサイクル
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _memoController = TextEditingController();
    // 次のフレームでタスクを読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskDetailViewModelProvider(widget.taskId).notifier).loadTask(widget.taskId);
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }


  // ------------------------------------------------------------------
  // レンダリング

  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(taskDetailViewModelProvider(widget.taskId));

    // エラーが発生した場合のSnackBar表示
    ref.listen(taskDetailViewModelProvider(widget.taskId), (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '閉じる',
              onPressed: () {
                ref.read(taskDetailViewModelProvider(widget.taskId).notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    // コントローラーの値をViewModelの状態と同期
    if (viewModelState.task != null) {
      _titleController.text = viewModelState.task!.title;
      _memoController.text = viewModelState.task!.memo ?? '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('タスク詳細'),
        actions: [
          IconButton(
            onPressed: _deleteTask,
            icon: const Icon(Icons.delete),
            tooltip: '削除',
          ),
        ],
      ),
      body: viewModelState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // タイトル
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'タイトル *',
                        border: OutlineInputBorder(),
                      ),
                      maxLength: 200,
                      onChanged: (value) {
                        ref.read(taskDetailViewModelProvider(widget.taskId).notifier).updateTitle(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // メモ
                    TextFormField(
                      controller: _memoController,
                      decoration: const InputDecoration(
                        labelText: 'メモ',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      maxLength: 2000,
                      onChanged: (value) {
                        ref.read(taskDetailViewModelProvider(widget.taskId).notifier).updateMemo(value);
                      },
                    ),
                    const SizedBox(height: 16),

                    // 期限
                    ListTile(
                      title: const Text('期限'),
                      subtitle: Text(
                        viewModelState.task?.dueDate != null
                            ? '${viewModelState.task!.dueDate!.year}/${viewModelState.task!.dueDate!.month}/${viewModelState.task!.dueDate!.day}'
                            : '設定なし',
                      ),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: viewModelState.task?.dueDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          ref.read(taskDetailViewModelProvider(widget.taskId).notifier).updateDueDate(date);
                        }
                      },
                    ),

                    // 優先度
                    ListTile(
                      title: const Text('優先度'),
                      subtitle: Text(_getPriorityText(viewModelState.task?.priority ?? 2)),
                      trailing: DropdownButton<int>(
                        value: viewModelState.task?.priority ?? 2,
                        onChanged: (value) {
                          ref.read(taskDetailViewModelProvider(widget.taskId).notifier).updatePriority(value!);
                        },
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('低')),
                          DropdownMenuItem(value: 2, child: Text('中')),
                          DropdownMenuItem(value: 3, child: Text('高')),
                        ],
                      ),
                    ),

                    // 完了状態
                    SwitchListTile(
                      title: const Text('完了'),
                      subtitle: Text((viewModelState.task?.completed ?? false) ? '完了済み' : '未完了'),
                      value: viewModelState.task?.completed ?? false,
                      onChanged: (value) {
                        ref.read(taskDetailViewModelProvider(widget.taskId).notifier).updateCompleted(value);
                      },
                    ),

                    const SizedBox(height: 32),

                    // 保存ボタン
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: viewModelState.isLoading ? null : _saveTask,
                        child: viewModelState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('保存'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }


  // ------------------------------------------------------------------
  // ヘルパー関数

  /// ### [Description]
  /// - タスクを保存する
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> _saveTask() async {
    final success = await ref.read(taskDetailViewModelProvider(widget.taskId).notifier).saveTask(widget.taskId);
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  /// ### [Description]
  /// - タスクを削除する
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> _deleteTask() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このタスクを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('削除'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref.read(taskDetailViewModelProvider(widget.taskId).notifier).deleteTask(widget.taskId);
      if (success && mounted) {
        Navigator.of(context).pop();
      }
    }
  }

  /// ### [Description]
  /// - 優先度のテキストを取得する
  /// 
  /// ### [Parameters]
  /// - [priority] 優先度
  /// 
  /// ### [Returns]
  /// - String
  String _getPriorityText(int priority) {
    switch (priority) {
      case 1:
        return '低';
      case 2:
        return '中';
      case 3:
        return '高';
      default:
        return '中';
    }
  }
}

