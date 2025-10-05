/// ### [Description]
/// - ユーザーエンティティ
class User {
  final String uid;  // ユーザーID
  final String email;  // メールアドレス

  /// ### [Description]
  /// - ユーザーのコンストラクタ
  /// 
  /// ### [Parameters]
  /// - [uid] ユーザーID
  /// - [email] メールアドレス
  const User({
    required this.uid,
    required this.email,
  });

  /// ### [Description]
  /// - ユーザーのコピー
  /// 
  /// ### [Parameters]
  /// - [uid] ユーザーID
  /// - [email] メールアドレス
  User copyWith({
    String? uid,
    String? email,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
    );
  }
}
