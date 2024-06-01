import 'package:flutter/material.dart';
import 'package:job_finder_app/services/auth_service.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/auth/auth_screen.dart';
import 'package:provider/provider.dart';

import 'ui/shared/build_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: Colors.blueAccent,
      secondary: Colors.grey.shade400,
      surface: Colors.white,
      background: Colors.white,
      surfaceTint: Colors.grey,
      onSecondary: Colors.black
    );



    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => AuthManager(),
        ),
      ],
      child: Consumer<AuthManager>(
        builder: (ctx, authManager, child) {
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
                shadowColor: colorScheme.shadow
              ),
              bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: colorScheme.primary,
                unselectedItemColor: colorScheme.secondary,
                showUnselectedLabels: true
              ),
            ),
            routerConfig: buildRouter(authManager),
          );
        }
      ),
    );
  }
}