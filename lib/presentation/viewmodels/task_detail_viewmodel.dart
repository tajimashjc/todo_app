import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/application/usecases/update_task_usecase.dart';
import 'package:todo_app/application/usecases/delete_task_usecase.dart';

/// ------------------------------------------------------------
/// タスク詳細のViewModel
final taskDetailViewModelProvider = NotifierProvider.family<TaskDetailViewModel, TaskDetailViewModelState, String>(
  (taskId) => TaskDetailViewModel(),
);

/// ------------------------------------------------------------
/// タスク詳細ViewModelの状態
class TaskDetailViewModelState {
  final bool isLoading;
  final String? errorMessage;
  final Task? task;

  const TaskDetailViewModelState({
    this.isLoading = false,
    this.errorMessage,
    this.task,
  });

  TaskDetailViewModelState copyWith({
    bool? isLoading,
    String? errorMessage,
    Task? task,
  }) {
    return TaskDetailViewModelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      task: task ?? this.task,
    );
  }
}

/// ------------------------------------------------------------
/// タスク詳細のViewModel
class TaskDetailViewModel extends Notifier<TaskDetailViewModelState> {
  @override
  TaskDetailViewModelState build() => const TaskDetailViewModelState();

  /// ------------------------------------------------------------------
  /// タスクを読み込む
  /// 
  /// ### [Parameters]
  /// - [taskId] タスクID
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> loadTask(String taskId) async {
    try {
      // ローディング状態を設定
      state = state.copyWith(isLoading: true, errorMessage: null);

      // TaskRepositoryからタスクを取得
      final repository = ref.read(taskRepositoryProvider);
      final task = await repository.getTask(taskId);

      // 状態を更新
      state = state.copyWith(
        isLoading: false,
        task: task,
      );
    } catch (e) {
      // エラー状態を設定
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'タスクの読み込みに失敗しました: $e',
      );
    }
  }

  /// ------------------------------------------------------------------
  /// タイトルを更新する
  /// 
  /// ### [Parameters]
  /// - [title] タイトル
  /// 
  /// ### [Returns]
  /// - void
  void updateTitle(String title) {
    // タスクが存在しない場合は何もしない
    if (state.task == null) return;
    // タイトルを更新したタスクをコピー
    final updatedTask = state.task!.copyWith(title: title);
    // 状態を更新
    state = state.copyWith(task: updatedTask);
  }

  /// ------------------------------------------------------------------
  /// メモを更新する
  /// 
  /// ### [Parameters]
  /// - [memo] メモ
  /// 
  /// ### [Returns]
  /// - void
  void updateMemo(String memo) {
    // タスクが存在しない場合は何もしない
    if (state.task == null) return;
    // メモを更新したタスクをコピー
    final updatedTask = state.task!.copyWith(memo: memo);
    // 状態を更新
    state = state.copyWith(task: updatedTask);
  }

  /// ------------------------------------------------------------------
  /// 期限を更新する
  /// 
  /// ### [Parameters]
  /// - [dueDate] 期限
  /// 
  /// ### [Returns]
  /// - void
  void updateDueDate(DateTime? dueDate) {
    // タスクが存在しない場合は何もしない
    if (state.task == null) return;
    // 期限を更新したタスクをコピー
    final updatedTask = state.task!.copyWith(dueDate: dueDate);
    // 状態を更新
    state = state.copyWith(task: updatedTask);
  }

  /// ------------------------------------------------------------------
  /// 優先度を更新する
  /// 
  /// ### [Parameters]
  /// - [priority] 優先度
  /// 
  /// ### [Returns]
  /// - void
  void updatePriority(int priority) {
    // タスクが存在しない場合は何もしない
    if (state.task == null) return;
    // 優先度を更新したタスクをコピー
    final updatedTask = state.task!.copyWith(priority: priority);
    // 状態を更新
    state = state.copyWith(task: updatedTask);
  }

  /// ------------------------------------------------------------------
  /// 完了状態を更新する
  /// 
  /// ### [Parameters]
  /// - [completed] 完了状態
  /// 
  /// ### [Returns]
  /// - void
  void updateCompleted(bool completed) {
    // タスクが存在しない場合は何もしない
    if (state.task == null) return;
    // 完了状態を更新したタスクをコピー
    final updatedTask = state.task!.copyWith(completed: completed);
    // 状態を更新
    state = state.copyWith(task: updatedTask);
  }

  /// ------------------------------------------------------------------
  /// タスクを保存する
  /// 
  /// ### [Parameters]
  /// - [taskId] タスクID
  /// 
  /// ### [Returns]
  /// - Future<bool>
  Future<bool> saveTask(String taskId) async {
    // ローディング状態を設定
    state = state.copyWith(isLoading: true, errorMessage: null);

    // UseCaseを使用してタスクを更新
    final useCase = ref.read(updateTaskUsecaseProvider);
    final request = UpdateTaskRequest(
      taskId: taskId,
      title: state.task?.title ?? '',
      memo: state.task?.memo,
      dueDate: state.task?.dueDate,
      priority: state.task?.priority ?? 2,
      completed: state.task?.completed ?? false,
    );

    final result = await useCase.execute(request);

    // ローディング完了
    state = state.copyWith(isLoading: false);

    if (result.isSuccess) {
      // 更新されたタスクで状態を更新
      state = state.copyWith(task: result.task);
      return true;
    } else {
      // エラー状態を設定
      state = state.copyWith(errorMessage: result.errorMessage);
      return false;
    }
  }

  /// ------------------------------------------------------------------
  /// タスクを削除する
  /// 
  /// ### [Parameters]
  /// - [taskId] タスクID
  /// 
  /// ### [Returns]
  /// - Future<bool>
  Future<bool> deleteTask(String taskId) async {
    // ローディング状態を設定
    state = state.copyWith(isLoading: true, errorMessage: null);

    // UseCaseを使用してタスクを削除
    final useCase = ref.read(deleteTaskUsecaseProvider);
    final request = DeleteTaskRequest(taskId: taskId);

    final result = await useCase.execute(request);

    // ローディング完了
    state = state.copyWith(isLoading: false);

    if (result.isSuccess) {
      return true;
    } else {
      // エラー状態を設定
      state = state.copyWith(errorMessage: result.errorMessage);
      return false;
    }
  }

  /// ------------------------------------------------------------------
  /// エラーメッセージをクリアする
  /// 
  /// ### [Returns]
  /// - void
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

}
