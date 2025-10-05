import 'package:go_router/go_router.dart';
import 'package:todo_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:todo_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:todo_app/features/auth/presentation/widgets/auth_guard.dart';
import 'package:todo_app/features/tasks/presentation/screens/task_detail_screen.dart';
import 'package:todo_app/features/tasks/presentation/screens/task_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    // 認証画面
    GoRoute(
      path: '/sign-in',
      name: 'sign-in',
      builder: (context, state) => const SignInScreen(),
    ),
    GoRoute(
      path: '/sign-up',
      name: 'sign-up',
      builder: (context, state) => const SignUpScreen(),
    ),
    // タスク画面（認証が必要）
    GoRoute(
      path: '/',
      name: 'task-list',
      builder: (context, state) => const AuthGuard(
        child: TaskListScreen(),
      ),
    ),
    GoRoute(
      path: '/task/:id',
      name: 'task-detail',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return AuthGuard(
          child: TaskDetailScreen(taskId: taskId),
        );
      },
    ),
  ],
);

