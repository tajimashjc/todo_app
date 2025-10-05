import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/application/state/task_list_state.dart';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';

// ----------------------------------------------------------------------
// 新規タスク作成のユースケース
final createTaskUsecaseProvider = Provider<CreateTaskUsecase>(
  CreateTaskUsecase.new
);

/// ------------------------------------------------------------
/// タスク作成のリクエスト
class CreateTaskRequest {
  final String title;
  final String memo;
  final DateTime? dueDate;
  final int priority;

  const CreateTaskRequest({
    required this.title,
    required this.memo,
    this.dueDate,
    required this.priority,
  });
}

/// ------------------------------------------------------------
/// タスク作成の結果
class CreateTaskResult {
  final Task? task;
  final String? errorMessage;

  const CreateTaskResult({
    this.task,
    this.errorMessage,
  });

  bool get isSuccess => task != null && errorMessage == null;
  bool get isFailure => !isSuccess;
}

class CreateTaskUsecase {
  CreateTaskUsecase(this._ref);

  final Ref _ref;

  /// ------------------------------------------------------------------
  /// タスクを作成する
  /// 
  /// ### [Parameters]
  /// - [request] タスク作成リクエスト
  /// 
  /// ### [Returns]
  /// - Future<CreateTaskResult>
  Future<CreateTaskResult> execute(CreateTaskRequest request) async {
    try {
      // バリデーション
      final validationError = _validateRequest(request);
      if (validationError != null) {
        return CreateTaskResult(errorMessage: validationError);
      }

      // タスクのデータを作成
      final now = DateTime.now();
      final task = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: request.title.trim(),
        memo: request.memo.trim().isEmpty ? null : request.memo.trim(),
        dueDate: request.dueDate,
        priority: request.priority,
        createdAt: now,
        updatedAt: now,
      );

      // 作成実行
      final repository = _ref.read(taskRepositoryProvider);
      await repository.createTask(task);

      // TODO: 毎回タスク一覧を全件取得するのは非効率なので、修正案を検討する。
      // タスク一覧を更新
      final taskRepository = _ref.read(taskRepositoryProvider);
      final tasks = await taskRepository.getTasks();
      await _ref.read(taskListNotifierProvider.notifier).setTaskList(tasks);

      return CreateTaskResult(task: task);
    } catch (e) {
      return CreateTaskResult(
        errorMessage: 'タスクの作成に失敗しました: $e',
      );
    }
  }

  /// ------------------------------------------------------------------
  /// リクエストのバリデーション
  /// 
  /// ### [Parameters]
  /// - [request] タスク作成リクエスト
  /// 
  /// ### [Returns]
  /// - String? エラーメッセージ（エラーがない場合はnull）
  String? _validateRequest(CreateTaskRequest request) {
    // タイトルのバリデーション
    if (request.title.trim().isEmpty) {
      return 'タイトルを入力してください';
    }

    // メモのバリデーション
    if (request.memo.length > 2000) {
      return 'メモは2000文字以内で入力してください';
    }

    // 期限のバリデーション
    if (request.dueDate != null && request.dueDate!.isBefore(DateTime.now())) {
      return '期限は現在以降の日付を選択してください';
    }

    return null;
  }
}