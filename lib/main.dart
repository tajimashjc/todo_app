import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:todo_app/features/auth/infrastructure/repositories/firebase/auth_repository_impl.dart';
import 'package:todo_app/features/tasks/domain/repositories/task_repository.dart';
import 'package:todo_app/firebase_options.dart';
import 'package:todo_app/features/tasks/infrastructure/repositories/remote/task_repository_impl.dart';
import 'package:todo_app/features/tasks/infrastructure/repositories/sort_preference_repository_impl.dart';
import 'router/app_router.dart';

void main() async {
  // ---------------------------------------------
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------
  // Firebaseを初期化
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ---------------------------------------------
  // envファイルを読み込む
  await dotenv.load(fileName: '.env');

  // ---------------------------------------------
  const app = MyApp();

  // ---------------------------------------------
  // riverpodのスコープ用のオーバーライドリストを作成
  final overrides = [
    // 認証プロバイダ
    authRepositoryProvider.overrideWithValue(
      AuthRepositoryImpl()
    ),
    // タスクプロバイダ
    taskRepositoryProvider.overrideWithValue(
      TaskRepositoryImpl()
      // MockTaskRepository()
    ),
    sortPreferenceRepositoryProvider.overrideWithValue(
      SortPreferenceRepositoryImpl()
    ),
  ];

  // ---------------------------------------------
  // riverpodのスコープを作成
  var scope = ProviderScope(
    overrides: overrides,
    child: app
  );

  runApp(scope);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ToDo App',
      themeMode: ThemeMode.system,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
      ),
      routerConfig: appRouter,
    );
  }
}
