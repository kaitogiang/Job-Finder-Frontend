import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'auth_manager.dart';

enum UserType { employee, employer }

class RegisterCard extends StatefulWidget {
  RegisterCard({super.key});

  @override
  State<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  final GlobalKey<FormState> _formKey = GlobalKey();
  final PageController _pageController = PageController(); //Controller để quản lý việc chuyển form
  UserType userType = UserType.employee;
  final Map<String, String> _authData = {
    'email': '',
    'password': '',
  };

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    try {
      if (userType == UserType.employee) {
        //Đăng nhập cho người tìm việc
        await context
            .read<AuthManager>()
            .login(_authData['email']!, _authData['password']!, false);
      } else {
        await context
            .read<AuthManager>()
            .login(_authData['email']!, _authData['password']!, true);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      }
    }
  }

  void _updateCurrentPageIndex(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut
    );
  }

  @override
  Widget build(BuildContext context) {
    Size currentSceen = MediaQuery.of(context).size;

    return Card(
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50),
        ),
        child: Container(
            width: currentSceen.width,
            height: 680,
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
                        padding: EdgeInsets.only(left: 6),
                        icon: Icon(Icons.arrow_back_ios),
                        onPressed: () {
                          print('Back to AuthScreen');
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
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(child: _buildFirstNameField()),
                              const SizedBox(width: 5,),
                              Expanded(child: _buildLastNameField()),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildPhoneField(),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildEmailField(),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildPasswordField(),
                          const SizedBox(height: 10,),
                          _buildAddressField(),
                          const SizedBox(
                            height: 10,
                          ),
                          _buildOTP()
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildLoginButton(),
                const SizedBox(
                  height: 10,
                ),
                _buildSwitchUser()
              ],
            )));
  }

  Widget _buildFirstNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'First name',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Tên không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  Widget _buildLastNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Last name',
        prefixIcon: Icon(Icons.person),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return 'họ không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  Widget _buildPhoneField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Phone',
        prefixIcon: Icon(Icons.phone),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value!.isEmpty || value!.length != 10) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Address',
        prefixIcon: Icon(Icons.place),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Địa chỉ không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  Widget _buildEmailField() {
    return TextFormField(
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
      decoration: const InputDecoration(
        labelText: 'Mật khẩu',
        border: OutlineInputBorder(),
        prefixIcon: Icon(Icons.lock),
        
      ),
      obscureText: true,
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
        log('Đăng nhập vào' + userType.toString());
        // _login();
      },
      style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
          fixedSize: Size(350, 60)),
      child: Text(
        'TIẾP THEO',
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
        style: TextStyle(fontSize: 17),
      ),
    );
  }

  Widget _buildCompanyNameField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Company name',
        prefixIcon: Icon(Icons.place),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Tên công ty không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  Widget _buildRoleField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Role',
        prefixIcon: Icon(Icons.place),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Vai trò không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }
  
  Widget _buildCompanyEmailField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Company email',
        prefixIcon: Icon(Icons.place),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Email không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }
  
  Widget _buildCompanyPhoneField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Company phone',
        prefixIcon: Icon(Icons.place),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }
  
  Widget _buildCompanyAddressField() {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: 'Company address',
        prefixIcon: Icon(Icons.place),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return 'Địa chỉ không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  Widget _buildOTP() {
    return SizedBox(
      height: 60,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: TextFormField(
              decoration: const InputDecoration(
                labelText: 'OTP',
                prefixIcon: Icon(Icons.lock_clock),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.text,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Địa chỉ không hợp lệ';
                }
                return null;
              },
              onSaved: (value) {},
            ),
          ),
          const SizedBox(width: 5,),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () {
              log('Gửi OTP');
            },
            child: const Text('Gửi OTP', style:TextStyle(fontSize: 17)),
          )
        ],
      ),
    );
  }



}
