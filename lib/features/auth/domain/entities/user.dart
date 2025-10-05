/// ### [Description]
/// - ユーザーエンティティ
class User {
  final String uid;  // ユーザーID
  final String email;  // メールアドレス
  final String? displayName;  // 表示名
  final DateTime createdAt;  // 作成日時
  final DateTime updatedAt;  // 更新日時

  /// ### [Description]
  /// - ユーザーのコンストラクタ
  /// 
  /// ### [Parameters]
  /// - [uid] ユーザーID
  /// - [email] メールアドレス
  /// - [displayName] 表示名
  /// - [createdAt] 作成日時
  /// - [updatedAt] 更新日時
  const User({
    required this.uid,
    required this.email,
    this.displayName,
    required this.createdAt,
    required this.updatedAt,
  });

  /// ### [Description]
  /// - ユーザーのコピー
  /// 
  /// ### [Parameters]
  /// - [uid] ユーザーID
  /// - [email] メールアドレス
  /// - [displayName] 表示名
  /// - [createdAt] 作成日時
  /// - [updatedAt] 更新日時
  User copyWith({
    String? uid,
    String? email,
    String? displayName,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return User(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
