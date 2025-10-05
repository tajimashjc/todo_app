import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/application/state/auth_state.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';

// ----------------------------------------------------------------------
// アカウント登録のユースケース
final signUpUsecaseProvider = Provider<SignUpUsecase>(
  SignUpUsecase.new
);

/// ------------------------------------------------------------
/// アカウント登録のリクエスト
class SignUpRequest {
  final String email;
  final String password;

  const SignUpRequest({
    required this.email,
    required this.password,
  });
}

/// ------------------------------------------------------------
/// アカウント登録の結果
class SignUpResult {
  final User? user;
  final String? errorMessage;

  const SignUpResult({
    this.user,
    this.errorMessage,
  });

  bool get isSuccess => user != null && errorMessage == null;
  bool get isFailure => !isSuccess;
}

class SignUpUsecase {
  SignUpUsecase(this._ref);

  final Ref _ref;

  /// ------------------------------------------------------------------
  /// アカウント登録を実行する
  /// 
  /// ### [Parameters]
  /// - [request] アカウント登録リクエスト
  /// 
  /// ### [Returns]
  /// - Future<SignUpResult>
  Future<SignUpResult> execute(SignUpRequest request) async {
    try {
      // バリデーション
      final validationError = _validateRequest(request);
      if (validationError != null) {
        return SignUpResult(errorMessage: validationError);
      }

      // アカウント登録実行
      final repository = _ref.read(authRepositoryProvider);
      final user = await repository.signUpWithEmailAndPassword(
        email: request.email.trim(),
        password: request.password,
      );

      // 認証状態を更新
      _ref.read(authStateNotifierProvider.notifier).setAuthState(user);

      return SignUpResult(user: user);
    } catch (e) {
      return SignUpResult(
        errorMessage: 'アカウント登録に失敗しました: $e',
      );
    }
  }

  /// ------------------------------------------------------------------
  /// リクエストのバリデーション
  /// 
  /// ### [Parameters]
  /// - [request] アカウント登録リクエスト
  /// 
  /// ### [Returns]
  /// - String? エラーメッセージ（エラーがない場合はnull）
  String? _validateRequest(SignUpRequest request) {
    // メールアドレスのバリデーション
    if (request.email.trim().isEmpty) {
      return 'メールアドレスを入力してください';
    }

    // メールアドレスの形式チェック
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(request.email.trim())) {
      return '正しいメールアドレスを入力してください';
    }

    // パスワードのバリデーション
    if (request.password.isEmpty) {
      return 'パスワードを入力してください';
    }

    if (request.password.length < 6) {
      return 'パスワードは6文字以上で入力してください';
    }

    return null;
  }
}
