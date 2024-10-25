import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/manager/admin_auth_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/widgets/rectangle_action_button.dart';
import 'package:provider/provider.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:toastification/toastification.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ValueNotifier<bool> _isContinueClicked = ValueNotifier(false);
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  //Hàm gửi mã OTP đi
  Future<void> sendOTP() async {
    String email = _emailController.text;
    if (email.isEmpty) {
      Utils.showNotification(
        context: context,
        title: 'Vui lòng nhập email',
        type: ToastificationType.error,
      );
      return;
    }

    final isSentOtp = await context.read<AdminAuthManager>().sendOTP(email);
    if (isSentOtp && mounted) {
      Utils.showNotification(
        context: context,
        title: 'Đã gửi mã xác nhận, vui lòng kiểm tra email',
        type: ToastificationType.success,
      );
      _isContinueClicked.value = true;
    } else {
      if (mounted) {
        Utils.showNotification(
          context: context,
          title: 'Gửi mã xác nhận thất bại',
          type: ToastificationType.error,
        );
      }
    }
  }

  //Hàm khôi phục mật khẩu
  Future<void> resetPassword() async {
    final email = _emailController.text;
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;
    final otp = _otpController.text;
    if (email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        otp.isEmpty) {
      Utils.showNotification(
        context: context,
        title: 'Vui lòng nhập đẩy đủ thông tin',
        type: ToastificationType.error,
      );
    }

    if (password != confirmPassword) {
      Utils.showNotification(
        context: context,
        title: 'Mật khẩu không khớp',
        type: ToastificationType.error,
      );
    }
    final isResetPassword = await context
        .read<AdminAuthManager>()
        .resetPassword(email, password, otp);
    if (isResetPassword && mounted) {
      Utils.showNotification(
        context: context,
        title: 'Khôi phục mật khẩu thành công',
        type: ToastificationType.success,
      );
      GoRouter.of(context).go('/login');
    } else {
      if (mounted) {
        Utils.showNotification(
          context: context,
          title: 'Khôi phục mật khẩu thất bại',
          type: ToastificationType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme;
    final deviceType = getDeviceType(MediaQuery.of(context).size);
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
                      const SizedBox(width: 10.0),
                      ValueListenableBuilder(
                        valueListenable: _isContinueClicked,
                        builder: (context, isContinueClicked, child) {
                          return !isContinueClicked
                              ? Image.asset(
                                  'assets/images/modern_logo.png',
                                  height: 100,
                                )
                              : Row(children: [
                                  IconButton(
                                    onPressed: () {
                                      _isContinueClicked.value = false;
                                    },
                                    icon: Icon(Icons.arrow_back),
                                  ),
                                  const SizedBox(width: 90.0),
                                  Image.asset(
                                    'assets/images/modern_logo.png',
                                    height: 100,
                                  )
                                ]);
                        },
                      ),
                      Text(
                        'Khôi phục mật khẩu',
                        style: textStyle.titleLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Vui lòng nhập email để khôi phục mật khẩu',
                        style: textStyle.titleMedium,
                      ),
                      SizedBox(height: 20.0),
                      ValueListenableBuilder(
                        valueListenable: _isContinueClicked,
                        builder: (context, isContinueClicked, child) {
                          return !isContinueClicked
                              ? Column(
                                  children: [
                                    TextFormField(
                                      controller: _emailController,
                                      decoration: InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 150.0),
                                  ],
                                )
                              : SizedBox.shrink();
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _isContinueClicked,
                        builder: (context, isContinueClicked, child) {
                          return isContinueClicked
                              ? Column(
                                  children: [
                                    TextFormField(
                                      controller: _otpController,
                                      decoration: InputDecoration(
                                        labelText: 'Mã xác nhận',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    TextFormField(
                                      controller: _passwordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Mật khẩu mới',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                    TextFormField(
                                      controller: _confirmPasswordController,
                                      obscureText: true,
                                      decoration: InputDecoration(
                                        labelText: 'Xác nhận mật khẩu mới',
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                    SizedBox(height: 20.0),
                                  ],
                                )
                              : SizedBox.shrink();
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable: _isContinueClicked,
                        builder: (context, isContinueClicked, child) {
                          return !isContinueClicked
                              ? RectangleActionButton(
                                  title: 'Tiếp tục',
                                  onPressed: sendOTP,
                                )
                              : RectangleActionButton(
                                  title: 'Khôi phục mật khẩu',
                                  onPressed: resetPassword,
                                );
                        },
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
