import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/employer/company_manager.dart';
import 'package:job_finder_app/ui/employer/employer_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:provider/provider.dart';

import 'ui/shared/build_router.dart';

Future<void> main() async {
  //load the .env file
  await dotenv.load(); //TODO: PHải định nghĩa file .env trong pubspec.yaml
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

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
          create: (context) => AuthManager(),
        ),
        ChangeNotifierProxyProvider<AuthManager, JobseekerManager>(
          create: (context) =>
              JobseekerManager(context.read<AuthManager>().jobseeker),
          update: (context, authManager, jobseekerManager) {
            //TODO Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            jobseekerManager!.authToken = authManager.authToken;
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
            return employerManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, CompanyManager>(
          create: (context) => CompanyManager(),
          update: (context, authManager, companyManager) {
            //TODO Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            companyManager!.authToken = authManager.authToken;
            return companyManager;
          },
        ),
        ChangeNotifierProxyProvider<AuthManager, JobpostingManager>(
          create: (context) => JobpostingManager(),
          update: (context, authManager, jobpostingManager) {
            //TODO Khi authManager có báo hiệu thay đổi thì đọc lại authToken
            //* cho JobseekerManager
            jobpostingManager!.authToken = authManager.authToken;
            return jobpostingManager;
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
