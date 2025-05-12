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

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final globalNavigatorKey = _rootNavigatorKey;

GoRouter buildRouter(AuthManager authManager) {
  // Initially show login screen when not authenticated
  // After login and notifyListener is called, GoRouter will rebuild UI based on user type
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: authManager.isAuth
        ? (authManager.isEmployer ? '/employer-home' : '/jobseeker-home')
        : '/login',
    routes: [
      GoRoute(
        name: 'login',
        path: '/login',
        builder: (context, state) => FutureBuilder(
          future: authManager.tryAutoLogin(),
          builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting
              ? const SafeArea(child: SplashScreen())
              : const SafeArea(child: AuthScreen()),
        ),
      ),
      // Routes for job seeker
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => 
          ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: _buildJobseekerRoutes(),
      ),
      // Routes for employer
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
          ScaffoldWithNavBar(navigationShell: navigationShell),
        branches: _buildEmployerRoutes(),
      ),
      // Shared routes for both user types
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        name: 'jobseeker-setting',
        path: '/jobseeker-setting',
        builder: (context, state) => UserSettingScreen(),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            name: 'change-email',
            path: 'change-email',
            builder: (context, state) => ChangeEmailScreen(),
          ),
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            name: 'change-password',
            path: 'change-password',
            builder: (context, state) => ChangePasswordScreen(),
          )
        ],
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        name: 'job-detail',
        path: '/job-detail',
        builder: (context, state) => JobDetailScreen(state.extra as Jobposting),
      ),
      // Route for company details
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        name: 'company-detail',
        path: '/company-detail',
        builder: (context, state) => CompanyDetailScreen(state.extra as Company),
      ),
      // Route for image preview
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        name: 'image-preview',
        path: '/image-preview',
        builder: (context, state) {
          final data = state.extra as Map<String, dynamic>;
          return ImagePreview(
            gallaryItems: data['images'] as List<String>,
            index: data['index'] as int,
          );
        },
      ),
      // Route for job seeker details
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        name: 'jobseeker-detail',
        path: '/jobseeker-detail',
        builder: (context, state) => JobseekerDetailScreen(
          jobseekerId: state.extra as String,
        ),
      ),
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        name: 'conversation-list',
        path: '/conversation-list',
        builder: (context, state) => MessageScreen(),
        routes: [
          GoRoute(
            parentNavigatorKey: _rootNavigatorKey,
            name: 'chat',
            path: 'chat',
            builder: (context, state) => ChatScreen(
              conversationId: state.extra as String,
            ),
          )
        ],
      )
    ],
  );
}

// Child routes for job seeker
List<StatefulShellBranch> _buildJobseekerRoutes() {
  return [
    // Branch for job seeker home tab
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'jobseeker-home',
          path: '/jobseeker-home',
          builder: (context, state) => JobseekerHome(),
        ),
      ],
    ),
    // Branch for job/company search
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'searching',
          path: '/searching',
          builder: (context, state) => const SearchJobScreen(),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'search-result',
              path: 'search-result',
              builder: (context, state) => const SearchResultScreen(),
            )
          ],
        ),
      ],
    ),
    // Branch for saved jobs, liked jobs and submitted applications
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'saved-work',
          path: '/saved-work',
          builder: (context, state) => const MyJobScreen(),
        ),
      ],
    ),
    // Branch for viewing all partner companies
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'company',
          path: '/company',
          builder: (context, state) => const CompanyListScreen(),
        ),
      ],
    ),
    // Branch for account and personal information
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'account',
          path: '/account',
          builder: (context, state) => JobseekerProfileScreen(),
          routes: [
            // Personal information edit page
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'information-edit',
              path: 'information-edit',
              builder: (context, state) => InformationEditScreen(
                state.extra as Jobseeker,
              ),
            ),
            // Skill addition page
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'skill-addition',
              path: 'skill-addition',
              builder: (context, state) => SkillAdditionScreen(),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'resume-upload',
              path: 'resume-upload',
              builder: (context, state) => ResumeUploadScreen(
                resume: state.extra as Resume?,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'experience-addition',
              path: 'experience-addition',
              builder: (context, state) => ExperienceAdditionScreen(
                experience: state.extra as Experience?,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'education-addition',
              path: 'education-addition',
              builder: (context, state) => EducationAdditionScreen(
                education: state.extra as Education?,
              ),
            ),
            // Resume list display page
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'resume-list',
              path: 'resume-list',
              builder: (context, state) => const ResumeListScreen(),
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  name: 'resume-creation',
                  path: 'resume-creation',
                  builder: (context, state) => const ResumeCreationForm(),
                  routes: [
                    // PDF preview page for resume
                    GoRoute(
                      parentNavigatorKey: _rootNavigatorKey,
                      name: 'resume-creation-preview',
                      path: 'resume-creation-preview',
                      builder: (context, state) => ResumeCreationPreview(
                        data: state.extra as Map<String, dynamic>,
                      ),
                    )
                  ],
                ),
                // Route for PDF preview
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  name: 'resume-preview',
                  path: 'resume-preview',
                  builder: (context, state) => ResumePreviewScreen(
                    url: state.extra as String,
                  ),
                )
              ],
            ),
          ],
        ),
      ],
    ),
  ];
}

// Child routes for employer
List<StatefulShellBranch> _buildEmployerRoutes() {
  return [
    // Branch for employer job postings tab
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'employer-home',
          path: '/employer-home',
          builder: (context, state) => const EmployerJobposting(),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'jobposting-creation',
              path: 'jobposting-creation',
              builder: (context, state) => JobpostingCreationForm(
                jobposting: state.extra as Jobposting?,
              ),
              routes: [
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  name: 'quill-editor',
                  path: 'quill-editor',
                  builder: (context, state) {
                    final data = state.extra as Map<String, dynamic>;
                    return QuillEditorScreen(
                      title: data['title'] as String,
                      subtitle: data['subtitle'] as String,
                      document: data['document'] as Document,
                      onSaved: data['onSaved'] as Function(Document),
                    );
                  },
                ),
                // Required technology input page
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  name: 'tech-addition',
                  path: 'tech-addition',
                  builder: (context, state) {
                    final data = state.extra as Map<String, dynamic>;
                    return TechAdditionScreen(
                      onSaved: data['onSaved'] as Function(List<String>),
                      techList: data['techList'] as List<String>?,
                    );
                  },
                ),
                // Level addition page
                GoRoute(
                  parentNavigatorKey: _rootNavigatorKey,
                  name: 'level-addition',
                  path: 'level-addition',
                  builder: (context, state) {
                    final data = state.extra as Map<String, dynamic>;
                    return LevelAdditionScreen(
                      existingLevel: data['level'] as List<String>?,
                      onSaved: data['onSaved'] as Function(List<String>),
                    );
                  },
                )
              ],
            )
          ],
        ),
      ],
    ),
    // Branch for viewing all candidates and their information
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'application-list',
          path: '/application-list',
          builder: (context, state) => const SubmittedApplicationScreen(),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'application-detail',
              path: 'application-detail',
              builder: (context, state) => ApplicationDetailScreen(
                applicationStorageId: state.extra as String,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'approved-application',
              path: 'approved-application',
              builder: (context, state) => ApprovedApplicationScreen(
                applicationStorageId: state.extra as String,
              ),
            ),
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              name: 'rejected-application',
              path: 'rejected-application',
              builder: (context, state) => RejectedApplicationScreen(
                applicationStorageId: state.extra as String,
              ),
            ),
          ],
        ),
      ],
    ),
    // Branch for viewing and customizing company information
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'company-info',
          path: '/company-info',
          builder: (context, state) => const CompanyScreen(),
          routes: [
            GoRoute(
              name: 'company-edit',
              path: 'company-edit',
              builder: (context, state) => CompanyEditScreen(
                state.extra as Company,
              ),
            )
          ],
        ),
      ],
    ),
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'conversations',
          path: '/conversations',
          builder: (context, state) => MessageScreen(),
          routes: [
            GoRoute(
              name: 'chat-detail',
              path: 'chat-detail',
              builder: (context, state) => ChatScreen(
                conversationId: state.extra as String,
              ),
            )
          ],
        ),
      ],
    ),
    // Branch for employer account
    StatefulShellBranch(
      routes: [
        GoRoute(
          name: 'employer-info',
          path: '/employer-info',
          builder: (context, state) => EmployerProfileScreen(),
          routes: [
            GoRoute(
              name: 'employer-edit',
              path: 'employer-edit',
              builder: (context, state) => EmployerEditScreen(
                state.extra as Employer,
              ),
            )
          ],
        ),
      ],
    )
  ];
}
