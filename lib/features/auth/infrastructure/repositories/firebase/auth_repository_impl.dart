import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:todo_app/features/auth/domain/entities/user.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/infrastructure/datasources/local_auth_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  final firebase_auth.FirebaseAuth _firebaseAuth;
  final LocalAuthStorage _localStorage;

  AuthRepositoryImpl({
    firebase_auth.FirebaseAuth? firebaseAuth,
    LocalAuthStorage? localStorage,
  }) : _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance,
       _localStorage = localStorage ?? LocalAuthStorage();

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _firebaseAuth.currentUser;
    if (firebaseUser == null) return null;

    return _convertFirebaseUserToUser(firebaseUser);
  }

  @override
  Future<User> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('ユーザー作成に失敗しました');
      }

      final user = _convertFirebaseUserToUser(credential.user!);
      
      // ローカルストレージにユーザー情報を保存
      await _localStorage.saveUser(user);
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw Exception('ログインに失敗しました');
      }

      final user = _convertFirebaseUserToUser(credential.user!);
      
      // ローカルストレージにユーザー情報を保存
      await _localStorage.saveUser(user);
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print(e);
      throw _handleFirebaseAuthException(e);
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
    // ローカルストレージから認証情報をクリア
    await _localStorage.clearAuth();
  }

  @override
  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      if (firebaseUser == null) return null;
      return _convertFirebaseUserToUser(firebaseUser);
    });
  }

  /// FirebaseUserをUserエンティティに変換
  User _convertFirebaseUserToUser(firebase_auth.User firebaseUser) {
    return User(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      createdAt: firebaseUser.metadata.creationTime ?? DateTime.now(),
      updatedAt: firebaseUser.metadata.lastSignInTime ?? DateTime.now(),
    );
  }

  /// FirebaseAuthExceptionを適切なエラーメッセージに変換
  Exception _handleFirebaseAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return Exception('ユーザーが見つかりません');
      case 'wrong-password':
        return Exception('パスワードが正しくありません');
      case 'email-already-in-use':
        return Exception('このメールアドレスは既に使用されています');
      case 'weak-password':
        return Exception('パスワードが弱すぎます');
      case 'invalid-email':
        return Exception('メールアドレスの形式が正しくありません');
      case 'user-disabled':
        return Exception('このアカウントは無効化されています');
      case 'too-many-requests':
        return Exception('リクエストが多すぎます。しばらく待ってから再試行してください');
      default:
        return Exception('認証エラーが発生しました: ${e.message}');
    }
  }
}
