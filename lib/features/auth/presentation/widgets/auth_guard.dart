import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:todo_app/features/auth/application/state/auth_state.dart';

/// ------------------------------------------------------------
/// 認証状態を監視し、適切な画面にリダイレクトするWidget
class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 認証状態を監視
    ref.listen(authStateNotifierProvider, (previous, next) {
      if (next.isUnauthenticated && previous?.isAuthenticated == true) {
        // 認証状態が未認証になった場合（ログアウトなど）
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (context.mounted) {
            context.go('/sign-in');
          }
        });
      }
    });

    final authState = ref.watch(authStateNotifierProvider);

    // 初期化中の場合はローディング表示
    if (authState.isInitializing) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('認証状態を確認中...'),
            ],
          ),
        ),
      );
    }

    // 未認証の場合はログイン画面にリダイレクト
    if (authState.isUnauthenticated) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          context.go('/sign-in');
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    // 認証済みの場合は子Widgetを表示
    return child;
  }
}
