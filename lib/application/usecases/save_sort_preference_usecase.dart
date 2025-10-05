import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/application/types/task_sort_type.dart';
import 'package:todo_app/domain/repositories/sort_preference_repository.dart';
import 'package:todo_app/infrastructure/repositories/sort_preference_repository_impl.dart';

/// ### [Description]
/// - ソート設定を保存するユースケース
class SaveSortPreferenceUsecase {
  
  // ------------------------------------------------------------
  // プロパティ
  final SortPreferenceRepository _repository;

  // ------------------------------------------------------------
  // コンストラクタ
  SaveSortPreferenceUsecase(this._repository);

  /// ### [Description]
  /// - ソート設定を保存する
  /// 
  /// ### [Parameters]
  /// - [sortType] 保存するソート種類
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> execute(TaskSortType sortType) async {
    await _repository.saveSortPreference(sortType);
  }
}

/// ------------------------------------------------------------
/// ソート設定保存ユースケースのProvider
final saveSortPreferenceUsecaseProvider = Provider<SaveSortPreferenceUsecase>((ref) {
  final repository = ref.read(sortPreferenceRepositoryProvider);
  return SaveSortPreferenceUsecase(repository);
});
