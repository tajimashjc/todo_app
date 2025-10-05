import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/application/usecases/load_task_usecase.dart';
import 'package:todo_app/features/tasks/application/usecases/get_sort_preference_usecase.dart';
import 'package:todo_app/features/tasks/application/usecases/save_sort_preference_usecase.dart';
import 'package:todo_app/features/tasks/application/types/task_sort_type.dart';

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
  final TaskSortType currentSortType;

  const TaskListViewModelState({
    this.isLoading = false,
    this.errorMessage,
    this.currentSortType = TaskSortType.none,
  });

  TaskListViewModelState copyWith({
    bool? isLoading,
    String? errorMessage,
    TaskSortType? currentSortType,
  }) {
    return TaskListViewModelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentSortType: currentSortType ?? this.currentSortType,
    );
  }
}

/// ------------------------------------------------------------
/// タスク一覧のViewModel
class TaskListViewModel extends Notifier<TaskListViewModelState> {
  @override
  TaskListViewModelState build() => const TaskListViewModelState();

  /// ------------------------------------------------------------------
  /// 初期化処理（ソート設定を読み込み）
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> initialize() async {
    try {
      final getSortPreferenceUsecase = ref.read(getSortPreferenceUsecaseProvider);
      final sortType = await getSortPreferenceUsecase.execute();
      state = state.copyWith(currentSortType: sortType);
    } catch (e) {
      // エラーが発生した場合はデフォルト値を維持
    }
  }

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
  /// ソート種類を変更する
  /// 
  /// ### [Parameters]
  /// - [sortType] 新しいソート種類
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> changeSortType(TaskSortType sortType) async {
    try {
      // 状態を更新
      state = state.copyWith(currentSortType: sortType);
      
      // 永続化
      final saveSortPreferenceUsecase = ref.read(saveSortPreferenceUsecaseProvider);
      await saveSortPreferenceUsecase.execute(sortType);
    } catch (e) {
      // エラーが発生した場合はエラーメッセージを設定
      state = state.copyWith(errorMessage: 'ソート設定の保存に失敗しました: $e');
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
