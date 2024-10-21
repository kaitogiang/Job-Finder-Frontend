import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/employer/employer_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authenticateEmailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailController = TextEditingController();

  ValueNotifier<bool> isFull = ValueNotifier(false);
  String password = '';
  String email = '';

  @override
  void initState() {
    _passwordController.addListener(_isValidForm);
    _emailController.addListener(_isValidForm);
    _authenticateEmailController.addListener(_isValidForm);
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authenticateEmailController.dispose();
    super.dispose();
  }

  void _isValidForm() {
    isFull.value = _passwordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _authenticateEmailController.text.isNotEmpty;
    log('IsFull la: ${isFull.value}');
  }

  Future<void> _changeEmailForJobseeker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_emailController.text.compareTo(_authenticateEmailController.text) !=
        0) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Lỗi',
          text: 'Email chưa khớp, vui lòng nhập lại',
          confirmBtnText: 'Tôi biết rồi');
    } else {
      try {
        _formKey.currentState!.save();

        final result = await context
            .read<JobseekerManager>()
            .changeEmail(password, email)
            .whenComplete(() {
          // QuickAlert.show(
          //     context: context,
          //     type: QuickAlertType.success,
          //     title: 'Thành công',
          //     text: 'Bạn đã đổi email thành công');
          clearAllField();
        });
        if (result && mounted) {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Thành công',
              text: 'Bạn đã đổi email thành công');
        } else {
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Không thể đổi email',
              text: 'Email hoặc mật khẩu chưa chính xác',
            );
          }
        }
      } catch (error) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Không thể đổi email',
            text: 'Email hoặc mật khẩu chưa chính xác',
          );
        }
        log('Lỗi trong chagne email screen $error');
      }
    }
  }

  void clearAllField() {
    _authenticateEmailController.clear();
    _passwordController.clear();
    _emailController.clear();
  }

  Future<void> _changeEmailForEmployer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_emailController.text.compareTo(_authenticateEmailController.text) !=
        0) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Lỗi',
          text: 'Email chưa khớp, vui lòng nhập lại',
          confirmBtnText: 'Tôi biết rồi');
    } else {
      try {
        _formKey.currentState!.save();

        final result = await context
            .read<EmployerManager>()
            .changeEmail(password, email)
            .whenComplete(() {
          clearAllField();
        });
        if (result && mounted) {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Thành công',
              text: 'Bạn đã đổi email thành công');
        } else {
          if (mounted) {
            QuickAlert.show(
              context: context,
              type: QuickAlertType.error,
              title: 'Không thể đổi email',
              text: 'Email hoặc mật khẩu chưa chính xác',
            );
          }
        }
      } catch (error) {
        if (mounted) {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Không thể đổi email',
            text: 'Email hoặc mật khẩu chưa chính xác',
          );
        }
        log('Lỗi trong chagne email screen $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    bool isEmployer = context.read<AuthManager>().isEmployer;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi email truy cập'),
      ),
      body: Form(
        key: _formKey,
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              CombinedTextFormField(
                title: 'Mật khẩu hiện tại',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                isPassword: true,
                controller: _passwordController,
                validator: (value) {
                  if (value!.length < 8) {
                    return 'Mật khẩu ít nhất 8 ký tự';
                  }
                  return null;
                },
                onSaved: (value) {
                  password = value!;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              CombinedTextFormField(
                title: 'Email mới',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _emailController,
                validator: (value) {
                  // Define a regular expression pattern for validating email addresses
                  final RegExp emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );

                  // Check if the email matches the pattern
                  if (value!.isEmpty || !emailRegex.hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
                onSaved: (value) {
                  email = value!;
                },
              ),
              const SizedBox(
                height: 10,
              ),
              CombinedTextFormField(
                title: 'Xác nhận email mới',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _authenticateEmailController,
                validator: (value) {
                  // Define a regular expression pattern for validating email addresses
                  final RegExp emailRegex = RegExp(
                    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                  );

                  // Check if the email matches the pattern
                  if (value!.isEmpty || !emailRegex.hasMatch(value)) {
                    return 'Email không hợp lệ';
                  }
                  return null;
                },
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder(
                      valueListenable: isFull,
                      builder: (context, isValid, child) {
                        return ElevatedButton(
                          onPressed: isValid == false
                              ? null
                              : (!isEmployer)
                                  ? _changeEmailForJobseeker
                                  : _changeEmailForEmployer,
                          style: ElevatedButton.styleFrom(
                              disabledBackgroundColor: Colors.grey.shade300,
                              fixedSize: Size(deviceSize.width, 60),
                              backgroundColor: theme.primaryColor,
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              foregroundColor: theme.colorScheme.onPrimary,
                              textStyle: textTheme.titleMedium),
                          child: Text("ĐỔI EMAIL"),
                        );
                      }),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
