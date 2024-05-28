import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';

import '../employee/employee-home.dart';
import '../employer/employer_home.dart';
import 'scaffold_with_navbar.dart';
import 'splash_screen.dart';
import '../auth/auth_screen.dart';

final _rootNavigatorkey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter buildRouter(AuthManager authManager) {
  return GoRouter(
    navigatorKey: _rootNavigatorkey,
    initialLocation: authManager.isAuth ? (authManager.isEmployer ? '/employer-home' : '/employee-home') : '/login',
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
        branches: _buildEmployeeRoutes()
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
List<StatefulShellBranch> _buildEmployeeRoutes() {
  List<StatefulShellBranch> routes = [
    //Nhánh cho tab trang chủ của người tìm việc
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
          name: 'employee-home',
          path: '/employee-home',
          builder: (context, state) => const SafeArea(child: EmployeeHome())
        )
      ]
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

