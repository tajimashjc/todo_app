import 'package:firebase_auth/firebase_auth.dart';

/// 通信の流れをまとめておくサービスクラス
class AuthService {

  /// ------------------------------------------------------------
  /// アカウント登録
  Future<void> signUp() async {
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: '',
      password: '',
    );
  }

  /// ------------------------------------------------------------
  /// ログイン
  Future<void> signIn() async {
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: '',
      password: '',
    );
  }

  /// ------------------------------------------------------------
  /// ログアウト
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }
}