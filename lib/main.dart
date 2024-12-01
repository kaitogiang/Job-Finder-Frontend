import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:job_finder_app/admin/ui/manager/admin_auth_manager.dart';
import 'package:job_finder_app/admin/ui/manager/application_list_manager.dart';
import 'package:job_finder_app/admin/ui/manager/employer_list_manager.dart';
import 'package:job_finder_app/admin/ui/manager/jobposting_list_manager.dart';
import 'package:job_finder_app/admin/ui/manager/stats_manager.dart';
import 'package:job_finder_app/admin/ui/router/admin_router.dart';
import 'package:job_finder_app/ui/shared/message_notificaion_controller.dart';
import 'firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:job_finder_app/ui/employer/company_manager.dart';
import 'package:job_finder_app/ui/employer/employer_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:job_finder_app/ui/shared/message_manager.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'ui/shared/build_router.dart';
import 'ui/shared/utils.dart';
import 'services/firebase_messaging_service.dart';

import 'package:job_finder_app/admin/ui/manager/jobseeker_list_manager.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  //load the .env file
  await dotenv.load(); //PHải định nghĩa file .env trong pubspec.yaml

  debugPrint("Gia tri cua kIsWeb: $kIsWeb");
  if (kIsWeb) {
    log("Chay app admin");
    //Gọi hàm này để chuyển url từ /#/admin/... thành /admin...
    usePathUrlStrategy();
    runApp(AdminApp());
  } else {
    //? Khởi tạo Notification cho ứng dụng
    AwesomeNotifications().initialize(
        // set the icon to null if you want to use the default app icon
        'resource://drawable/notification',
        [
          NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for basic tests',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white,
          ),
          NotificationChannel(
            channelGroupKey: 'message_channel_group',
            channelKey: 'message_channel',
            channelName: 'Message notification',
            channelDescription: 'Messages channel for receiving messages',
            defaultColor: const Color(0xFF9D50DD),
            ledColor: Colors.white,
            groupKey: 'message_group_key',
            importance: NotificationImportance.High,
          ),
        ],
        // Channel groups are only visual and are not required
        channelGroups: [
          NotificationChannelGroup(
              channelGroupKey: 'basic_channel_group',
              channelGroupName: 'Basic group')
        ],
        debug: true);
    FirebaseMessagingService firebaseAPI = FirebaseMessagingService();
    await firebaseAPI.firebaseMessagingInit();
    await firebaseAPI.setUpInteractedMessage();
    //Thiết lập xử lý nhận thông báo tin nhắn khi ứng dụng
    //đang ở foreground
    MessageNotificaionController.initialize(globalNavigatorKey);
    runApp(
      MyApp(
        firebaseAPI: firebaseAPI,
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.firebaseAPI});

  final FirebaseMessagingService firebaseAPI;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        primary: const Color(0xFF0C5FBF),
        secondary: Colors.grey.shade400,
        surface: Colors.white,
        // background: Colors.white, //lỗi thời
        surfaceTint: Colors.grey,
        onSecondary: Colors.black);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            Utils.logMessage("AuthManager is being created");
            //Gán NavigatorKey trong Build_router
            firebaseAPI.globalNavigatorKey = globalNavigatorKey;
            return AuthManager(firebaseAPI: firebaseAPI);
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, JobseekerManager>(
          create: (context) =>
              JobseekerManager(context.read<AuthManager>().jobseeker),
          update: (context, authManager, jobseekerManager) {
            //Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            jobseekerManager!.authToken = authManager.authToken;
            // jobseekerManager.jobseeker = authManager.jobseeker;
            //Truyền socketService vào cho JobseekerManager
            jobseekerManager.socketService = authManager.socketService;
            Utils.logMessage(
                "---- ChangeNotifierProxyProvider<AuthManager, JobseekerManager> ----");
            return jobseekerManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, EmployerManager>(
          create: (context) =>
              EmployerManager(context.read<AuthManager>().employer),
          update: (context, authManager, employerManager) {
            //Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            employerManager!.authToken = authManager.authToken;
            Utils.logMessage(
                "---- ChangeNotifierProxyProvider<AuthManager, EmployerManager> ----");
            return employerManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, CompanyManager>(
          create: (context) => CompanyManager(),
          update: (context, authManager, companyManager) {
            //Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            companyManager!.authToken = authManager.authToken;
            Utils.logMessage(
                "---- ChangeNotifierProxyProvider<AuthManager, CompanyManager> ----");
            return companyManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, JobpostingManager>(
          create: (context) => JobpostingManager(),
          update: (context, authManager, jobpostingManager) {
            //Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            jobpostingManager!.authToken = authManager.authToken;
            jobpostingManager.socketService = authManager.socketService;
            return jobpostingManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, ApplicationManager>(
          create: (context) => ApplicationManager(),
          update: (context, authManager, applicationManager) {
            //Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            applicationManager!.authToken = authManager.authToken;
            Utils.logMessage(
                "---- ChangeNotifierProxyProvider<AuthManager, ApplicationManager> ----");
            return applicationManager;
          },
        ),
        //Manager quản lý tin nhắn
        ChangeNotifierProxyProvider<AuthManager, MessageManager>(
          create: (context) => MessageManager(),
          update: (context, authManager, messageManager) {
            Utils.logMessage('Goi update MessageManager');
            //Gán lại authToken khi AuthManager thay đổi
            messageManager!.authToken = authManager.authToken;
            //Truyền socketService vào cho MessageManager
            messageManager.socketService = authManager.socketService;
            /*
              Riêng các hàm nạp dữ liệu và lắng nghe tin nhắn mới thì nếu
              khi người dùng đã đăng xuất rồi thì không gọi lại những hàm này.
              Những hàm này chỉ được gọi khi người dùng đăng nhập vào hệ thống
              để khởi tạo danh sách tin nhắn và lắng nghe khi có tin nhắn mới
            */
            if (authManager.authToken != null) {
              //Nạp dữ liệu các cuộc trò chuyện và tin nhắn
              messageManager.getAllConversation();
              //Lắng nghe tin nhắn mới đến
              messageManager.listenToIncomingMessages();
              //Nếu là nhà tuyển dụng thì lắng nghe việc nhận conversation mới từ jobseeker
              if (authManager.isEmployer) {
                messageManager.listenForNewConversation();
              }
            }
            return messageManager;
          },
        ),
      ],
      child: Consumer<AuthManager>(builder: (ctx, authManager, child) {
        return MaterialApp.router(
          title: 'Job Finder App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'Lato',
            colorScheme: colorScheme,
            appBarTheme: AppBarTheme(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                elevation: 4,
                shadowColor: colorScheme.shadow),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: colorScheme.secondary,
                showUnselectedLabels: true),
          ),
          routerConfig: buildRouter(authManager),
        );
      }),
    );
  }
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        primary: const Color(0xFF0C5FBF),
        secondary: Colors.grey.shade400,
        surface: Colors.white,
        // background: Colors.white, //lỗi thời
        surfaceTint: Colors.grey,
        onSecondary: Colors.black);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AdminAuthManager()),
        ChangeNotifierProxyProvider<AdminAuthManager, JobseekerListManager>(
          create: (context) => JobseekerListManager(),
          update: (context, adminAuthManager, jobseekerListManager) {
            //Cập nhật lại authToken cho JobseekerListManager
            jobseekerListManager!.authToken = adminAuthManager.authToken;
            return jobseekerListManager;
          },
        ),
        ChangeNotifierProxyProvider<AdminAuthManager, EmployerListManager>(
          create: (context) => EmployerListManager(),
          update: (context, adminAuthManager, employerListManager) {
            employerListManager!.authToken = adminAuthManager.authToken;
            return employerListManager;
          },
        ),
        ChangeNotifierProxyProvider<AdminAuthManager, JobpostingListManager>(
          create: (context) => JobpostingListManager(),
          update: (context, adminAuthManager, jobpostingListManager) {
            jobpostingListManager!.authToken = adminAuthManager.authToken;
            return jobpostingListManager;
          },
        ),
        ChangeNotifierProxyProvider<AdminAuthManager, ApplicationListManager>(
          create: (context) => ApplicationListManager(),
          update: (context, adminAuthManager, aplicationListManager) {
            aplicationListManager!.authToken = adminAuthManager.authToken;
            return aplicationListManager;
          },
        ),
        ChangeNotifierProxyProvider<AdminAuthManager, StatsManager>(
          create: (context) => StatsManager(),
          update: (context, adminAuthManager, statsManager) {
            statsManager!.authToken = adminAuthManager.authToken;
            return statsManager;
          },
        ),
      ],
      child: Consumer<AdminAuthManager>(
          builder: (context, adminAuthManager, child) {
        return MaterialApp.router(
          title: 'Admin App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: colorScheme,
          ),
          routerConfig: buildAdminRouter(adminAuthManager),
        );
      }),
    );
  }
}
