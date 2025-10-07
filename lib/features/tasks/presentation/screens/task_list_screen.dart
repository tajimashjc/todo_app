import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/application/state/task_list_state.dart';
import 'package:todo_app/features/tasks/application/types/task_sort_type.dart';
import 'package:todo_app/features/tasks/presentation/viewmodels/task_list_viewmodel.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_tile.dart';
import 'package:todo_app/features/tasks/presentation/widgets/task_input_dialog.dart';
import 'package:todo_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';

class TaskListScreen extends ConsumerStatefulWidget {
  const TaskListScreen({super.key});

  @override
  ConsumerState<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends ConsumerState<TaskListScreen> {

  // ------------------------------------------------------------------
  // 定数
  static const double _appBarTitleSize = 16.0;
  static const double _iconSize = 20.0;
  static const double _checkIconSize = 16.0;
  static const double _headerTitleSize = 20.0;
  static const double _emptyStateIconSize = 64.0;
  static const double _horizontalPadding = 20.0;
  static const double _verticalSpacing = 16.0;
  static const double _smallSpacing = 8.0;
  static const double _endPadding = 10.0;

  // ------------------------------------------------------------------
  // ライフサイクル
  @override
  void initState() {
    super.initState();
    _initializeScreen();
  }

  /// 画面の初期化処理
  void _initializeScreen() {
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

    _setupErrorListener();

    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(viewModelState, tasks, currentSortType),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// エラーリスナーの設定
  void _setupErrorListener() {
    ref.listen(taskListViewModelProvider, (previous, next) {
      if (next.errorMessage != null) {
        _showErrorSnackBar(next.errorMessage!);
      }
    });
  }

  /// エラーSnackBarの表示
  void _showErrorSnackBar(String errorMessage) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
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


  // ------------------------------------------------------------------
  // イベントハンドラー

  /// ログアウト処理を実行する
  /// 
  /// ### [Parameters]
  /// - [context] BuildContext
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> _handleLogout(BuildContext context) async {
    // 確認ダイアログを表示
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ログアウト'),
        content: const Text('ログアウトしますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('ログアウト'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      // AuthViewModelを使用してログアウトを実行
      // TODO: 別機能のViewModelを呼び出すことが設計上問題ないか再度検討する。
      final authViewModel = ref.read(authViewModelProvider.notifier);
      final success = await authViewModel.signOut();
      
      if (!success && mounted) {
        // ログアウトに失敗した場合のエラー表示
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('ログアウトに失敗しました'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ------------------------------------------------------------------
  // ウィジェット構築

  /// AppBarの構築
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        ref.read(authViewModelProvider).currentUser?.email ?? '',
        style: const TextStyle(
          fontSize: _appBarTitleSize,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => _handleLogout(context),
          icon: const Icon(Icons.logout),
          tooltip: 'ログアウト',
        ),
      ],
    );
  }

  /// ボディの構築
  Widget _buildBody(TaskListViewModelState viewModelState, List<Task> tasks, TaskSortType currentSortType) {
    if (viewModelState.isLoading) {
      return _buildLoadingIndicator();
    }

    return Column(
      children: [
        _buildHeader(currentSortType, viewModelState.isAscending),
        const SizedBox(height: _verticalSpacing),
        Expanded(
          child: _buildTaskList(tasks, currentSortType, viewModelState.isAscending),
        ),
      ],
    );
  }

  /// ヘッダー部分の構築
  Widget _buildHeader(TaskSortType currentSortType, bool isAscending) {
    return Row(
      children: [
        const SizedBox(width: _horizontalPadding),
        const Text(
          'タスク一覧',
          style: TextStyle(
            fontSize: _headerTitleSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        _buildSortMenu(currentSortType),
        _buildSortOrderButton(isAscending),
        _buildRefreshButton(),
        const SizedBox(width: _endPadding),
      ],
    );
  }

  /// ソートメニューの構築
  Widget _buildSortMenu(TaskSortType currentSortType) {
    return PopupMenuButton<TaskSortType>(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            currentSortType.icon,
            size: _iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            currentSortType.displayName,
            style: const TextStyle(fontSize: 14),
          ),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_drop_down, size: 16),
        ],
      ),
      tooltip: 'ソート: ${currentSortType.displayName}',
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
                size: _iconSize,
              ),
              const SizedBox(width: _smallSpacing),
              Text(sortType.displayName),
              if (currentSortType == sortType) ...[
                const Spacer(),
                const Icon(Icons.check, size: _checkIconSize),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  /// ソート順序切り替えボタンの構築
  Widget _buildSortOrderButton(bool isAscending) {
    return IconButton(
      onPressed: () {
        ref.read(taskListViewModelProvider.notifier).toggleSortOrder();
      },
      icon: Icon(
        isAscending ? Icons.arrow_upward : Icons.arrow_downward,
        size: _iconSize,
      ),
      tooltip: isAscending ? '昇順' : '降順',
    );
  }

  /// 更新ボタンの構築
  Widget _buildRefreshButton() {
    return IconButton(
      onPressed: () {
        ref.read(taskListViewModelProvider.notifier).loadTasks();
      },
      icon: const Icon(Icons.refresh),
      tooltip: 'タスク一覧の更新',
    );
  }

  /// FloatingActionButtonの構築
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) => const TaskInputDialog(),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  /// ローディングインジケーターの構築
  Widget _buildLoadingIndicator() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: _verticalSpacing),
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

  /// タスク一覧の構築
  Widget _buildTaskList(List<Task> tasks, TaskSortType sortType, bool isAscending) {
    final sortedTasks = sortType.sortTasks(tasks, isAscending: isAscending);

    if (sortedTasks.isEmpty) {
      return _buildEmptyState();
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

  /// 空状態の表示
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: _emptyStateIconSize,
            color: Colors.grey,
          ),
          SizedBox(height: _verticalSpacing),
          Text(
            'タスクがありません',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: _smallSpacing),
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
}

