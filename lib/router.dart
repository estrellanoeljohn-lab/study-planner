import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/auth/auth_providers.dart';
import 'features/auth/create_account_screen.dart';
import 'features/auth/sign_in_screen.dart';
import 'features/courses/add_course_screen.dart';
import 'features/courses/courses_screen.dart';
import 'features/focus/focus_screen.dart';
import 'features/stats/stats_screen.dart';
import 'features/today/today_screen.dart';
import 'shell/app_shell.dart';
import 'features/tasks/add_task_screen.dart';
class _AuthRefresh extends ChangeNotifier {
  _AuthRefresh(Stream<User?> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<User?> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  final refresh = _AuthRefresh(repo.userChanges());
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/sign-in',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = repo.currentUser != null;
      final atAuth = state.matchedLocation == '/sign-in' ||
          state.matchedLocation == '/create-account';
      if (!loggedIn && !atAuth) return '/sign-in';
      if (loggedIn && atAuth) return '/today';
      return null;
    },
    routes: [
      GoRoute(
        path: '/sign-in',
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: '/create-account',
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: '/add-course',
        builder: (context, state) => const AddCourseScreen(),
      ),
      GoRoute(
        path: '/add-task',
        builder: (context, state) => const AddTaskScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/today',
              builder: (context, state) => const TodayScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/courses',
              builder: (context, state) => const CoursesScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/focus',
              builder: (context, state) => const FocusScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/stats',
              builder: (context, state) => const StatsScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});