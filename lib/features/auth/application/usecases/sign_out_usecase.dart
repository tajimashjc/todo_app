import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/application/state/auth_state.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';

// ----------------------------------------------------------------------
// ログアウトのユースケース
final signOutUsecaseProvider = Provider<SignOutUsecase>(
  SignOutUsecase.new
);

/// ------------------------------------------------------------
/// ログアウトの結果
class SignOutResult {
  final bool isSuccess;
  final String? errorMessage;

  const SignOutResult({
    required this.isSuccess,
    this.errorMessage,
  });

  bool get isFailure => !isSuccess;
}

class SignOutUsecase {
  SignOutUsecase(this._ref);

  final Ref _ref;

  /// ------------------------------------------------------------------
  /// ログアウトを実行する
  /// 
  /// ### [Returns]
  /// - Future<SignOutResult>
  Future<SignOutResult> execute() async {
    try {
      // ログアウト実行
      final repository = _ref.read(authRepositoryProvider);
      await repository.signOut();

      // 認証状態をクリア
      _ref.read(authStateNotifierProvider.notifier).clearAuthState();

      return const SignOutResult(isSuccess: true);
    } catch (e) {
      return SignOutResult(
        isSuccess: false,
        errorMessage: 'ログアウトに失敗しました: $e',
      );
    }
  }
}
