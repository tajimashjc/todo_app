import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';

/// ------------------------------------------------------------
/// 認証状態のプロバイダ
final authStateNotifierProvider = NotifierProvider<AuthStateNotifier, User?>(() {
  return AuthStateNotifier();
});

class AuthStateNotifier extends Notifier<User?> {
  @override
  User? build() => null;

  /// ------------------------------------------------------------------
  /// 認証状態をセットする
  /// 
  /// ### [Parameters]
  /// - [user] ユーザー情報（nullの場合は未認証）
  /// 
  /// ### [Returns]
  /// - void
  void setAuthState(User? user) {
    state = user;
  }

  /// ------------------------------------------------------------------
  /// 認証状態をクリアする
  /// 
  /// ### [Returns]
  /// - void
  void clearAuthState() {
    state = null;
  }
}
