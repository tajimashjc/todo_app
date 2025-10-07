import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/application/usecases/create_task_usecase.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';

/// ------------------------------------------------------------
/// タスク入力のViewModel
final taskInputViewModelProvider = NotifierProvider<TaskInputViewModel, TaskInputViewModelState>(() {
  return TaskInputViewModel();
});

/// ------------------------------------------------------------
/// タスク入力ViewModelの状態
class TaskInputViewModelState {
  final bool isLoading;
  final String? errorMessage;
  final String title;
  final String memo;
  final DateTime? dueDate;
  final int priority;

  const TaskInputViewModelState({
    this.isLoading = false,
    this.errorMessage,
    this.title = '',
    this.memo = '',
    this.dueDate,
    this.priority = 2,
  });

  TaskInputViewModelState copyWith({
    bool? isLoading,
    String? errorMessage,
    String? title,
    String? memo,
    DateTime? dueDate,
    int? priority,
    bool clearDueDate = false,
  }) {
    return TaskInputViewModelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
      priority: priority ?? this.priority,
    );
  }
}

/// ------------------------------------------------------------
/// タスク入力のViewModel
class TaskInputViewModel extends Notifier<TaskInputViewModelState> {
  @override
  TaskInputViewModelState build() => const TaskInputViewModelState();

  /// ------------------------------------------------------------------
  /// タイトルを更新する
  /// 
  /// ### [Parameters]
  /// - [title] タイトル
  /// 
  /// ### [Returns]
  /// - void
  void updateTitle(String title) {
    state = state.copyWith(title: title);
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
    state = state.copyWith(memo: memo);
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
    if (dueDate == null) {
      // 期限をクリアする場合
      state = state.copyWith(clearDueDate: true);
    } else {
      // 期限を設定する場合
      state = state.copyWith(dueDate: dueDate);
    }
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
    state = state.copyWith(priority: priority);
  }

  /// ------------------------------------------------------------------
  /// タスクを作成する
  /// 
  /// ### [Returns]
  /// - Future<Task?>
  Future<Task?> createTask() async {
    // ローディング状態を設定
    state = state.copyWith(isLoading: true, errorMessage: null);

    // UseCaseを使用してタスクを作成
    final useCase = ref.read(createTaskUsecaseProvider);
    final request = CreateTaskRequest(
      title: state.title,
      memo: state.memo,
      dueDate: state.dueDate,
      priority: state.priority,
    );

    // タスクを作成
    final result = await useCase.execute(request);

    // ローディング完了
    state = state.copyWith(isLoading: false);

    if (result.isSuccess) {
      return result.task;
    } else {
      // エラー状態を設定
      state = state.copyWith(errorMessage: result.errorMessage);
      return null;
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

  /// ------------------------------------------------------------------
  /// 入力値をリセットする
  /// 
  /// ### [Returns]
  /// - void
  void reset() {
    state = const TaskInputViewModelState();
  }
}
