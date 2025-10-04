/// ### [Description]
/// - タスクエンティティ
class Task {
  final String id;  // タスクID
  final String title;  // タイトル
  final String? memo;  // メモ
  final DateTime? dueDate;  // 期限
  final int priority;  // 優先度（1=Low, 2=Medium, 3=High）
  final bool completed;  // 完了状態
  final DateTime createdAt;  // 作成日時
  final DateTime updatedAt;  // 更新日時

  /// ### [Description]
  /// - タスクのコンストラクタ
  /// 
  /// ### [Parameters]
  /// - [id] タスクID
  /// - [title] タイトル
  /// - [memo] メモ
  /// - [dueDate] 期限
  /// - [priority] 優先度
  /// - [completed] 完了状態
  /// - [createdAt] 作成日時
  /// - [updatedAt] 更新日時
  const Task({
    required this.id,
    required this.title,
    this.memo,
    this.dueDate,
    this.priority = 2,
    this.completed = false,
    required this.createdAt,
    required this.updatedAt,
  });


  /// ### [Description]
  /// - タスクのコピー
  /// 
  /// ### [Parameters]
  /// - [id] タスクID
  /// - [title] タイトル
  /// - [memo] メモ
  /// - [dueDate] 期限
  /// - [priority] 優先度
  /// - [completed] 完了状態
  /// - [createdAt] 作成日時
  /// - [updatedAt] 更新日時
  Task copyWith({
    String? id,
    String? title,
    String? memo,
    DateTime? dueDate,
    int? priority,
    bool? completed,
    int? orderIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      memo: memo ?? this.memo,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

