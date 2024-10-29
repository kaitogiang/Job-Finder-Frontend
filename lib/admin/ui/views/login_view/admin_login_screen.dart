import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/manager/admin_auth_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:toastification/toastification.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    try {
      final email = _emailController.text;
      final password = _passwordController.text;
      Utils.logMessage('email: $email, password: $password');
      if (email.isEmpty || password.isEmpty) {
        Utils.showNotification(
          context: context,
          title: 'Vui lòng nhập đẩy đủ thông tin',
          type: ToastificationType.error,
        );
        return;
      }
      if (mounted) {
        await context.read<AdminAuthManager>().login(email, password);
        Utils.showNotification(
          context: context,
          title: 'Đăng nhập thành công',
          type: ToastificationType.success,
        );
      }
    } catch (error) {
      Utils.logMessage(error.toString());
      if (context.mounted) {
        Utils.showNotification(
          context: context,
          title: 'Đăng nhập thất bại',
          type: ToastificationType.error,
        );
      }
    }
  }

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
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 20.0),
                      TextFormField(
                        controller: _passwordController,
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
                        onPressed: _login,
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
