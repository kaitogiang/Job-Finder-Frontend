import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/models/company.dart';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/models/employer.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/resume.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/employer/company_edit_screen.dart';
import 'package:job_finder_app/ui/employer/employer_profile_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/education_addition_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/experience_addition_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/resume_upload_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/skill_addition_screen.dart';
import 'package:job_finder_app/ui/jobseeker/my_job_screen.dart';
import 'package:job_finder_app/ui/jobseeker/search_job_screen.dart';
import 'package:job_finder_app/ui/jobseeker/search_result_screen.dart';
import 'package:job_finder_app/ui/shared/change_email_screen.dart';
import 'package:job_finder_app/ui/shared/change_password_screen.dart';
import 'package:job_finder_app/ui/shared/company_detail_screen.dart';
import 'package:job_finder_app/ui/shared/image_fullscreen.dart';
import 'package:job_finder_app/ui/shared/image_preview.dart';
import 'package:job_finder_app/ui/shared/job_detail_screen.dart';
import 'package:job_finder_app/ui/shared/user_setting_screen.dart';
import 'package:path/path.dart';
import '../employer/company_screen.dart';
import '../employer/employer_edit_screen.dart';
import '../jobseeker/company_list_screen.dart';
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
    initialLocation: authManager.isAuth
        ? (authManager.isEmployer ? '/employer-home' : '/jobseeker-home')
        : '/login',
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
              )),
      //Routes cho người tìm việc
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: _buildJobseekerRoutes()),
      //Routes cho nhà tuyển dụng
      StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: _buildEmployerRoutes()),
      //Các route bên dưới là các route chung của cả hai người dùng
      GoRoute(
        parentNavigatorKey: _rootNavigatorkey,
        name: 'jobseeker-setting',
        path: '/jobseeker-setting',
        builder: (context, state) => UserSettingScreen(),
        routes: <RouteBase>[
          GoRoute(
            parentNavigatorKey: _rootNavigatorkey,
            name: 'change-email',
            path: 'change-email',
            builder: (context, state) => ChangeEmailScreen(),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorkey,
            name: 'change-password',
            path: 'change-password',
            builder: (context, state) => ChangePasswordScreen(),
          )
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorkey,
        name: 'job-detail',
        path: '/job-detail',
        builder: (context, state) => JobDetailScreen(state.extra as Jobposting),
      ),
      //? Route xem chi tiết công ty
      GoRoute(
          parentNavigatorKey: _rootNavigatorkey,
          name: 'company-detail',
          path: '/company-detail',
          builder: (context, state) =>
              CompanyDetailScreen(state.extra as Company),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorkey,
              name: 'image-preview',
              path: 'image-preview',
              builder: (context, state) {
                Map<String, dynamic> data = state.extra as Map<String, dynamic>;
                List<String> images = data['images'] as List<String>;
                int currentIndex = data['index'] as int;
                return ImagePreview(gallaryItems: images, index: currentIndex);
              },
            ),
          ]),
      //Route dùng để xem image
    ],
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
            builder: (context, state) => JobseekerHome()),
      ],
    ),
    //Nhánh tìm kiếm bài viết hoặc công ty....
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
            name: 'searching',
            path: '/searching',
            builder: (context, state) => const SearchJobScreen(),
            routes: <RouteBase>[
              GoRoute(
                parentNavigatorKey: _rootNavigatorkey,
                name: 'search-result',
                path: 'search-result',
                builder: (context, state) => const SearchResultScreen(),
              )
            ]),
      ],
    ),
    //Nhánh xem công việc đã lưu, đã thích và đã nộp CV
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
            name: 'saved-work',
            path: '/saved-work',
            builder: (context, state) => const MyJobScreen()),
      ],
    ),
    //Nhánh xem danh sách tất cả công ty đã hợp tác
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
            name: 'company',
            path: '/company',
            builder: (context, state) => const CompanyListScreen()),
      ],
    ),
    //Nhánh xem tài khoản cùng các thông tin cá nhân
    StatefulShellBranch(
      routes: <RouteBase>[
        GoRoute(
            name: 'account',
            path: '/account',
            builder: (context, state) => JobseekerProfileScreen(),
            routes: <RouteBase>[
              //Trang chỉnh sửa thông tin cá nhân
              GoRoute(
                  parentNavigatorKey: _rootNavigatorkey,
                  name: 'information-edit',
                  path: 'information-edit',
                  builder: (context, state) => InformationEditScreen(
                        state.extra as Jobseeker,
                      )),
              //Trang thêm skill
              GoRoute(
                  parentNavigatorKey: _rootNavigatorkey,
                  name: 'skill-addition',
                  path: 'skill-addition',
                  builder: (context, state) => SkillAdditionScreen()),
              GoRoute(
                parentNavigatorKey: _rootNavigatorkey,
                name: 'resume-upload',
                path: 'resume-upload',
                builder: (context, state) =>
                    ResumeUploadScreen(resume: state.extra as Resume?),
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigatorkey,
                name: 'experience-addition',
                path: 'experience-addition',
                builder: (context, state) => ExperienceAdditionScreen(
                    experience: state.extra as Experience?),
              ),
              GoRoute(
                parentNavigatorKey: _rootNavigatorkey,
                name: 'education-addition',
                path: 'education-addition',
                builder: (context, state) => EducationAdditionScreen(
                    education: state.extra as Education?),
              ),
            ]),
      ],
    ),
  ];

  return routes;
}

//Các routes con cho nhà tuyển dụng
List<StatefulShellBranch> _buildEmployerRoutes() {
  List<StatefulShellBranch> routes = [
    //Nhánh cho tab bài đăng của nhà tuyển dụng
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
          name: 'employer-home',
          path: '/employer-home',
          builder: (context, state) => CompanyScreen()),
    ]),
    //Nhánh xem danh sách tất cả ứng viên cùng thông tin của họ
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
        name: 'jobseeker-list',
        path: '/jobseeker-list',
        builder: (context, state) => const SafeArea(child: EmployerHome()),
      ),
    ]),
    //Nhánh xem những hồ sơ đã duyệt
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
        name: 'approved-resume',
        path: '/approved-resume',
        builder: (context, state) => const SafeArea(child: EmployerHome()),
      ),
    ]),
    //Nhánh xem và tùy chỉnh thông tin công ty
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
          name: 'company-info',
          path: '/company-info',
          builder: (context, state) => const CompanyScreen(),
          routes: <RouteBase>[
            GoRoute(
                name: 'company-edit',
                path: 'company-edit',
                builder: (context, state) =>
                    CompanyEditScreen(state.extra as Company))
          ]),
    ]),
    //Nhánh xem tài khoản cho nhà tuyển dụng
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
          name: 'employer-info',
          path: '/employer-info',
          builder: (context, state) => EmployerProfileScreen(),
          routes: <RouteBase>[
            GoRoute(
              name: 'employer-edit',
              path: 'employer-edit',
              builder: (context, state) =>
                  EmployerEditScreen(state.extra as Employer),
            )
          ])
    ])
  ];

  return routes;
}
