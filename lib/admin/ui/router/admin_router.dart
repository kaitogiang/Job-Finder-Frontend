import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/base_layout_page.dart';
import 'package:job_finder_app/admin/ui/manager/admin_auth_manager.dart';
import 'package:job_finder_app/admin/ui/manager/employer_list_manager.dart';
import 'package:job_finder_app/admin/ui/manager/jobseeker_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/application_view/application_screen.dart';
import 'package:job_finder_app/admin/ui/views/dashboard_view/dashboard_screen.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_account_screen.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_detail_screen.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_screen.dart';
import 'package:job_finder_app/admin/ui/views/feedback_view/feedback_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/jobposting_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_detail_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_info_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/locked_jobseeker_detail_screen.dart';
import 'package:job_finder_app/admin/ui/views/login_view/admin_login_screen.dart';
import 'package:job_finder_app/admin/ui/views/login_view/reset_password_screen.dart';
import 'package:job_finder_app/admin/ui/views/notification_view/notification_screen.dart';
import 'package:job_finder_app/admin/ui/widgets/custom_alert.dart';
import 'package:job_finder_app/admin/ui/widgets/dialog_page.dart';
import 'package:job_finder_app/admin/ui/widgets/modal.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> _adminNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'admin');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');
final GlobalKey<NavigatorState> _jobseekerNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'jobseeker');

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
      // ShellRoute(
      //   navigatorKey: _shellNavigatorKey,
      //   builder: (context, state, child) {
      //     return BaseLayoutPage(child: child);
      //   },
      //   routes: <RouteBase>[
      //     //Hiển thị dashboard
      //     GoRoute(
      //       path: '/',
      //       builder: (context, state) {
      //         return const DashboardScreen();
      //       },
      //       pageBuilder: (context, state) {
      //         return NoTransitionPage(
      //           child: const DashboardScreen(),
      //         );
      //       },
      //     ),
      //     //Hiển thị trang chứa tất cả các ứng viên
      //     GoRoute(
      //       path: '/jobseeker',
      //       builder: (context, state) {
      //         return JobseekerScreen();
      //       },
      //       // pageBuilder: (context, state) {
      //       //   return MaterialPage<dynamic>(child: JobseekerScreen());
      //       // },
      //       routes: <RouteBase>[
      //         GoRoute(
      //           // parentNavigatorKey: _adminNavigatorKey,
      //           path:
      //               'detail', //Route phải là relative path, không được có dấu '/' ở đầu
      //           builder: (context, state) {
      //             return JobseekerDetailScreen();
      //           },
      //         ),
      //       ],
      //     ),
      //     //Hiển thị trang chứa tất cả các nhà tuyển dụng
      //     GoRoute(
      //       path: '/employer',
      //       builder: (context, state) {
      //         return EmployerScreen();
      //       },
      //       pageBuilder: (context, state) {
      //         return NoTransitionPage(
      //           child: EmployerScreen(),
      //         );
      //       },
      //     ),
      //     //Hiển thị trang quản lý bài tuyển dụng
      //     GoRoute(
      //       path: '/jobposting',
      //       builder: (context, state) {
      //         return JobpostingScreen();
      //       },
      //       pageBuilder: (context, state) {
      //         return NoTransitionPage(
      //           child: JobpostingScreen(),
      //         );
      //       },
      //     ),
      //     //Hiển thị trang quản lý hồ sơ ứng tuyển
      //     GoRoute(
      //       path: '/application',
      //       builder: (context, state) {
      //         return ApplicationScreen();
      //       },
      //       pageBuilder: (context, state) {
      //         return NoTransitionPage(
      //           child: ApplicationScreen(),
      //         );
      //       },
      //     ),
      //     //Hiển thị trang quản lý thông báo
      //     GoRoute(
      //       path: '/notification',
      //       builder: (context, state) {
      //         return NotificationScreen();
      //       },
      //       pageBuilder: (context, state) {
      //         return NoTransitionPage(
      //           child: NotificationScreen(),
      //         );
      //       },
      //     ),
      //     //Hiển thị trang quản lý feedback
      //     GoRoute(
      //       path: '/feedback',
      //       builder: (context, state) {
      //         return FeedbackScreen();
      //       },
      //       pageBuilder: (context, state) {
      //         return NoTransitionPage(
      //           child: FeedbackScreen(),
      //         );
      //       },
      //     ),
      //   ],
      // )
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: _adminNavigatorKey,
        pageBuilder: (context, state, navigationShell) {
          return NoTransitionPage(
              child: BaseLayoutPage(child: navigationShell));
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              //Hiển thị dashboard
              GoRoute(
                path: '/',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: const DashboardScreen());
                },
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _jobseekerNavigatorKey,
            routes: <RouteBase>[
              //Hiển thị trang chứa tất cả các ứng viên
              GoRoute(
                path: '/jobseeker',
                pageBuilder: (context, state) {
                  //Thêm từ khóa const vào trước parent để làm cho nó không bị built
                  //Mà được lưu vào bộ nhớ
                  return NoTransitionPage(child: const JobseekerScreen());
                },
                routes: [
                  //Route hiển thị xem chi tiết thông tin Jobseeker
                  GoRoute(
                    parentNavigatorKey: _adminNavigatorKey,
                    path: 'profile/:id',
                    pageBuilder: (context, state) {
                      final jobseekerId = state.pathParameters['id'];
                      Utils.logMessage('Context: $context');
                      Utils.logMessage('Jobseeker ID: $jobseekerId');
                      //Caching future để tránh việc JobseekerDetailScreen bị rebuild
                      final jobseekeFuture = context
                          .read<JobseekerListManager>()
                          .getJobseekerById(jobseekerId!);

                      return DialogPage(
                        builder: (context) => Modal(
                          title: 'Thông tin chi tiết ứng viên',
                          headerIcon: 'assets/images/jobseeker.png',
                          content: JobseekerDetailScreen(
                            jobseekerFuture: jobseekeFuture,
                          ),
                        ),
                      );
                    },
                  ),
                  //Route hiển thị xem thông tin về tài khoản bị Khóa
                  GoRoute(
                    parentNavigatorKey: _adminNavigatorKey,
                    path: 'locked-user/:id',
                    pageBuilder: (context, state) {
                      final jobseekerId = state.pathParameters['id']!;
                      Utils.logMessage('Context: $context');
                      Utils.logMessage('Jobseeker ID: $jobseekerId');
                      //Caching future để tránh việc JobseekerDetailScreen bị rebuild
                      final basicInfoFuture = context
                          .read<JobseekerListManager>()
                          .getJobseekerById(jobseekerId);
                      final lockedInfoFuture = context
                          .read<JobseekerListManager>()
                          .getLockedJobseekerById(jobseekerId);

                      return DialogPage(
                        builder: (context) => Modal(
                          title: 'Thông tin ứng viên bị khóa',
                          headerIcon: 'assets/images/locked-user.png',
                          content: LockedJobseekerDetailScreen(
                            basicInfoFuture: basicInfoFuture,
                            lockedInfoFuture: lockedInfoFuture,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              //Hiển thị trang chứa tất cả các nhà tuyển dụng
              GoRoute(
                path: '/employer',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: const EmployerScreen());
                },
                routes: [
                  GoRoute(
                    parentNavigatorKey: _adminNavigatorKey,
                    path: 'company-info/:id',
                    pageBuilder: (context, state) {
                      //Tạo một future để lấy thông tin của company và gửi vào EmployerDetailScreen
                      String companyId = state.pathParameters['id']!;
                      final companyFuture = context
                          .read<EmployerListManager>()
                          .getCompanyById(companyId);
                      //Tạo một future để lấy danh sách các bài tuyển dụng của công ty
                      final jobpostingsFuture = context
                          .read<EmployerListManager>()
                          .getCompanyJobpostings(companyId);

                      return DialogPage(
                        builder: (context) => Modal(
                          title: 'Thông tin chi tiết công ty',
                          headerIcon: 'assets/images/company.png',
                          content: EmployerDetailScreen(
                            companyFuture: companyFuture,
                            jobpostingsFuture: jobpostingsFuture,
                          ),
                        ),
                      );
                    },
                  ),
                  GoRoute(
                    parentNavigatorKey: _adminNavigatorKey,
                    path: 'employer-account/:id',
                    pageBuilder: (context, state) {
                      final employerId = state.pathParameters['id']!;
                      //Tạo một future để lấy thông tin của một employer dựa vào employerId
                      final employerFuture = context
                          .read<EmployerListManager>()
                          .getEmployerById(employerId);
                      //Tạo một future để lấy thông tin của một company dựa vào employerId
                      final companyFuture = context
                          .read<EmployerListManager>()
                          .getCompanyByEmployerId(employerId);
                      //Tạo một future để kiểm tra xem tài khoản có bị khóa không
                      final isLockedFuture = context
                          .read<EmployerListManager>()
                          .checkLockedAccount(employerId);

                      return DialogPage(
                        builder: (context) => Modal(
                          title: 'Thông tin tài khoản nhà tuyển dụng',
                          headerIcon: 'assets/images/company.png',
                          content: EmployerAccountScreen(
                            employerFuture: employerFuture,
                            companyFuture: companyFuture,
                            isLockedFuture: isLockedFuture,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              //Hiển thị trang quản lý bài tuyển dụng
              GoRoute(
                path: '/jobposting',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: JobpostingScreen());
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              //Hiển thị trang quản lý feedback
              GoRoute(
                path: '/application',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: ApplicationScreen());
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              //Hiển thị trang quản lý thông báo
              GoRoute(
                path: '/notification',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: NotificationScreen());
                },
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              //Hiển thị trang quản lý feedback
              GoRoute(
                path: '/feedback',
                pageBuilder: (context, state) {
                  return NoTransitionPage(child: FeedbackScreen());
                },
              ),
            ],
          ),
        ],
      )
    ],
  );
}
