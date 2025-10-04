import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/application/usecases/load_task_usecase.dart';

/// ------------------------------------------------------------
/// タスク一覧のViewModel
final taskListViewModelProvider = NotifierProvider<TaskListViewModel, TaskListViewModelState>(() {
  return TaskListViewModel();
});

/// ------------------------------------------------------------
/// タスク一覧ViewModelの状態
class TaskListViewModelState {
  final bool isLoading;
  final String? errorMessage;

  const TaskListViewModelState({
    this.isLoading = false,
    this.errorMessage,
  });

  TaskListViewModelState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return TaskListViewModelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

/// ------------------------------------------------------------
/// タスク一覧のViewModel
class TaskListViewModel extends Notifier<TaskListViewModelState> {
  @override
  TaskListViewModelState build() => const TaskListViewModelState();

  /// ------------------------------------------------------------------
  /// タスク一覧を読み込む
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> loadTasks() async {
    // ローディング状態を設定
    state = state.copyWith(isLoading: true, errorMessage: null);

    // UseCaseを使用してタスクを取得
    final useCase = ref.read(loadTaskUsecaseProvider);
    final result = await useCase.execute();

    // ローディング完了
    state = state.copyWith(isLoading: false);

    if (result.isFailure) {
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
