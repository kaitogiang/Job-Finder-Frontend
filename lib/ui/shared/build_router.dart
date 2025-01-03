import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/models/company.dart';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/models/employer.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/resume.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/employer/application_detail_screen.dart';
import 'package:job_finder_app/ui/employer/company_edit_screen.dart';
import 'package:job_finder_app/ui/employer/employer_jobposting.dart';
import 'package:job_finder_app/ui/employer/employer_profile_screen.dart';
import 'package:job_finder_app/ui/employer/level_addition_screen.dart';
import 'package:job_finder_app/ui/employer/rejected_application_screen.dart';
import 'package:job_finder_app/ui/employer/submitted_application_screen.dart';
import 'package:job_finder_app/ui/employer/tech_addition_screen.dart';
import 'package:job_finder_app/ui/employer/widgets/quill_editor_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/education_addition_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/experience_addition_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/resume_list_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/resume_upload_screen.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_profile_pages/skill_addition_screen.dart';
import 'package:job_finder_app/ui/jobseeker/my_job_screen.dart';
import 'package:job_finder_app/ui/jobseeker/resume_preview/resume_creation_form.dart';
import 'package:job_finder_app/ui/jobseeker/resume_preview/resume_creation_preview.dart';
import 'package:job_finder_app/ui/jobseeker/resume_preview/resume_preview_screen.dart';
import 'package:job_finder_app/ui/jobseeker/search_job_screen.dart';
import 'package:job_finder_app/ui/jobseeker/search_result_screen.dart';
import 'package:job_finder_app/ui/shared/change_email_screen.dart';
import 'package:job_finder_app/ui/shared/change_password_screen.dart';
import 'package:job_finder_app/ui/shared/chat_screen.dart';
import 'package:job_finder_app/ui/shared/company_detail_screen.dart';
import 'package:job_finder_app/ui/shared/image_preview.dart';
import 'package:job_finder_app/ui/shared/job_detail_screen.dart';
import 'package:job_finder_app/ui/shared/jobseeker_detail_screen.dart';
import 'package:job_finder_app/ui/shared/message_screen.dart';
import 'package:job_finder_app/ui/shared/user_setting_screen.dart';
import 'package:path/path.dart';
import '../employer/approved_application_screen.dart';
import '../employer/company_screen.dart';
import '../employer/employer_edit_screen.dart';
import '../employer/jobposting_creation_form.dart';
import '../jobseeker/company_list_screen.dart';
import '../jobseeker/jobseeker_home.dart';
import '../jobseeker/jobseeker_profile_pages/information_edit_screen.dart';
import '../jobseeker/jobseeker_profile_screen.dart';
import 'scaffold_with_navbar.dart';
import 'splash_screen.dart';
import '../auth/auth_screen.dart';

final _rootNavigatorkey = GlobalKey<NavigatorState>(debugLabel: 'root');
// final _generalNavigatorkey = GlobalKey<NavigatorState>(debugLabel: 'general');
final globalNavigatorKey = _rootNavigatorkey;

GoRouter buildRouter(AuthManager authManager) {
  //Ban đầu khi chưa đăng nhập thì sẽ hiển thị màn hình đăng nhập cho người dùng
  //Khi họ đăng nhập xong và thay đổi getter isAuth và gọi notifyListener thì
  //sẽ báo hiệu cho các phần khác bao gồm GoRouter nạp lại giao diện
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
        branches: _buildJobseekerRoutes(),
      ),
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
      ),
      //Route dùng để xem image
      GoRoute(
        parentNavigatorKey: _rootNavigatorkey,
        name: 'image-preview',
        path: '/image-preview',
        builder: (context, state) {
          Map<String, dynamic> data = state.extra as Map<String, dynamic>;
          List<String> images = data['images'] as List<String>;
          int currentIndex = data['index'] as int;
          return ImagePreview(gallaryItems: images, index: currentIndex);
        },
      ),
      //?Xem chi tiết về ứng viên
      GoRoute(
        parentNavigatorKey: _rootNavigatorkey,
        name: 'jobseeker-detail',
        path: '/jobseeker-detail',
        builder: (context, state) => JobseekerDetailScreen(
          jobseekerId: state.extra as String,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorkey,
        name: 'conversation-list',
        path: '/conversation-list',
        builder: (context, state) => MessageScreen(),
        routes: <RouteBase>[
          GoRoute(
            parentNavigatorKey: _rootNavigatorkey,
            name: 'chat',
            path: 'chat',
            builder: (context, state) =>
                ChatScreen(conversationId: state.extra as String),
          )
        ],
      )
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
              builder: (context, state) =>
                  EducationAdditionScreen(education: state.extra as Education?),
            ),
            //Trang hiển thị thêm CV mới
            GoRoute(
              parentNavigatorKey: _rootNavigatorkey,
              name: 'resume-list',
              path: 'resume-list',
              builder: (context, state) => const ResumeListScreen(),
              routes: <RouteBase>[
                GoRoute(
                  parentNavigatorKey: _rootNavigatorkey,
                  name: 'resume-creation',
                  path: 'resume-creation',
                  builder: (context, state) =>
                      const ResumeCreationForm(),
                  routes: <RouteBase>[
                    //Trang dùng để xem trước file PDF của CV
                    //Map chứa jobseeker và các thông tin mô tả bổ sung cho các kinh nghiệm nếu có
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorkey,
                      name: 'resume-creation-preview',
                      path: 'resume-creation-preview',
                      builder: (context, state) => ResumeCreationPreview(
                        data: state.extra as Map<String, dynamic>,
                      ),
                    )
                  ],
                ),
                //Route dùng để xem file PDF trước của CV
                GoRoute(
                  parentNavigatorKey: _rootNavigatorkey,
                  name: 'resume-preview',
                  path: 'resume-preview',
                  builder: (context, state) => ResumePreviewScreen(url: state.extra as String),
                )
              ],
            ),
          ],
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
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
          name: 'employer-home',
          path: '/employer-home',
          builder: (context, state) => const EmployerJobposting(),
          routes: <RouteBase>[
            GoRoute(
                parentNavigatorKey: _rootNavigatorkey,
                name: 'jobposting-creation',
                path: 'jobposting-creation',
                builder: (context, state) => JobpostingCreationForm(
                      jobposting: state.extra as Jobposting?,
                    ),
                routes: <RouteBase>[
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorkey,
                    name: 'quill-editor',
                    path: 'quill-editor',
                    builder: (context, state) {
                      Map<String, dynamic> data =
                          state.extra as Map<String, dynamic>;
                      String title = data['title'] as String;
                      String subtitle = data['subtitle'] as String;
                      Document document = data['document'] as Document;
                      void Function(Document)? onSaved =
                          data['onSaved'] as Function(Document);

                      return QuillEditorScreen(
                        title: title,
                        subtitle: subtitle,
                        document: document,
                        onSaved: onSaved,
                      );
                    },
                  ),
                  //?Trang hiển thị nhập công nghệ yêu cầu
                  GoRoute(
                    parentNavigatorKey: _rootNavigatorkey,
                    name: 'tech-addition',
                    path: 'tech-addition',
                    builder: (context, state) {
                      Map<String, dynamic> data =
                          state.extra as Map<String, dynamic>;
                      void Function(List<String>) onSaved =
                          data['onSaved'] as Function(List<String>);
                      List<String>? techList =
                          data['techList'] as List<String>?;

                      return TechAdditionScreen(
                        onSaved: onSaved,
                        techList: techList,
                      );
                    },
                  ),
                  //?Trang hiển thị thêm trình độ
                  GoRoute(
                      parentNavigatorKey: _rootNavigatorkey,
                      name: 'level-addition',
                      path: 'level-addition',
                      builder: (context, state) {
                        Map<String, dynamic> data =
                            state.extra as Map<String, dynamic>;
                        List<String>? level = data['level'] as List<String>?;
                        void Function(List<String>) onSaved = data['onSaved'];
                        return LevelAdditionScreen(
                          existingLevel: level,
                          onSaved: onSaved,
                        );
                      })
                ])
          ]),
    ]),
    //Nhánh xem danh sách tất cả ứng viên cùng thông tin của họ
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
          name: 'application-list',
          path: '/application-list',
          builder: (context, state) => const SubmittedApplicationScreen(),
          routes: <RouteBase>[
            GoRoute(
              parentNavigatorKey: _rootNavigatorkey,
              name: 'application-detail',
              path: 'application-detail',
              builder: (context, state) => ApplicationDetailScreen(
                applicationStorageId: state.extra as String,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorkey,
              name: 'approved-application',
              path: 'approved-application',
              builder: (context, state) => ApprovedApplicationScreen(
                applicationStorageId: state.extra as String,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorkey,
              name: 'rejected-application',
              path: 'rejected-application',
              builder: (context, state) => RejectedApplicationScreen(
                applicationStorageId: state.extra as String,
              ),
            ),
          ]),
    ]),
    //Nhánh xem những hồ sơ đã duyệt
    // StatefulShellBranch(routes: <RouteBase>[
    //   GoRoute(
    //     name: 'approved-resume',
    //     path: '/approved-resume',
    //     builder: (context, state) => const SafeArea(child: EmployerHome()),
    //   ),
    // ]),
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
    StatefulShellBranch(routes: <RouteBase>[
      GoRoute(
          name: 'conversations',
          path: '/conversations',
          builder: (context, state) => MessageScreen(),
          routes: <RouteBase>[
            GoRoute(
              name: 'chat-detail',
              path: 'chat-detail',
              builder: (context, state) =>
                  ChatScreen(conversationId: state.extra as String),
            )
          ])
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
