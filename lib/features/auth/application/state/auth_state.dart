import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';
import 'package:todo_app/features/auth/infrastructure/datasources/local_auth_storage.dart';

/// ------------------------------------------------------------
/// 認証状態の種類
enum AuthStatus {
  initializing, // 初期化中
  authenticated, // 認証済み
  unauthenticated, // 未認証
}

/// ------------------------------------------------------------
/// 認証状態のデータクラス
class AuthState {
  final AuthStatus status;
  final User? user;

  const AuthState({
    required this.status,
    this.user,
  });

  bool get isInitializing => status == AuthStatus.initializing;
  bool get isAuthenticated => status == AuthStatus.authenticated && user != null;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
}

/// ------------------------------------------------------------
/// 認証状態のプロバイダ
final authStateNotifierProvider = NotifierProvider<AuthStateNotifier, AuthState>(() {
  return AuthStateNotifier();
});

class AuthStateNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // 初期化時にローカルストレージから認証状態を復元
    _initializeAuthState();
    return const AuthState(status: AuthStatus.initializing);
  }

  /// ------------------------------------------------------------------
  /// 認証状態を初期化する
  /// 
  /// ### [Returns]
  /// - void
  void _initializeAuthState() async {
    try {
      final localStorage = LocalAuthStorage();
      final isLoggedIn = await localStorage.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await localStorage.getUser();
        if (user != null) {
          // 認証済み状態に更新
          setAuthenticated(user);
        } else {
          // ユーザー情報が見つからない場合は未認証状態に
          setUnauthenticated();
        }
      } else {
        // ログイン情報がない場合は未認証状態に
        setUnauthenticated();
      }
    } catch (e) {
      print('認証状態の初期化に失敗しました: $e');
      setUnauthenticated();
    }
  }

  /// ------------------------------------------------------------------
  /// 認証済み状態をセットする
  /// 
  /// ### [Parameters]
  /// - [user] ユーザー情報
  /// 
  /// ### [Returns]
  /// - void
  void setAuthenticated(User user) {
    state = AuthState(status: AuthStatus.authenticated, user: user);
  }

  /// ------------------------------------------------------------------
  /// 未認証状態をセットする
  /// 
  /// ### [Returns]
  /// - void
  void setUnauthenticated() {
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// ------------------------------------------------------------------
  /// 認証状態をクリアする
  /// 
  /// ### [Returns]
  /// - void
  void clearAuthState() {
    setUnauthenticated();
  }

  /// ------------------------------------------------------------------
  /// 認証状態をリフレッシュする
  /// 
  /// ローカルストレージから最新の認証状態を取得して更新する
  /// 
  /// ### [Returns]
  /// - Future<void>
  Future<void> refreshAuthState() async {
    try {
      final localStorage = LocalAuthStorage();
      final isLoggedIn = await localStorage.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await localStorage.getUser();
        if (user != null) {
          setAuthenticated(user);
        } else {
          setUnauthenticated();
        }
      } else {
        setUnauthenticated();
      }
    } catch (e) {
      print('認証状態のリフレッシュに失敗しました: $e');
      setUnauthenticated();
    }
  }
}
