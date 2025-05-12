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
  final _isFull = ValueNotifier(false);

  String _password = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _setupControllerListeners();
  }

  void _setupControllerListeners() {
    void listener() => _validateForm();
    _passwordController.addListener(listener);
    _emailController.addListener(listener);
    _authenticateEmailController.addListener(listener);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authenticateEmailController.dispose();
    super.dispose();
  }

  void _validateForm() {
    _isFull.value = _passwordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _authenticateEmailController.text.isNotEmpty;
  }

  void _clearAllFields() {
    _authenticateEmailController.clear();
    _passwordController.clear();
    _emailController.clear();
  }

  bool _validateEmails() {
    if (_emailController.text != _authenticateEmailController.text) {
      _showErrorAlert('Email chưa khớp, vui lòng nhập lại');
      return false;
    }
    return true;
  }

  void _showErrorAlert(String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Lỗi',
      text: message,
      confirmBtnText: 'Tôi biết rồi',
    );
  }

  void _showSuccessAlert() {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Thành công',
      text: 'Bạn đã đổi email thành công',
    );
  }

  Future<void> _handleChangeEmail(Future<bool> Function(String, String) changeEmail) async {
    if (!_formKey.currentState!.validate() || !_validateEmails()) {
      return;
    }

    try {
      _formKey.currentState!.save();
      final result = await changeEmail(_password, _email);
      _clearAllFields();

      if (result && mounted) {
        _showSuccessAlert();
      } else if (mounted) {
        _showErrorAlert('Email hoặc mật khẩu chưa chính xác');
      }
    } catch (error) {
      if (mounted) {
        _showErrorAlert('Email hoặc mật khẩu chưa chính xác');
      }
      log('Lỗi trong change email screen: $error');
    }
  }

  Future<void> _changeEmailForJobseeker() async {
    await _handleChangeEmail(
      context.read<JobseekerManager>().changeEmail,
    );
  }

  Future<void> _changeEmailForEmployer() async {
    await _handleChangeEmail(
      context.read<EmployerManager>().changeEmail,
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final isEmployer = context.read<AuthManager>().isEmployer;

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
                  _password = value!;
                },
              ),
              const SizedBox(height: 10),
              CombinedTextFormField(
                title: 'Email mới',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _emailController,
                validator: _validateEmail,
                onSaved: (value) {
                  _email = value!;
                },
              ),
              const SizedBox(height: 10),
              CombinedTextFormField(
                title: 'Xác nhận email mới',
                hintText: 'Bắt buộc',
                keyboardType: TextInputType.text,
                controller: _authenticateEmailController,
                validator: _validateEmail,
              ),
              Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ValueListenableBuilder(
                    valueListenable: _isFull,
                    builder: (context, isValid, child) {
                      return ElevatedButton(
                        onPressed: isValid
                            ? (isEmployer ? _changeEmailForEmployer : _changeEmailForJobseeker)
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
                        child: const Text("ĐỔI EMAIL"),
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

  String? _validateEmail(String? value) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );

    if (value!.isEmpty || !emailRegex.hasMatch(value)) {
      return 'Email không hợp lệ';
    }
    return null;
  }
}
