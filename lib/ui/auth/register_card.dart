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
  final PageController _pageController =
      PageController(); //Controller để quản lý việc chuyển form
  ValueNotifier<UserType> userType = ValueNotifier<UserType>(UserType.employee);
  ValueNotifier<bool> isPasswordShown = ValueNotifier<bool>(false);
  final PageStorageBucket _bucket = PageStorageBucket();

  final addressController = TextEditingController();

  Map<String, String> submitedData = {
    'firstName': '',
    'lastName': '',
    'phone': '',
    'email': '',
    'password': '',
    'address': '',
    'role': '',
    'companyName': '',
    'companyEmail': '',
    'companyPhone': '',
    'companyAddress': '',
    'otp': ''
  };

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    log(submitedData.toString());
    try {} catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      }
    }
  }

  void _updateCurrentPageIndex(int index) {
    _pageController.animateToPage(index,
        duration: const Duration(milliseconds: 400), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    Size currentSceen = MediaQuery.of(context).size;
    TextStyle userTitleStyle =
        TextStyle(fontSize: 25, fontWeight: FontWeight.bold);

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
                      child: ValueListenableBuilder(
                        valueListenable: userType,
                        builder: (context, value, child) {
                          String userString = (value == UserType.employee)
                              ? 'ỨNG VIÊN'
                              : 'NHÀ TUYỂN DỤNG';
                          return Text(userString, style: userTitleStyle);
                        },
                      ),
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
                      child: PageStorage(
                        bucket: _bucket,
                        child: PageView(
                          controller: _pageController,
                          children: [
                            Column(
                              key: PageStorageKey('informationKey'),
                              children: <Widget>[
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Expanded(child: _buildFirstNameField()),
                                    const SizedBox(
                                      width: 5,
                                    ),
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
                                const SizedBox(
                                  height: 10,
                                ),
                                _buildAddressField(),
                                const SizedBox(
                                  height: 10,
                                ),
                                ValueListenableBuilder(
                                  valueListenable: userType,
                                  builder: (context, value, child) {
                                    return value == UserType.employee
                                        ? _buildOTP()
                                        : _buildRoleField();
                                  },
                                )
                              ],
                            ),
                            Column(
                              key: PageStorageKey('companyKey'),
                              children: <Widget>[
                                _buildCompanyNameField(),
                                const SizedBox(
                                  height: 10,
                                ),
                                _buildCompanyEmailField(),
                                const SizedBox(
                                  height: 10,
                                ),
                                _buildCompanyPhoneField(),
                                const SizedBox(
                                  height: 10,
                                ),
                                _buildCompanyAddressField(),
                                const SizedBox(
                                  height: 10,
                                ),
                                _buildOTP(),
                                const SizedBox(
                                  height: 10,
                                ),
                                _buildBackButton()
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                _buildRegisterButton(),
                const SizedBox(
                  height: 10,
                ),
                _buildSwitchUser()
              ],
            )));
  }

  Widget _buildBackButton() {
    return ElevatedButton(
        onPressed: () {
          _updateCurrentPageIndex(0);
        },
        child: const Text(
          'Quay về',
          style: TextStyle(fontSize: 17),
        ));
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
        if (value!.isEmpty || value.length != 10) {
          return 'Số điện thoại không hợp lệ';
        }
        return null;
      },
      onSaved: (value) {},
    );
  }

  Widget _buildAddressField() {
    return TextFormField(
      controller: addressController,
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
      onSaved: (value) {},
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder(
        valueListenable: isPasswordShown,
        builder: (context, value, child) {
          return TextFormField(
            decoration: InputDecoration(
                labelText: 'Mật khẩu',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(!value ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    log('Hiện mật khẩu');
                    isPasswordShown.value = !isPasswordShown.value;
                  },
                )),
            obscureText: !isPasswordShown.value,
            validator: (value) {
              if (value == null || value.length < 8) {
                return 'Mật khẩu ít nhất 8 ký tự';
              }
              return null;
            },
            onSaved: (value) {},
          );
        });
  }

  Widget _buildRegisterButton() {
    return ValueListenableBuilder(
        valueListenable: userType,
        builder: (context, value, child) {
          return ElevatedButton(
            onPressed: () {
              log(_pageController.page?.toInt().toString() ?? '');
              // _login();
              if (value == UserType.employer) {
                _bucket.writeState(context, addressController.value);
                _updateCurrentPageIndex(1);
                log('Chuyển đến form công ty');
              } else {
                log('Thực hiện đăng ký');
                // _register();
              }
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
              (value == UserType.employer && _pageController.page?.toInt() == 0)
                  ? 'TIẾP THEO'
                  : 'ĐĂNG KÝ',
              style: TextStyle(fontSize: 17),
            ),
          );
        });
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        _updateCurrentPageIndex(1);
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
          if (userType.value == UserType.employee) {
            userType.value = UserType.employer;
          } else {
            userType.value = UserType.employee;
            _updateCurrentPageIndex(0);
          }
        },
        style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 4),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            )),
        child: ValueListenableBuilder(
          valueListenable: userType,
          builder: (context, value, child) {
            String switchString = value != UserType.employee
                ? 'Đăng ký ứng tuyển viên'
                : 'Đăng ký nhà tuyển dụng';
            return Text(switchString, style: TextStyle(fontSize: 17));
          },
        ));
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
          const SizedBox(
            width: 5,
          ),
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
            child: const Text('Gửi OTP', style: TextStyle(fontSize: 17)),
          )
        ],
      ),
    );
  }

  //Xây dựng Form nhập thông tin cá nhân dành cho Người tìm việc và nhà tuyển dụng
}
