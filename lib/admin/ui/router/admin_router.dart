import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/base_layout_page.dart';
import 'package:job_finder_app/admin/ui/manager/admin_auth_manager.dart';
import 'package:job_finder_app/admin/ui/views/application_view/application_screen.dart';
import 'package:job_finder_app/admin/ui/views/dashboard_view/dashboard_screen.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_screen.dart';
import 'package:job_finder_app/admin/ui/views/feedback_view/feedback_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/jobposting_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_info_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_screen.dart';
import 'package:job_finder_app/admin/ui/views/login_view/admin_login_screen.dart';
import 'package:job_finder_app/admin/ui/views/login_view/reset_password_screen.dart';
import 'package:job_finder_app/admin/ui/views/notification_view/notification_screen.dart';

final GlobalKey<NavigatorState> _adminNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'admin');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

GoRouter buildAdminRouter(AdminAuthManager adminAuthManager) {
  return GoRouter(
    navigatorKey: _adminNavigatorKey,
    initialLocation: adminAuthManager.isAuth ? '/' : '/login',
    routes: <RouteBase>[
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return FutureBuilder(
            future: adminAuthManager.tryAutoLogin(),
            builder: (context, snapshot) {
              return snapshot.connectionState == ConnectionState.waiting
                  ? const CircularProgressIndicator()
                  : const AdminLoginScreen();
            },
          );
        },
        // pageBuilder: (context, state) {
        //   return NoTransitionPage(child: const AdminLoginScreen());
        // },
      ),
      GoRoute(
        path: '/reset-password',
        builder: (context, state) {
          return const ResetPasswordScreen();
        },
        pageBuilder: (context, state) {
          return NoTransitionPage(child: const ResetPasswordScreen());
        },
      ),
      ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) {
            return BaseLayoutPage(child: child);
          },
          routes: <RouteBase>[
            //Hiển thị dashboard
            GoRoute(
              path: '/',
              builder: (context, state) {
                return const DashboardScreen();
              },
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: const DashboardScreen(),
                );
              },
            ),
            //Hiển thị trang chứa tất cả các ứng viên
            GoRoute(
              path: '/jobseeker',
              builder: (context, state) {
                return JobseekerScreen();
              },
              pageBuilder: (context, state) {
                return NoTransitionPage(child: JobseekerScreen());
              },
              routes: <RouteBase>[
                GoRoute(
                  path:
                      'detail', //Route phải là relative path, không được có dấu '/' ở đầu
                  builder: (context, state) {
                    return JobseekerInfoScreen();
                  },
                ),
              ],
            ),
            //Hiển thị trang chứa tất cả các nhà tuyển dụng
            GoRoute(
              path: '/employer',
              builder: (context, state) {
                return EmployerListScreen();
              },
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: EmployerListScreen(),
                );
              },
            ),
            //Hiển thị trang quản lý bài tuyển dụng
            GoRoute(
              path: '/jobposting',
              builder: (context, state) {
                return JobpostingScreen();
              },
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: JobpostingScreen(),
                );
              },
            ),
            //Hiển thị trang quản lý hồ sơ ứng tuyển
            GoRoute(
              path: '/application',
              builder: (context, state) {
                return ApplicationScreen();
              },
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: ApplicationScreen(),
                );
              },
            ),
            //Hiển thị trang quản lý thông báo
            GoRoute(
              path: '/notification',
              builder: (context, state) {
                return NotificationScreen();
              },
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: NotificationScreen(),
                );
              },
            ),
            //Hiển thị trang quản lý feedback
            GoRoute(
              path: '/feedback',
              builder: (context, state) {
                return FeedbackScreen();
              },
              pageBuilder: (context, state) {
                return NoTransitionPage(
                  child: FeedbackScreen(),
                );
              },
            ),
          ])
    ],
  );
}
