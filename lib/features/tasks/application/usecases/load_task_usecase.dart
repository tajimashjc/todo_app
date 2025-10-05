import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_app/features/tasks/application/state/task_list_state.dart';

// ----------------------------------------------------------------------
// タスク一覧読み込みのユースケース
final loadTaskUsecaseProvider = Provider<LoadTaskUsecase>(
  LoadTaskUsecase.new
);

/// ------------------------------------------------------------
/// タスク読み込みの結果
class LoadTaskResult {
  final List<Task> tasks;
  final String? errorMessage;

  const LoadTaskResult({
    required this.tasks,
    this.errorMessage,
  });

  bool get isSuccess => errorMessage == null;
  bool get isFailure => !isSuccess;
}

class LoadTaskUsecase {
  LoadTaskUsecase(this._ref);

  final Ref _ref;

  /// ------------------------------------------------------------------
  /// タスク一覧を読み込む
  /// 
  /// ### [Returns]
  /// - Future<LoadTaskResult>
  Future<LoadTaskResult> execute() async {
    try {
      // TaskRepositoryからタスク一覧を取得
      final taskRepository = _ref.read(taskRepositoryProvider);
      final tasks = await taskRepository.getTasks();

      // taskListNotifierProviderを更新
      await _ref.read(taskListNotifierProvider.notifier).setTaskList(tasks);

      return LoadTaskResult(tasks: tasks);
    } catch (e) {
      return LoadTaskResult(
        tasks: [],
        errorMessage: 'タスクの読み込みに失敗しました: $e',
      );
    }
  }
}