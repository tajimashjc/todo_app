import 'dart:convert';
import 'package:todo_app/features/tasks/domain/entities/task.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_app/features/tasks/infrastructure/api/api_client.dart';

/// ### [Description]
/// - TaskRepositoryの実装クラス（API通信版）
class TaskRepositoryImpl implements TaskRepository {

  // ------------------------------------------------------------
  // APIエンドポイント
  static const String _tasksEndpoint = '/tasks';  // タスクAPI
  
  /// APIクライアント
  final ApiClient _apiClient;
  

  // ------------------------------------------------------------
  // コンストラクタ
  TaskRepositoryImpl({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();


  // ------------------------------------------------------------
  // オーバーライドメソッド

  /// ### [Description]
  /// - タスク一覧を取得する
  /// 
  /// ### [Returns]
  /// - Future<List<Task>>
  @override
  Future<List<Task>> getTasks() async {
    try {
      final response = await _apiClient.get(_tasksEndpoint);

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => _taskFromJson(json)).toList();
      } else {
        throw Exception('タスク一覧の取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('タスク一覧の取得に失敗しました: $e');
    }
  }

  /// ### [Description]
  /// - 指定されたIDのタスクを取得する
  /// 
  /// ### [Parameters]
  /// - [id] タスクID
  /// 
  /// ### [Returns]
  /// - Future<Task>
  @override
  Future<Task> getTask(String id) async {
    try {
      final response = await _apiClient.get('$_tasksEndpoint/$id');

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return _taskFromJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('タスクが見つかりません: $id');
      } else {
        throw Exception('タスクの取得に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('タスクの取得に失敗しました: $e');
    }
  }

  /// ### [Description]
  /// - 新しいタスクを作成する
  /// 
  /// ### [Parameters]
  /// - [task] 作成するタスク
  /// 
  /// ### [Returns]
  /// - Future<Task>
  @override
  Future<Task> createTask(Task task) async {
    try {
      final response = await _apiClient.post(
        _tasksEndpoint,
        body: json.encode(_taskToJson(task)),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return _taskFromJson(json);
      } else {
        throw Exception('タスクの作成に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('タスクの作成に失敗しました: $e');
    }
  }

  /// ### [Description]
  /// - タスクを更新する
  /// 
  /// ### [Parameters]
  /// - [task] 更新するタスク
  /// 
  /// ### [Returns]
  /// - Future<Task>
  @override
  Future<Task> updateTask(Task task) async {
    try {
      final response = await _apiClient.put(
        '$_tasksEndpoint/${task.id}',
        body: json.encode(_taskToJson(task)),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> json = jsonDecode(response.body);
        return _taskFromJson(json);
      } else if (response.statusCode == 404) {
        throw Exception('更新対象のタスクが見つかりません: ${task.id}');
      } else {
        throw Exception('タスクの更新に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('タスクの更新に失敗しました: $e');
    }
  }

  /// ### [Description]
  /// - タスクを削除する
  /// 
  /// ### [Parameters]
  /// - [id] 削除するタスクのID
  /// 
  /// ### [Returns]
  /// - Future<void>
  @override
  Future<void> deleteTask(String id) async {
    try {
      final response = await _apiClient.delete('$_tasksEndpoint/$id');

      if (response.statusCode == 200) {
        return;
      } else if (response.statusCode == 404) {
        throw Exception('削除対象のタスクが見つかりません: $id');
      } else {
        throw Exception('タスクの削除に失敗しました: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('タスクの削除に失敗しました: $e');
    }
  }


  // ------------------------------------------------------------
  // ヘルパー関数

  /// ### [Description]
  /// - JSONからTaskオブジェクトを作成する
  /// 
  /// ### [Parameters]
  /// - [json] JSONデータ
  /// 
  /// ### [Returns]
  /// - Task
  Task _taskFromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'].toString(),
      title: json['title'] ?? '',
      memo: json['memo'],
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      priority: json['priority'] ?? 2,
      completed: json['completed'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  /// ### [Description]
  /// - TaskオブジェクトをJSONに変換する
  /// 
  /// ### [Parameters]
  /// - [task] タスクオブジェクト
  /// 
  /// ### [Returns]
  /// - Map<String, dynamic>
  Map<String, dynamic> _taskToJson(Task task) {
    return {
      'id': task.id,
      'title': task.title,
      'memo': task.memo,
      'dueDate': task.dueDate?.toLocal().toIso8601String(),
      'priority': task.priority,
      'completed': task.completed,
      'createdAt': task.createdAt.toIso8601String(),
      'updatedAt': task.updatedAt.toIso8601String(),
    };
  }
}

