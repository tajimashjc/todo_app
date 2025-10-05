import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (_) => throw UnimplementedError(),
);

abstract interface class AuthRepository {
  /// 現在のユーザーを取得
  Future<User?> getCurrentUser();

  /// メールアドレスとパスワードでアカウント登録
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// メールアドレスとパスワードでログイン
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  /// ログアウト
  Future<void> signOut();

  /// 認証状態の変更を監視
  Stream<User?> get authStateChanges;
}
