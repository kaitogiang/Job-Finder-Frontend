import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';

import '../jobseeker/jobseeker_home.dart';
import '../jobseeker/jobseeker_profile_pages/information_edit_screen.dart';
import '../jobseeker/jobseeker_profile_screen.dart';
import '../employer/employer_home.dart';
import 'scaffold_with_navbar.dart';
import 'splash_screen.dart';
import '../auth/auth_screen.dart';

final _rootNavigatorkey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter buildRouter(AuthManager authManager) {
  return GoRouter(
    navigatorKey: _rootNavigatorkey,
    initialLocation: authManager.isAuth ? (authManager.isEmployer ? '/employer-home' : '/jobseeker-home') : '/login',
    routes: <RouteBase>[
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => FutureBuilder(
          future: authManager.tryAutoLogin(),
          builder: (ctx, snapshot) {
            return snapshot.connectionState == ConnectionState.waiting
              ? const SafeArea(child: SplashScreen())
              : const SafeArea(child: AuthScreen());
          },
        )
      ),
      //Routes cho người tìm việc
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: _buildJobseekerRoutes()
      ),
      //Routes cho nhà tuyển dụng
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: _buildEmployerRoutes()
      )
    ]
  );
}

//Các routes con cho người tìm việc
List<StatefulShellBranch> _buildJobseekerRoutes() {
  List<StatefulShellBranch> routes = [
    //Nhánh cho tab trang chủ của người tìm việc
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          name: 'jobseeker-home',
          path: '/jobseeker-home',
          builder: (context, state) => InformationEditScreen()
        ),
      ],
    ),
    //Nhánh tìm kiếm bài viết hoặc công ty....
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          name: 'searching',
          path: '/searching',
          builder: (context, state) => const SafeArea(child: JobseekerHome())
        ),
      ],
    ),
    //Nhánh xem công việc đã lưu, đã thích và đã nộp CV
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          name: 'saved-work',
          path: '/saved-work',
          builder: (context, state) => const SafeArea(child: JobseekerHome())
        ),
      ],
    ),
    //Nhánh xem danh sách tất cả công ty đã hợp tác
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          name: 'company',
          path: '/company',
          builder: (context, state) => const SafeArea(child: JobseekerHome())
        ),
      ],
    ),
    //Nhánh xem tài khoản cùng các thông tin cá nhân
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          name: 'account',
          path: '/account',
          builder: (context, state) => const SafeArea(child: JobseekerProfileScreen()),
          routes: <RouteBase>[
            GoRoute(
              parentNavigatorKey: _rootNavigatorkey,
              name: 'information-edit',
              path: 'information-edit',
              builder: (context, state) => const SafeArea(child: const InformationEditScreen())
            )
          ]
        ),
      ],
    ),
  ];

  return routes;
}

//Các routes con cho nhà tuyển dụng
List<StatefulShellBranch> _buildEmployerRoutes() {
  List<StatefulShellBranch> routes = [
    //Nhánh cho tab bài đăng của nhà tuyển dụng
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          name: 'employer-home',
          path: '/employer-home',
          builder: (context, state) => const SafeArea(child: EmployerHome())
        )
      ]
    ),
  ];

  return routes;
}

