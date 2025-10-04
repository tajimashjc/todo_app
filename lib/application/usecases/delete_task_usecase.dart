import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/application/state/task_list_state.dart';

// ----------------------------------------------------------------------
// タスク削除のユースケース
final deleteTaskUsecaseProvider = Provider<DeleteTaskUsecase>(
  DeleteTaskUsecase.new
);

/// ------------------------------------------------------------
/// タスク削除のリクエスト
class DeleteTaskRequest {
  final String taskId;

  const DeleteTaskRequest({
    required this.taskId,
  });
}

/// ------------------------------------------------------------
/// タスク削除の結果
class DeleteTaskResult {
  final String? errorMessage;

  const DeleteTaskResult({
    this.errorMessage,
  });

  bool get isSuccess => errorMessage == null;
  bool get isFailure => !isSuccess;
}

class DeleteTaskUsecase {
  DeleteTaskUsecase(this._ref);

  final Ref _ref;

  /// ------------------------------------------------------------------
  /// タスクを削除する
  ///
  /// ### [Parameters]
  /// - [request] タスク削除リクエスト
  ///
  /// ### [Returns]
  /// - Future<DeleteTaskResult>
  Future<DeleteTaskResult> execute(DeleteTaskRequest request) async {
    try {
      // 削除実行
      final repository = _ref.read(taskRepositoryProvider);
      await repository.deleteTask(request.taskId);

      // TODO: 毎回タスク一覧を全件取得するのは非効率なので、修正案を検討する。
      // タスク一覧を更新
      final taskRepository = _ref.read(taskRepositoryProvider);
      final tasks = await taskRepository.getTasks();
      await _ref.read(taskListNotifierProvider.notifier).setTaskList(tasks);

      return const DeleteTaskResult();
    } catch (e) {
      return DeleteTaskResult(
        errorMessage: 'タスクの削除に失敗しました: $e',
      );
    }
  }
}
