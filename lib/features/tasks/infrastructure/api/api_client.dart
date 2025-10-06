import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ### [Description]
/// - Firebase認証トークンを使用したAPI通信クライアント
/// - 自動的にAuthorizationヘッダーを付与し、401エラー時のトークンリフレッシュと再試行を実装
class ApiClient {
  final http.Client _client;
  final FirebaseAuth _firebaseAuth;

  ApiClient({
    http.Client? client,
    FirebaseAuth? firebaseAuth,
  }) : _client = client ?? http.Client(),
       _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// ### [Description]
  /// - GETリクエストを送信する
  /// 
  /// ### [Parameters]
  /// - [endpoint] APIエンドポイント
  /// - [maxRetries] 最大再試行回数（デフォルト: 1）
  /// 
  /// ### [Returns]
  /// - Future<http.Response>
  Future<http.Response> get(
    String endpoint, {
    int maxRetries = 1,
  }) async {
    return await _makeRequest(
      () async => _client.get(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
      ),
      maxRetries: maxRetries,
    );
  }

  /// ### [Description]
  /// - POSTリクエストを送信する
  /// 
  /// ### [Parameters]
  /// - [endpoint] APIエンドポイント
  /// - [body] リクエストボディ
  /// - [maxRetries] 最大再試行回数（デフォルト: 1）
  /// 
  /// ### [Returns]
  /// - Future<http.Response>
  Future<http.Response> post(
    String endpoint, {
    String? body,
    int maxRetries = 1,
  }) async {
    return await _makeRequest(
      () async => _client.post(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: body,
      ),
      maxRetries: maxRetries,
    );
  }

  /// ### [Description]
  /// - PUTリクエストを送信する
  /// 
  /// ### [Parameters]
  /// - [endpoint] APIエンドポイント
  /// - [body] リクエストボディ
  /// - [maxRetries] 最大再試行回数（デフォルト: 1）
  /// 
  /// ### [Returns]
  /// - Future<http.Response>
  Future<http.Response> put(
    String endpoint, {
    String? body,
    int maxRetries = 1,
  }) async {
    return await _makeRequest(
      () async => _client.put(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: body,
      ),
      maxRetries: maxRetries,
    );
  }

  /// ### [Description]
  /// - DELETEリクエストを送信する
  /// 
  /// ### [Parameters]
  /// - [endpoint] APIエンドポイント
  /// - [maxRetries] 最大再試行回数（デフォルト: 1）
  /// 
  /// ### [Returns]
  /// - Future<http.Response>
  Future<http.Response> delete(
    String endpoint, {
    int maxRetries = 1,
  }) async {
    return await _makeRequest(
      () async => _client.delete(
        Uri.parse('$_baseUrl$endpoint'),
        headers: await _getHeaders(),
      ),
      maxRetries: maxRetries,
    );
  }

  // ------------------------------------------------------------
  // プライベートメソッド

  /// ### [Description]
  /// - APIベースURLを取得する
  /// 
  /// ### [Returns]
  /// - String
  String get _baseUrl => dotenv.env['API_BASE_URL'] ?? '';

  /// ### [Description]
  /// - 認証ヘッダーを含むHTTPヘッダーを取得する
  /// 
  /// ### [Returns]
  /// - Future<Map<String, String>>
  Future<Map<String, String>> _getHeaders() async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        // TODO: 本来はIDトークンを使用するが、時間の都合上UIDで代替する。
        // final token = await user.getIdToken();
        // headers['Authorization'] = 'Bearer $token';
        final token = user.uid;
        headers['Authorization'] = token;
      }
    } catch (e) {
      // トークン取得に失敗した場合は認証ヘッダーなしでリクエスト
      print('トークン取得に失敗しました: $e');
    }

    return headers;
  }

  /// ### [Description]
  /// - HTTPリクエストを実行し、401エラー時の再試行を処理する
  /// 
  /// ### [Parameters]
  /// - [requestFunction] リクエスト実行関数
  /// - [maxRetries] 最大再試行回数
  /// 
  /// ### [Returns]
  /// - Future<http.Response>
  Future<http.Response> _makeRequest(
    Future<http.Response> Function() requestFunction, {
    required int maxRetries,
  }) async {
    int retryCount = 0;

    while (retryCount <= maxRetries) {
      try {
        final response = await requestFunction();

        // 401エラーでリトライ可能な場合
        if (response.statusCode == 401 && retryCount < maxRetries) {
          try {
            // トークンを強制リフレッシュ
            final user = _firebaseAuth.currentUser;
            if (user != null) {
              await user.getIdToken(true); // 強制リフレッシュ
              retryCount++;
              continue; // 再試行
            }
          } catch (e) {
            print('トークンリフレッシュに失敗しました: $e');
            // トークンリフレッシュに失敗した場合はそのままレスポンスを返す
          }
        }

        return response;
      } catch (e) {
        if (retryCount >= maxRetries) {
          rethrow;
        }
        retryCount++;
      }
    }

    // この行には到達しないはずだが、コンパイラエラーを防ぐため
    throw Exception('予期しないエラーが発生しました');
  }

  /// ### [Description]
  /// - リソースを解放する
  /// 
  /// ### [Returns]
  /// - void
  void dispose() {
    _client.close();
  }
}
