import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/application/types/task_sort_type.dart';
import 'package:todo_app/domain/repositories/sort_preference_repository.dart';

/// ### [Description]
/// - ソート設定のリポジトリ実装クラス（SharedPreferences版）
class SortPreferenceRepositoryImpl implements SortPreferenceRepository {
  
  // ------------------------------------------------------------
  // 定数
  static const String _sortPreferenceKey = 'task_sort_preference';

  // ------------------------------------------------------------
  // オーバーライドメソッド

  /// ### [Description]
  /// - 保存されたソート設定を取得する
  /// 
  /// ### [Returns]
  /// - Future<TaskSortType>
  @override
  Future<TaskSortType> getSortPreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sortTypeString = prefs.getString(_sortPreferenceKey);
      
      if (sortTypeString == null) {
        return TaskSortType.none;
      }
      
      // 文字列からTaskSortTypeに変換
      for (final sortType in TaskSortType.values) {
        if (sortType.name == sortTypeString) {
          return sortType;
        }
      }
      
      return TaskSortType.none;
    } catch (e) {
      // エラーが発生した場合はデフォルト値を返す
      return TaskSortType.none;
    }
  }

  /// ### [Description]
  /// - ソート設定を保存する
  /// 
  /// ### [Parameters]
  /// - [sortType] 保存するソート種類
  /// 
  /// ### [Returns]
  /// - Future<void>
  @override
  Future<void> saveSortPreference(TaskSortType sortType) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_sortPreferenceKey, sortType.name);
    } catch (e) {
      // エラーが発生した場合は例外を投げる
      throw Exception('ソート設定の保存に失敗しました: $e');
    }
  }
}

/// ------------------------------------------------------------
/// ソート設定リポジトリのProvider
final sortPreferenceRepositoryProvider = Provider<SortPreferenceRepository>((ref) {
  return SortPreferenceRepositoryImpl();
});
