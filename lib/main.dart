import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_app/domain/repositories/task_repository.dart';
import 'package:todo_app/infrastructure/mock/mock_task_repository.dart';
import 'package:todo_app/infrastructure/repositories/task_repository_impl.dart';
import 'router/app_router.dart';

void main() async {
  // ---------------------------------------------
  WidgetsFlutterBinding.ensureInitialized();

  // ---------------------------------------------
  // envファイルを読み込む
  await dotenv.load(fileName: '.env');

  // ---------------------------------------------
  const app = MyApp();

  // ---------------------------------------------
  // riverpodのスコープ用のオーバーライドリストを作成
  final overrides = [
    taskRepositoryProvider.overrideWithValue(
      TaskRepositoryImpl()
      // MockTaskRepository()
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
