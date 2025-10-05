import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/application/state/auth_state.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';

// ----------------------------------------------------------------------
// ログインのユースケース
final signInUsecaseProvider = Provider<SignInUsecase>(
  SignInUsecase.new
);

/// ------------------------------------------------------------
/// ログインのリクエスト
class SignInRequest {
  final String email;
  final String password;

  const SignInRequest({
    required this.email,
    required this.password,
  });
}

/// ------------------------------------------------------------
/// ログインの結果
class SignInResult {
  final User? user;
  final String? errorMessage;

  const SignInResult({
    this.user,
    this.errorMessage,
  });

  bool get isSuccess => user != null && errorMessage == null;
  bool get isFailure => !isSuccess;
}

class SignInUsecase {
  SignInUsecase(this._ref);

  final Ref _ref;

  /// ------------------------------------------------------------------
  /// ログインを実行する
  /// 
  /// ### [Parameters]
  /// - [request] ログインリクエスト
  /// 
  /// ### [Returns]
  /// - Future<SignInResult>
  Future<SignInResult> execute(SignInRequest request) async {
    try {
      // バリデーション
      final validationError = _validateRequest(request);
      if (validationError != null) {
        return SignInResult(errorMessage: validationError);
      }

      // ログイン実行
      final repository = _ref.read(authRepositoryProvider);
      final user = await repository.signInWithEmailAndPassword(
        email: request.email.trim(),
        password: request.password,
      );

      // 認証状態を更新
      _ref.read(authStateNotifierProvider.notifier).setAuthState(user);

      return SignInResult(user: user);
    } catch (e) {
      print(e);
      return SignInResult(
        errorMessage: 'ログインに失敗しました: $e',
      );
    }
  }

  /// ------------------------------------------------------------------
  /// リクエストのバリデーション
  /// 
  /// ### [Parameters]
  /// - [request] ログインリクエスト
  /// 
  /// ### [Returns]
  /// - String? エラーメッセージ（エラーがない場合はnull）
  String? _validateRequest(SignInRequest request) {
    // メールアドレスのバリデーション
    if (request.email.trim().isEmpty) {
      return 'メールアドレスを入力してください';
    }

    // パスワードのバリデーション
    if (request.password.isEmpty) {
      return 'パスワードを入力してください';
    }

    return null;
  }
}
