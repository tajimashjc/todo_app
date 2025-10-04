import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/application/state/task_list_state.dart';
import 'package:todo_app/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:todo_app/presentation/widgets/task_tile.dart';
import 'package:todo_app/presentation/widgets/task_input_dialog.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {

  // ------------------------------------------------------------------
  // ライフサイクル
  @override
  void initState() {
    super.initState();
    // 次のフレームでタスク一覧を読み込み
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(taskListViewModelProvider.notifier).loadTasks();
    });
  }


  // ------------------------------------------------------------------
  // レンダリング
  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(taskListViewModelProvider);
    final tasks = ref.watch(taskListNotifierProvider);

    // エラーが発生した場合のSnackBar表示
    ref.listen(taskListViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '閉じる',
              onPressed: () {
                ref.read(taskListViewModelProvider.notifier).clearError();
              },
            ),
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('タスク一覧'),
        actions: [
          // タスク一覧の更新ボタン
          IconButton(
            onPressed: () {
              ref.read(taskListViewModelProvider.notifier).loadTasks();
            },
            icon: const Icon(Icons.refresh),
            tooltip: 'タスク一覧の更新',
          ),
        ],
      ),
      body: viewModelState.isLoading
        ? _buildLoadingIndicator() // ローディングインジケーター
        : _buildTaskList(tasks), // タスク一覧
      // 新しいタスクを作成するボタン
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => const TaskInputDialog(),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }


  // ------------------------------------------------------------------
  // ウィジェット構築

  /// ### [Description]
  /// - ローディングインジケーターを構築する。
  /// 
  /// ### [Parameters]
  /// - void
  /// 
  /// ### [Returns]
  /// - Widget
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'タスクを読み込み中...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  /// ### [Description]
  /// - タスク一覧を構築する。
  /// 
  /// ### [Parameters]
  /// - [tasks] タスク一覧
  /// 
  /// ### [Returns]
  /// - Widget
  Widget _buildTaskList(List<Task> tasks) {
    // タスクがない場合    
    if (tasks.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'タスクがありません',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '右下のボタンから新しいタスクを作成してください',
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskTile(
          key: ValueKey(task.id),
          task: task,
        );
      },
    );
  }
}

