import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/employer/employer_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authenticatePasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _isFull = ValueNotifier(false);

  String _oldPassword = '';
  String _newPassword = '';

  @override
  void initState() {
    super.initState();
    _setupControllerListeners();
  }

  void _setupControllerListeners() {
    void listener() => _validateForm();
    _oldPasswordController.addListener(listener);
    _newPasswordController.addListener(listener);
    _authenticatePasswordController.addListener(listener);
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _oldPasswordController.dispose();
    _authenticatePasswordController.dispose();
    super.dispose();
  }

  void _validateForm() {
    _isFull.value = _oldPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _authenticatePasswordController.text.isNotEmpty;
  }

  void _clearAllFields() {
    _authenticatePasswordController.clear();
    _oldPasswordController.clear();
    _newPasswordController.clear();
  }

  Future<void> _changePasswordForJobseeker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _authenticatePasswordController.text) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: 'Mật khẩu chưa khớp, vui lòng nhập lại',
        confirmBtnText: 'Tôi biết rồi',
      );
      return;
    }

    try {
      _formKey.currentState!.save();
      log('Oldpassword is: $_oldPassword');
      log('Newpassword is: $_newPassword');
      
      final isChanged = await context
          .read<JobseekerManager>()
          .changePassword(_oldPassword, _newPassword);
          
      if (isChanged && mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Bạn đã đổi mật khẩu thành công',
        );
        _clearAllFields();
      } else if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Không thể đổi mật khẩu',
          text: 'Mật khẩu chưa chính xác',
          confirmBtnText: 'Tôi biết rồi',
        );
      }
    } catch (error) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Không thể đổi mật khẩu',
          text: 'Mật khẩu chưa chính xác',
          confirmBtnText: 'Tôi biết rồi',
        );
      }
      log('Lỗi trong change password screen: $error');
    }
  }

  Future<void> _changePasswordForEmployer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_newPasswordController.text != _authenticatePasswordController.text) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: 'Mật khẩu chưa khớp, vui lòng nhập lại',
        confirmBtnText: 'Tôi biết rồi',
      );
      return;
    }

    try {
      _formKey.currentState!.save();
      log('Oldpassword is: $_oldPassword');
      log('Newpassword is: $_newPassword');
      
      final isChanged = await context
          .read<EmployerManager>()
          .changePassword(_oldPassword, _newPassword);
          
      if (isChanged && mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.success,
          title: 'Thành công',
          text: 'Bạn đã đổi mật khẩu thành công',
        );
        _clearAllFields();
      } else if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Không thể đổi mật khẩu',
          text: 'Mật khẩu chưa chính xác',
          confirmBtnText: 'Tôi biết rồi',
        );
      }
    } catch (error) {
      if (mounted) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Không thể đổi mật khẩu',
          text: 'Mật khẩu chưa chính xác',
          confirmBtnText: 'Tôi biết rồi',
        );
      }
      log('Lỗi trong change password screen: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isEmployer = context.read<AuthManager>().isEmployer;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đổi mật khẩu'),
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
                controller: _oldPasswordController,
                validator: (value) {
                  if (value!.length < 8) {
                    return 'Mật khẩu ít nhất 8 ký tự';
                  }
                  return null;
                },
                onSaved: (value) {
                  _oldPassword = value!;
                },
              ),
              const SizedBox(height: 10),
              CombinedTextFormField(
                title: 'Mật khẩu mới',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _newPasswordController,
                isPassword: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 8) {
                    return 'Mật khẩu không hợp lệ';
                  }
                  return null;
                },
                onSaved: (value) {
                  _newPassword = value!;
                },
              ),
              const SizedBox(height: 10),
              CombinedTextFormField(
                title: 'Xác nhận mật khẩu mới',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _authenticatePasswordController,
                isPassword: true,
                validator: (value) {
                  if (value!.isEmpty || value.length < 8) {
                    return 'Mật khẩu chưa hợp lệ';
                  }
                  return null;
                },
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder(
                    valueListenable: _isFull,
                    builder: (context, isValid, child) {
                      return ElevatedButton(
                        onPressed: isValid
                            ? (isEmployer
                                ? _changePasswordForEmployer
                                : _changePasswordForJobseeker)
                            : null,
                        style: ElevatedButton.styleFrom(
                          disabledBackgroundColor: Colors.grey.shade300,
                          fixedSize: Size(deviceSize.width, 60),
                          backgroundColor: theme.primaryColor,
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          foregroundColor: theme.colorScheme.onPrimary,
                          textStyle: textTheme.titleMedium,
                        ),
                        child: const Text("ĐỔI MẬT KHẨU"),
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
