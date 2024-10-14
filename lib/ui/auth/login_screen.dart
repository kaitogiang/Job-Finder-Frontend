import 'dart:developer';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

enum UserType { employee, employer }

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  ValueNotifier<bool> isFocus = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Blur(
            blur: 1.0,
            blurColor: const Color.fromARGB(255, 23, 48, 91),
            child: Container(
              decoration: const BoxDecoration(
                  image: DecorationImage(
                image: AssetImage('assets/images/job_background.jpg'),
                fit: BoxFit.cover,
              )),
            ),
          ),
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'ĐĂNG NHẬP',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontFamily: 'Anton',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                ValueListenableBuilder(
                    valueListenable: isFocus,
                    builder: (context, value, child) {
                      if (!value) {
                        return const SizedBox(
                          height: 200,
                        );
                      } else {
                        return const SizedBox(
                          height: 0,
                        );
                      }
                    }),
                LoginCard(
                  isFocus: isFocus,
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LoginCard extends StatefulWidget {
  const LoginCard({this.isFocus, super.key});

  final ValueNotifier<bool>? isFocus;

  @override
  State<LoginCard> createState() => _LoginCardState();
}

class _LoginCardState extends State<LoginCard> {
  final _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey();
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();
  UserType userType = UserType.employee;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  @override
  void initState() {
    super.initState();
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _passwordController.dispose();
    _emailFocusNode.dispose();
    _scrollController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    if (_emailFocusNode.hasFocus || _passwordFocusNode.hasFocus) {
      widget.isFocus!.value = true;
    } else {
      widget.isFocus!.value = false;
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    try {
      QuickAlert.show(
          context: context,
          type: QuickAlertType.loading,
          text: 'Đang đăng nhập');
      if (userType == UserType.employee) {
        //Đăng nhập cho người tìm việc
        await context
            .read<AuthManager>()
            .login(_authData['email']!, _authData['password']!, false)
            .whenComplete(() {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      } else {
        await context
            .read<AuthManager>()
            .login(_authData['email']!, _authData['password']!, true)
            .whenComplete(() {
          if (mounted) {
            Navigator.pop(context);
          }
        });
      }
    } catch (error) {
      if (mounted) {
        QuickAlert.show(
            context: context,
            type: QuickAlertType.error,
            title: 'Không thể đăng nhập',
            text: error.toString(),
            confirmBtnText: 'Tôi biết rồi');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Size currentSceen = MediaQuery.of(context).size;
    return Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: SizedBox(
            width: currentSceen.width,
            height: currentSceen.height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: IconButton(
                        padding: const EdgeInsets.only(left: 6),
                        icon: const Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          debugPrint('Back to AuthScreen');
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 0),
                      child: Text(
                          userType == UserType.employee
                              ? 'ỨNG VIÊN'
                              : 'NHÀ TUYỂN DỤNG',
                          style: const TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildEmailField(),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildPasswordField(),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildLoginButton(),
                        const SizedBox(
                          height: 10,
                        ),
                        _buildSwitchUser()
                      ],
                    ),
                  ),
                )
              ],
            )));
  }

  Widget _buildEmailField() {
    return TextFormField(
      focusNode: _emailFocusNode,
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
      validator: (value) {
        if (value!.isEmpty || !value.contains('@')) {
          return 'Email không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {
        _authData['email'] = value!;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      focusNode: _passwordFocusNode,
      decoration: const InputDecoration(
        labelText: 'Mật khẩu',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
      ),
      obscureText: true,
      controller: _passwordController,
      validator: (value) {
        if (value == null || value.length < 8) {
          return 'Mật khẩu ít nhất 8 ký tự';
        }
        return null;
      },
      onSaved: (value) {
        _authData['password'] = value!;
      },
    );
  }

  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: () {
        log('Đăng nhập vào + ${userType.toString()}');
        _login();
      },
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          fixedSize: const Size(350, 60)),
      child: const Text(
        'ĐĂNG NHẬP',
        style: TextStyle(fontSize: 17),
      ),
    );
  }

  Widget _buildSwitchUser() {
    return TextButton(
      onPressed: () {
        setState(() {
          if (userType == UserType.employee) {
            userType = UserType.employer;
          } else {
            userType = UserType.employee;
          }
        });
      },
      style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          )),
      child: Text(
        userType != UserType.employee
            ? 'Đăng nhập ứng tuyển viên'
            : 'Đăng nhập nhà tuyển dụng',
        style: const TextStyle(fontSize: 17),
      ),
    );
  }
}
