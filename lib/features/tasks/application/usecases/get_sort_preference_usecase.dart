import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/tasks/application/types/task_sort_type.dart';
import 'package:todo_app/features/tasks/domain/repositories/sort_preference_repository.dart';
import 'package:todo_app/features/tasks/infrastructure/repositories/sort_preference_repository_impl.dart';

/// ### [Description]
/// - ソート設定を取得するユースケース
class GetSortPreferenceUsecase {
  
  // ------------------------------------------------------------
  // プロパティ
  final SortPreferenceRepository _repository;

  // ------------------------------------------------------------
  // コンストラクタ
  GetSortPreferenceUsecase(this._repository);

  /// ### [Description]
  /// - 保存されたソート設定を取得する
  /// 
  /// ### [Returns]
  /// - Future<TaskSortType>
  Future<TaskSortType> execute() async {
    return await _repository.getSortPreference();
  }
}

/// ------------------------------------------------------------
/// ソート設定取得ユースケースのProvider
final getSortPreferenceUsecaseProvider = Provider<GetSortPreferenceUsecase>((ref) {
  final repository = ref.read(sortPreferenceRepositoryProvider);
  return GetSortPreferenceUsecase(repository);
});
