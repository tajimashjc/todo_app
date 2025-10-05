import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/application/state/auth_state.dart';
import 'package:todo_app/features/auth/application/usecases/sign_in_usecase.dart';
import 'package:todo_app/features/auth/application/usecases/sign_out_usecase.dart';
import 'package:todo_app/features/auth/application/usecases/sign_up_usecase.dart';
import 'package:todo_app/features/auth/domain/entities/user.dart';

/// ------------------------------------------------------------
/// 認証画面のViewModel
final authViewModelProvider = NotifierProvider<AuthViewModel, AuthViewModelState>(() {
  return AuthViewModel();
});

class AuthViewModelState {
  final bool isLoading;
  final String? errorMessage;
  final User? currentUser;

  const AuthViewModelState({
    this.isLoading = false,
    this.errorMessage,
    this.currentUser,
  });

  AuthViewModelState copyWith({
    bool? isLoading,
    String? errorMessage,
    User? currentUser,
  }) {
    return AuthViewModelState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      currentUser: currentUser ?? this.currentUser,
    );
  }
}

class AuthViewModel extends Notifier<AuthViewModelState> {
  @override
  AuthViewModelState build() {
    // 認証状態を監視
    ref.listen(authStateNotifierProvider, (previous, next) {
      state = state.copyWith(currentUser: next);
    });

    return const AuthViewModelState();
  }

  /// ------------------------------------------------------------------
  /// アカウント登録を実行
  /// 
  /// ### [Parameters]
  /// - [email] メールアドレス
  /// - [password] パスワード
  /// 
  /// ### [Returns]
  /// - Future<bool> 成功した場合true
  Future<bool> signUp({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final signUpUsecase = ref.read(signUpUsecaseProvider);
      final result = await signUpUsecase.execute(
        SignUpRequest(email: email, password: password),
      );

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'アカウント登録に失敗しました: $e',
      );
      return false;
    }
  }

  /// ------------------------------------------------------------------
  /// ログインを実行
  /// 
  /// ### [Parameters]
  /// - [email] メールアドレス
  /// - [password] パスワード
  /// 
  /// ### [Returns]
  /// - Future<bool> 成功した場合true
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final signInUsecase = ref.read(signInUsecaseProvider);
      final result = await signInUsecase.execute(
        SignInRequest(email: email, password: password),
      );

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ログインに失敗しました: $e',
      );
      return false;
    }
  }

  /// ------------------------------------------------------------------
  /// ログアウトを実行
  /// 
  /// ### [Returns]
  /// - Future<bool> 成功した場合true
  Future<bool> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final signOutUsecase = ref.read(signOutUsecaseProvider);
      final result = await signOutUsecase.execute();

      if (result.isSuccess) {
        state = state.copyWith(isLoading: false);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: result.errorMessage,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'ログアウトに失敗しました: $e',
      );
      return false;
    }
  }

  /// ------------------------------------------------------------------
  /// エラーメッセージをクリア
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
