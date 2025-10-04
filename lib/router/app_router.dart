import 'package:go_router/go_router.dart';
import 'package:todo_app/presentation/screens/task_detail_screen.dart';
import 'package:todo_app/presentation/screens/task_list_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'task-list',
      builder: (context, state) => const TaskListScreen(),
    ),
    GoRoute(
      path: '/task/:id',
      name: 'task-detail',
      builder: (context, state) {
        final taskId = state.pathParameters['id']!;
        return TaskDetailScreen(taskId: taskId);
      },
    ),
  ],
);

