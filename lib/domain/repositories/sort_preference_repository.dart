import 'package:todo_app/application/types/task_sort_type.dart';

/// ### [Description]
/// - ソート設定のリポジトリインターフェース
abstract class SortPreferenceRepository {
  /// ### [Description]
  /// - 保存されたソート設定を取得する
  /// 
  /// ### [Returns]
  /// - Future<TaskSortType>
  Future<TaskSortType> getSortPreference();

  /// ### [Description]
  /// - ソート設定を保存する
  /// 
  /// ### [Parameters]
  /// - [sortType] 保存するソート種類
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> saveSortPreference(TaskSortType sortType);
}
