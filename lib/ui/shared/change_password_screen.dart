import 'dart:developer';

import 'package:date_picker_plus/date_picker_plus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/combined_text_form_field.dart';
import 'package:job_finder_app/ui/shared/modal_bottom_sheet.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

class ChangePasswordScreen extends StatefulWidget {
  ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authenticatePasswordController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  ValueNotifier<bool> isFull = ValueNotifier(false);
  String oldPassword = '';
  String newPassword = '';

  @override
  void initState() {
    _oldPasswordController.addListener(_isValidForm);
    _newPasswordController.addListener(_isValidForm);
    _authenticatePasswordController.addListener(_isValidForm);
    super.initState();
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _oldPasswordController.dispose();
    _authenticatePasswordController.dispose();
    super.dispose();
  }

  void _isValidForm() {
    isFull.value = _oldPasswordController.text.isNotEmpty &&
        _newPasswordController.text.isNotEmpty &&
        _authenticatePasswordController.text.isNotEmpty;
    log('IsFull la: ${isFull.value}');
  }

  Future<void> _changePasswordForJobseeker() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_newPasswordController.text
            .compareTo(_authenticatePasswordController.text) !=
        0) {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Lỗi',
          text: 'Mật khẩu chưa khớp, vui lòng nhập lại',
          confirmBtnText: 'Tôi biết rồi');
    } else {
      try {
        _formKey.currentState!.save();
        log('Oldpassword is: $oldPassword');
        log('Newpassword is: $newPassword');
        final isChanged = await context
            .read<JobseekerManager>()
            .changePassword(oldPassword, newPassword);
        if (isChanged) {
          QuickAlert.show(
              context: context,
              type: QuickAlertType.success,
              title: 'Thành công',
              text: 'Bạn đã đổi mật khẩu thành công');
          clearAllField();
        } else {
          QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Không thể đổi mật khẩu',
            text: 'Mật khẩu chưa chính xác',
            confirmBtnText: 'Tôi biết rồi',
          );
        }
      } catch (error) {
        QuickAlert.show(
          context: context,
          type: QuickAlertType.error,
          title: 'Không thể đổi mật khẩu',
          text: 'Mật khẩu chưa chính xác',
          confirmBtnText: 'Tôi biết rồi',
        );
        log('Lỗi trong chagne email screen ${error}');
      }
    }
  }

  void clearAllField() {
    _authenticatePasswordController.clear();
    _oldPasswordController.clear();
    _newPasswordController.clear();
  }

  Future<void> _changePasswordForEmployer() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_newPasswordController.text
            .compareTo(_authenticatePasswordController.text) !=
        0) {
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Lỗi',
        text: 'Mật khẩu chưa khớp, vui lòng nhập lại',
      );
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
                  oldPassword = value!;
                },
              ),
              const SizedBox(
                height: 10,
              ),
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
                  newPassword = value!;
                },
              ),
              const SizedBox(
                height: 10,
              ),
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
                      valueListenable: isFull,
                      builder: (context, isValid, child) {
                        return ElevatedButton(
                          onPressed: isValid == false
                              ? null
                              : (!isEmployer)
                                  ? _changePasswordForJobseeker
                                  : _changePasswordForEmployer,
                          child: Text("ĐỔI MẬT KHẨU"),
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
