import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';

/// ------------------------------------------------------------
/// ローカル認証ストレージ
/// 
/// 認証情報をローカルに永続化するためのデータソース
class LocalAuthStorage {
  static const String _userKey = 'auth_user';
  static const String _isLoggedInKey = 'auth_is_logged_in';

  /// ------------------------------------------------------------------
  /// ユーザー情報を保存
  /// 
  /// ### [Parameters]
  /// - [user] 保存するユーザー情報
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode({
      'uid': user.uid,
      'email': user.email,
    });
    
    await prefs.setString(_userKey, userJson);
    await prefs.setBool(_isLoggedInKey, true);
  }

  /// ------------------------------------------------------------------
  /// 保存されたユーザー情報を取得
  /// 
  /// ### [Returns]
  /// - Future<User?> 保存されたユーザー情報（存在しない場合はnull）
  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    
    if (userJson == null) return null;
    
    try {
      final userMap = jsonDecode(userJson) as Map<String, dynamic>;
      return User(
        uid: userMap['uid'] as String,
        email: userMap['email'] as String,
      );
    } catch (e) {
      // JSONの解析に失敗した場合はnullを返す
      return null;
    }
  }

  /// ------------------------------------------------------------------
  /// ログイン状態を保存
  /// 
  /// ### [Parameters]
  /// - [isLoggedIn] ログイン状態
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> setLoggedIn(bool isLoggedIn) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, isLoggedIn);
  }

  /// ------------------------------------------------------------------
  /// ログイン状態を取得
  /// 
  /// ### [Returns]
  /// - Future<bool> ログイン状態
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  /// ------------------------------------------------------------------
  /// 認証情報をクリア
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> clearAuth() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_isLoggedInKey);
  }
}
