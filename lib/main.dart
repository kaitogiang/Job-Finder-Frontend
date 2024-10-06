import 'dart:developer';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_finder_app/services/socket_service.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:job_finder_app/ui/employer/company_manager.dart';
import 'package:job_finder_app/ui/employer/employer_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:job_finder_app/ui/shared/message_manager.dart';
import 'package:provider/provider.dart';

import 'ui/shared/build_router.dart';
import 'ui/shared/utils.dart';
import 'services/firebase_messaging_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  //load the .env file
  await dotenv.load(); //TODO: PHải định nghĩa file .env trong pubspec.yaml
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
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
        ),
        NotificationChannel(
          channelGroupKey: 'message_channel_group',
          channelKey: 'message_channel',
          channelName: 'Message notification',
          channelDescription: 'Messages channel for receiving messages',
          defaultColor: Color(0xFF9D50DD),
          ledColor: Colors.white,
          groupKey: 'message_group_key',
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
  runApp(
    MyApp(
      firebaseAPI: firebaseAPI,
    ),
  );
}

class MyApp extends StatelessWidget {
  MyApp({super.key, required this.firebaseAPI});

  final FirebaseMessagingService firebaseAPI;

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
        seedColor: Colors.blueAccent,
        primary: Color(0xFF0C5FBF),
        secondary: Colors.grey.shade400,
        surface: Colors.white,
        background: Colors.white,
        surfaceTint: Colors.grey,
        onSecondary: Colors.black);

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            Utils.logMessage("AuthManager is being created");
            return AuthManager(firebaseAPI: firebaseAPI);
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, JobseekerManager>(
          create: (context) =>
              JobseekerManager(context.read<AuthManager>().jobseeker),
          update: (context, authManager, jobseekerManager) {
            //TODO Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            jobseekerManager!.authToken = authManager.authToken;
            // jobseekerManager.jobseeker = authManager.jobseeker;
            Utils.logMessage(
                "---- ChangeNotifierProxyProvider<AuthManager, JobseekerManager> ----");
            return jobseekerManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, EmployerManager>(
          create: (context) =>
              EmployerManager(context.read<AuthManager>().employer),
          update: (context, authManager, employerManager) {
            //TODO Khi authManager có báo hiệu thay đổi thì đọc lại authToken
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
            //TODO Khi authManager có báo hiệu thay đổi thì đọc lại authToken
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
            //TODO Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            jobpostingManager!.authToken = authManager.authToken;
            jobpostingManager.socketService = authManager.socketService;
            return jobpostingManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, ApplicationManager>(
          create: (context) => ApplicationManager(),
          update: (context, authManager, applicationManager) {
            //TODO Khi authManager có báo hiệu thay đổi thì đọc lại authToken
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
            //Nạp dữ liệu các cuộc trò chuyện và tin nhắn
            messageManager.getAllConversation();
            //Lắng nghe tin nhắn mới đến
            messageManager.listenToIncomingMessages();
            //Nếu là nhà tuyển dụng thì lắng nghe việc nhận conversation mới từ jobseeker
            if (authManager.isEmployer) {
              messageManager.listenForNewConversation();
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
