import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/base_layout_page.dart';
import 'package:responsive_builder/responsive_builder.dart';

class AdminLoginScreen extends StatelessWidget {
  const AdminLoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = Theme.of(context).textTheme;
    var deviceType = getDeviceType(MediaQuery.of(context).size);
    double loginWidth = deviceType == DeviceScreenType.desktop
        ? 400
        : deviceType == DeviceScreenType.tablet
            ? 400
            : 300;
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/admin_background.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              constraints: BoxConstraints(maxWidth: loginWidth),
              height: 470,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10.0,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/images/modern_logo.png',
                        height: 100,
                      ),
                      Text(
                        'Job Finder Admin',
                        style: textStyle.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vui lòng nhập thông tin đăng nhập',
                        style: textStyle.titleMedium,
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {
                              GoRouter.of(context).go('/reset-password');
                            },
                            child: Text('Quên mật khẩu?'),
                          ),
                        ],
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          // Handle login logic here
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          minimumSize:
                              Size(double.infinity, 50), // Full-width button
                          backgroundColor: theme.colorScheme.primary,
                        ),
                        child: Text(
                          'Đăng nhập',
                          style: textStyle.titleMedium!.copyWith(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[200],
    );
  }
}
