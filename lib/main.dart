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
  await dotenv.load(); //Must define .env file in pubspec.yaml

  debugPrint("Value of kIsWeb: $kIsWeb");
  if (kIsWeb) {
    log("Running admin app");
    //Call this function to change url from /#/admin/... to /admin...
    usePathUrlStrategy();
    runApp(AdminApp());
  } else {
    //? Initialize Notifications for the application
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
    //Set up handling of message notifications when application
    //is in foreground
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
        // background: Colors.white, //deprecated
        surfaceTint: Colors.grey,
        onSecondary: Colors.black);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            Utils.logMessage("AuthManager is being created");
            //Assign NavigatorKey in Build_router
            firebaseAPI.globalNavigatorKey = globalNavigatorKey;
            return AuthManager(firebaseAPI: firebaseAPI);
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, JobseekerManager>(
          create: (context) =>
              JobseekerManager(context.read<AuthManager>().jobseeker),
          update: (context, authManager, jobseekerManager) {
            //When authManager signals change, read authToken again
            //* for JobseekerManager
            jobseekerManager!.authToken = authManager.authToken;
            // jobseekerManager.jobseeker = authManager.jobseeker;
            //Pass socketService to JobseekerManager
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
            //When authManager signals change, read authToken again
            //* for JobseekerManager
            employerManager!.authToken = authManager.authToken;
            Utils.logMessage(
                "---- ChangeNotifierProxyProvider<AuthManager, EmployerManager> ----");
            return employerManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, CompanyManager>(
          create: (context) => CompanyManager(),
          update: (context, authManager, companyManager) {
            //When authManager signals change, read authToken again
            //* for JobseekerManager
            companyManager!.authToken = authManager.authToken;
            Utils.logMessage(
                "---- ChangeNotifierProxyProvider<AuthManager, CompanyManager> ----");
            return companyManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, JobpostingManager>(
          create: (context) => JobpostingManager(),
          update: (context, authManager, jobpostingManager) {
            //When authManager signals change, read authToken again
            //* for JobseekerManager
            jobpostingManager!.authToken = authManager.authToken;
            jobpostingManager.socketService = authManager.socketService;
            return jobpostingManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, ApplicationManager>(
          create: (context) => ApplicationManager(),
          update: (context, authManager, applicationManager) {
            //When authManager signals change, read authToken again
            //* for JobseekerManager
            applicationManager!.authToken = authManager.authToken;
            Utils.logMessage(
                "---- ChangeNotifierProxyProvider<AuthManager, ApplicationManager> ----");
            return applicationManager;
          },
        ),
        //Manager for handling messages
        ChangeNotifierProxyProvider<AuthManager, MessageManager>(
          create: (context) => MessageManager(),
          update: (context, authManager, messageManager) {
            Utils.logMessage('Calling update MessageManager');
            //Reassign authToken when AuthManager changes
            messageManager!.authToken = authManager.authToken;
            //Pass socketService to MessageManager
            messageManager.socketService = authManager.socketService;
            /*
              For functions loading data and listening for new messages,
              if user has logged out, don't call these functions again.
              These functions are only called when user logs into the system
              to initialize message list and listen for new messages
            */
            if (authManager.authToken != null) {
              //Load data for conversations and messages
              messageManager.getAllConversation();
              //Listen for new incoming messages
              messageManager.listenToIncomingMessages();
              //If user is employer, listen for new conversations from jobseekers
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
        // background: Colors.white, //deprecated
        surfaceTint: Colors.grey,
        onSecondary: Colors.black);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AdminAuthManager()),
        ChangeNotifierProxyProvider<AdminAuthManager, JobseekerListManager>(
          create: (context) => JobseekerListManager(),
          update: (context, adminAuthManager, jobseekerListManager) {
            //Update authToken for JobseekerListManager
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
