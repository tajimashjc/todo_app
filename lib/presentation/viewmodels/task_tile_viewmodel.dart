import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/application/usecases/update_task_usecase.dart';

/// ------------------------------------------------------------
/// タスクタイルのViewModel
final taskTileViewModelProvider = NotifierProvider.family<TaskTileViewModel, TaskTileViewModelState, String>(
  (taskId) => TaskTileViewModel(),
);

/// ------------------------------------------------------------
/// タスクタイルViewModelの状態
class TaskTileViewModelState {
  final bool isLoading;
  final String? errorMessage;
  final Task? task;

  const TaskTileViewModelState({
    this.isLoading = false,
    this.errorMessage,
    this.task,
  });

  TaskTileViewModelState copyWith({
    bool? isLoading,
    String? errorMessage,
    Task? task,
  }) {
    return TaskTileViewModelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      task: task ?? this.task,
    );
  }
}

/// ------------------------------------------------------------
/// タスクタイルのViewModel
class TaskTileViewModel extends Notifier<TaskTileViewModelState> {
  @override
  TaskTileViewModelState build() => const TaskTileViewModelState();

  /// ------------------------------------------------------------------
  /// タスクを設定する
  /// 
  /// ### [Parameters]
  /// - [task] タスク
  /// 
  /// ### [Returns]
  /// - void
  void setTask(Task task) {
    state = state.copyWith(task: task);
  }

  /// ------------------------------------------------------------------
  /// タスクの完了状態を切り替える
  /// 
  /// ### [Parameters]
  /// - [taskId] タスクID
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> toggleCompleted(String taskId) async {
    if (state.task == null) return;

    // ローディング状態を設定
    state = state.copyWith(isLoading: true, errorMessage: null);

    // UseCaseを使用してタスクを更新
    final useCase = ref.read(updateTaskUsecaseProvider);
    final request = UpdateTaskRequest(
      taskId: taskId,
      title: state.task!.title,
      memo: state.task!.memo,
      dueDate: state.task!.dueDate,
      priority: state.task!.priority,
      completed: !state.task!.completed, // 完了状態を反転
    );

    final result = await useCase.execute(request);

    // ローディング完了
    state = state.copyWith(isLoading: false);

    if (result.isSuccess) {
      // 更新されたタスクで状態を更新
      state = state.copyWith(task: result.task);
    } else {
      // エラー状態を設定
      state = state.copyWith(errorMessage: result.errorMessage);
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
