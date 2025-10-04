import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/entities/task.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/application/state/task_list_state.dart';

// ----------------------------------------------------------------------
// タスク更新のユースケース
final updateTaskUsecaseProvider = Provider<UpdateTaskUsecase>(
  UpdateTaskUsecase.new
);

/// ------------------------------------------------------------
/// タスク更新のリクエスト
class UpdateTaskRequest {
  final String taskId;
  final String title;
  final String? memo;
  final DateTime? dueDate;
  final int priority;
  final bool completed;

  const UpdateTaskRequest({
    required this.taskId,
    required this.title,
    required this.memo,
    this.dueDate,
    required this.priority,
    required this.completed,
  });
}

/// ------------------------------------------------------------
/// タスク更新の結果
class UpdateTaskResult {
  final Task? task;
  final String? errorMessage;

  const UpdateTaskResult({
    this.task,
    this.errorMessage,
  });

  bool get isSuccess => task != null && errorMessage == null;
  bool get isFailure => !isSuccess;
}

class UpdateTaskUsecase {
  UpdateTaskUsecase(this._ref);

  final Ref _ref;

  /// ------------------------------------------------------------------
  /// タスクを更新する
  ///
  /// ### [Parameters]
  /// - [request] タスク更新リクエスト
  ///
  /// ### [Returns]
  /// - Future<UpdateTaskResult>
  Future<UpdateTaskResult> execute(UpdateTaskRequest request) async {
    try {
      // バリデーション
      final validationError = _validateRequest(request);
      if (validationError != null) {
        return UpdateTaskResult(errorMessage: validationError);
      }

      // タスクのデータを更新
      final now = DateTime.now();
      final task = Task(
        id: request.taskId,
        title: request.title.trim(),
        memo: request.memo?.trim().isEmpty == true ? null : request.memo?.trim(),
        dueDate: request.dueDate,
        priority: request.priority,
        completed: request.completed,
        createdAt: DateTime.now(), // 実際のアプリでは既存のタスクから取得
        updatedAt: now,
      );

      // 更新実行
      final repository = _ref.read(taskRepositoryProvider);
      await repository.updateTask(task);

      // TODO: 毎回タスク一覧を全件取得するのは非効率なので、修正案を検討する。
      // タスク一覧を更新
      final taskRepository = _ref.read(taskRepositoryProvider);
      final tasks = await taskRepository.getTasks();
      await _ref.read(taskListNotifierProvider.notifier).setTaskList(tasks);

      return UpdateTaskResult(task: task);
    } catch (e) {
      return UpdateTaskResult(
        errorMessage: 'タスクの更新に失敗しました: $e',
      );
    }
  }

  /// ------------------------------------------------------------------
  /// リクエストのバリデーション
  ///
  /// ### [Parameters]
  /// - [request] タスク更新リクエスト
  ///
  /// ### [Returns]
  /// - String? エラーメッセージ（エラーがない場合はnull）
  String? _validateRequest(UpdateTaskRequest request) {
    // タイトルのバリデーション
    if (request.title.trim().isEmpty) {
      return 'タイトルを入力してください';
    }

    // メモのバリデーション
    if (request.memo != null && request.memo!.length > 2000) {
      return 'メモは2000文字以内で入力してください';
    }

    // 期限のバリデーション
    if (request.dueDate != null && request.dueDate!.isBefore(DateTime.now())) {
      return '期限は今日以降の日付を選択してください';
    }

    return null;
  }
}
