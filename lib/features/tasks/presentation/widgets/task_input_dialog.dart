import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/presentation/viewmodels/task_input_viewmodel.dart';

class TaskInputDialog extends ConsumerStatefulWidget {
  const TaskInputDialog({super.key});

  @override
  ConsumerState<TaskInputDialog> createState() => _TaskInputDialogState();
}

class _TaskInputDialogState extends ConsumerState<TaskInputDialog> {

  // ------------------------------------------------------------------
  // 変数
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _memoController = TextEditingController();
  

  // ------------------------------------------------------------------
  // ライフサイクル
  @override
  void initState() {
    super.initState();
    // 次のフレームでViewModelをリセット
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskInputViewModelProvider.notifier).reset();
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
    final viewModelState = ref.watch(taskInputViewModelProvider);

    // エラーが発生した場合のSnackBar表示
    ref.listen(taskInputViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '閉じる',
              onPressed: () {
                ref.read(taskInputViewModelProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return AlertDialog(
      title: const Text('新しいタスク'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // タイトル
              _TitleField(
                controller: _titleController,
                onChanged: (value) {
                  ref.read(taskInputViewModelProvider.notifier).updateTitle(value);
                },
              ),
              const SizedBox(height: 16),
              // メモ
              _MemoField(
                controller: _memoController,
                onChanged: (value) {
                  ref.read(taskInputViewModelProvider.notifier).updateMemo(value);
                },
              ),
              const SizedBox(height: 16),
              // 期限
              _DueDateField(
                dueDate: viewModelState.dueDate,
                onDateChanged: (date) {
                  ref.read(taskInputViewModelProvider.notifier).updateDueDate(date);
                },
                onDateCleared: () {
                  ref.read(taskInputViewModelProvider.notifier).updateDueDate(null);
                },
              ),
              const SizedBox(height: 16),
              // 優先度
              _PriorityField(
                priority: viewModelState.priority,
                onPriorityChanged: (priority) {
                  ref.read(taskInputViewModelProvider.notifier).updatePriority(priority);
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: viewModelState.isLoading ? null : () => Navigator.of(context).pop(),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: viewModelState.isLoading ? null : _createTask,
          child: viewModelState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('作成'),
        ),
      ],
    );
  }


  // ------------------------------------------------------------------
  // ヘルパー関数

  /// ### [Description]
  /// - タスクを作成する
  /// 
  /// ### [Returns]
  /// - void
  Future<void> _createTask() async {
    // バリデーション
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // ViewModelを使用してタスクを作成
    final task = await ref.read(taskInputViewModelProvider.notifier).createTask();
    
    if (task != null && mounted) {
      Navigator.of(context).pop(task);
    }
  }
}

/// タイトル入力フィールド
class _TitleField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _TitleField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'タイトル',
        border: OutlineInputBorder(),
      ),
      maxLength: 200,
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'タイトルを入力してください';
        }
        return null;
      },
    );
  }
}

/// メモ入力フィールド
class _MemoField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _MemoField({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'メモ',
        border: OutlineInputBorder(),
        helperText: '任意のメモを入力できます',
      ),
      maxLines: 3,
      maxLength: 2000,
      onChanged: onChanged,
      validator: (value) {
        if (value != null && value.length > 2000) {
          return 'メモは2000文字以内で入力してください';
        }
        return null;
      },
    );
  }
}

/// 期限選択フィールド
class _DueDateField extends StatelessWidget {
  final DateTime? dueDate;
  final ValueChanged<DateTime?> onDateChanged;
  final VoidCallback onDateCleared;

  const _DueDateField({
    required this.dueDate,
    required this.onDateChanged,
    required this.onDateCleared,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('期限'),
      subtitle: Text(
        dueDate != null
            ? _formatDateTime(dueDate!)
            : '設定なし',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (dueDate != null)
            IconButton(
              onPressed: onDateCleared,
              icon: const Icon(Icons.clear),
              tooltip: '期限をクリア',
            ),
          const Icon(Icons.calendar_today),
        ],
      ),
      onTap: () async {
        await _showDateTimePicker(context);
      },
    );
  }

  /// 日時選択ダイアログを表示
  Future<void> _showDateTimePicker(BuildContext context) async {
    // 日付選択
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: dueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      // 時刻選択
      final selectedTime = await _showTimePicker(context, selectedDate);
      if (selectedTime != null) {
        // 日付と時刻を結合（ローカル時間として明示的に作成）
        final combinedDateTime = DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        ).toLocal();
        onDateChanged(combinedDateTime);
      }
    }
  }

  /// 時刻選択ダイアログを表示（5分刻み）
  Future<TimeOfDay?> _showTimePicker(BuildContext context, DateTime selectedDate) async {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year && 
                   selectedDate.month == now.month && 
                   selectedDate.day == now.day;
    
    // 今日の場合は現在時刻以降、それ以外は0時以降
    final initialTime = isToday 
        ? TimeOfDay.fromDateTime(now.add(const Duration(minutes: 5)))
        : const TimeOfDay(hour: 9, minute: 0);

    return await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  /// 日時をフォーマット
  String _formatDateTime(DateTime dateTime) {
    final year = dateTime.year;
    final month = dateTime.month.toString().padLeft(2, '0');
    final day = dateTime.day.toString().padLeft(2, '0');
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    
    return '$year/$month/$day $hour:$minute';
  }
}

/// 優先度選択フィールド
class _PriorityField extends StatelessWidget {
  final int priority;
  final ValueChanged<int> onPriorityChanged;

  const _PriorityField({
    required this.priority,
    required this.onPriorityChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: const Text('優先度'),
      subtitle: Text(_TaskPriority.getText(priority)),
      trailing: DropdownButton<int>(
        value: priority,
        onChanged: (value) => onPriorityChanged(value!),
        items: _TaskPriority.getDropdownItems(),
      ),
    );
  }
}



/// 優先度の定数とユーティリティ
class _TaskPriority {
  static const int low = 1;
  static const int medium = 2;
  static const int high = 3;

  static const List<int> allPriorities = [low, medium, high];

  static String getText(int priority) {
    switch (priority) {
      case low:
        return '低';
      case medium:
        return '中';
      case high:
        return '高';
      default:
        return '中';
    }
  }

  static List<DropdownMenuItem<int>> getDropdownItems() {
    return allPriorities.map((priority) {
      return DropdownMenuItem(
        value: priority,
        child: Text(getText(priority)),
      );
    }).toList();
  }
}