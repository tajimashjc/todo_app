import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/application/state/task_list_state.dart';
import 'package:todo_app/application/types/task_sort_type.dart';
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
    // 次のフレームでタスク一覧を読み込みとソート設定を初期化
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(taskListViewModelProvider.notifier).initialize();
      ref.read(taskListViewModelProvider.notifier).loadTasks();
    });
  }


  // ------------------------------------------------------------------
  // レンダリング
  @override
  Widget build(BuildContext context) {
    final viewModelState = ref.watch(taskListViewModelProvider);
    final tasks = ref.watch(taskListNotifierProvider);
    final currentSortType = viewModelState.currentSortType;

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
          // ソートメニュー
          PopupMenuButton<TaskSortType>(
            icon: const Icon(Icons.sort),
            tooltip: 'ソート',
            onSelected: (TaskSortType sortType) {
              ref.read(taskListViewModelProvider.notifier).changeSortType(sortType);
            },
            itemBuilder: (BuildContext context) => TaskSortType.values.map((TaskSortType sortType) {
              return PopupMenuItem<TaskSortType>(
                value: sortType,
                child: Row(
                  children: [
                    Icon(
                      sortType.icon,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(sortType.displayName),
                    if (currentSortType == sortType) ...[
                      const Spacer(),
                      const Icon(Icons.check, size: 16),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),
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
        : _buildTaskList(tasks, currentSortType), // タスク一覧
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
  /// - [sortType] ソート種類
  /// 
  /// ### [Returns]
  /// - Widget
  Widget _buildTaskList(List<Task> tasks, TaskSortType sortType) {
    // ソートを適用
    List<Task> sortedTasks = sortType.sortTasks(tasks);

    // タスクがない場合    
    if (sortedTasks.isEmpty) {
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
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final task = sortedTasks[index];
        return TaskTile(
          key: ValueKey(task.id),
          task: task,
        );
      },
    );
  }
}

