import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/application/state/auth_state.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/infrastructure/datasources/local_auth_storage.dart';

// ----------------------------------------------------------------------
// 自動再ログインのユースケース
final autoSignInUsecaseProvider = Provider<AutoSignInUsecase>(
  AutoSignInUsecase.new
);

/// ------------------------------------------------------------
/// 自動再ログインの結果
class AutoSignInResult {
  final User? user;
  final bool isSuccess;
  final String? errorMessage;

  const AutoSignInResult({
    this.user,
    required this.isSuccess,
    this.errorMessage,
  });

  bool get isFailure => !isSuccess;
}

class AutoSignInUsecase {
  AutoSignInUsecase(this._ref);

  final Ref _ref;

  /// ------------------------------------------------------------------
  /// 自動再ログインを実行する
  /// 
  /// ローカルストレージに保存された認証情報を確認し、
  /// Firebaseの認証状態と照合して自動ログインを試行する
  /// 
  /// ### [Returns]
  /// - Future<AutoSignInResult>
  Future<AutoSignInResult> execute() async {
    try {
      final localStorage = LocalAuthStorage();
      
      // ローカルストレージからログイン状態を確認
      final isLoggedIn = await localStorage.isLoggedIn();
      if (!isLoggedIn) {
        return const AutoSignInResult(
          isSuccess: false,
          errorMessage: 'ログイン情報が保存されていません',
        );
      }

      // ローカルストレージからユーザー情報を取得
      final localUser = await localStorage.getUser();
      if (localUser == null) {
        return const AutoSignInResult(
          isSuccess: false,
          errorMessage: 'ユーザー情報が見つかりません',
        );
      }

      // Firebaseの現在の認証状態を確認
      final repository = _ref.read(authRepositoryProvider);
      final currentUser = await repository.getCurrentUser();
      
      if (currentUser != null) {
        // Firebaseに認証済みのユーザーがいる場合
        if (currentUser.uid == localUser.uid) {
          // ローカルストレージのユーザーと一致する場合、認証状態を更新
          _ref.read(authStateNotifierProvider.notifier).setAuthenticated(currentUser);
          return AutoSignInResult(user: currentUser, isSuccess: true);
        } else {
          // ユーザーが一致しない場合、ローカルストレージをクリア
          await localStorage.clearAuth();
          return const AutoSignInResult(
            isSuccess: false,
            errorMessage: '認証情報が一致しません',
          );
        }
      } else {
        // Firebaseに認証済みのユーザーがいない場合
        // ローカルストレージをクリア
        await localStorage.clearAuth();
        return const AutoSignInResult(
          isSuccess: false,
          errorMessage: 'Firebaseの認証状態が無効です',
        );
      }
    } catch (e) {
      return AutoSignInResult(
        isSuccess: false,
        errorMessage: '自動再ログインに失敗しました: $e',
      );
    }
  }
}
