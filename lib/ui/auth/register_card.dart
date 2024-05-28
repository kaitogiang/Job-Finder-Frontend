import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:provider/provider.dart';

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
  ValueNotifier<int> _currentIndexPage = ValueNotifier<int>(0);
  ValueNotifier<bool> _isSendingOTP = ValueNotifier<bool>(false);
  final PageStorageBucket _bucket = PageStorageBucket();

  final firstNameController = TextEditingController();
  final addressController = TextEditingController();
  final Map<String, TextEditingController> textControllers = {};

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
    // _formKey.currentState!.save();
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
  void initState() {
    for (final key in submitedData.keys) {
      String controllerName = '${key}Controller';
      textControllers[controllerName] = TextEditingController();
    }
    super.initState();
  }

  @override
  void dispose() {
    for (final controller in textControllers.values) {
      controller.dispose();
    }
    super.dispose();
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
            // height: 790,
            constraints: BoxConstraints(minHeight: 600, maxHeight: 790),
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
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    child: Form(
                      key: _formKey,
                      child: PageStorage(
                        bucket: _bucket,
                        child: PageView(
                          controller: _pageController,
                          onPageChanged: (value) {
                            _currentIndexPage.value = value;
                          },
                          children: [
                            _buildInformationForm(),
                            _buildCompanyForm(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                ValueListenableBuilder<UserType>(
                    valueListenable: userType,
                    builder: (context, user, child) {
                      return ValueListenableBuilder<int>(
                        valueListenable: _currentIndexPage,
                        builder: (context, index, child) {
                          return (user == UserType.employee || index == 1)
                              ? _buildRegisterButton()
                              : _buildNextButton();
                        },
                      );
                    }),
                const SizedBox(
                  height: 10,
                ),
                _buildSwitchUser()
              ],
            )));
  }

  Column _buildCompanyForm() {
    return Column(
      key: PageStorageKey('companyKey'),
      children: <Widget>[
        const SizedBox(height: 5),
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
    );
  }

  Column _buildInformationForm() {
    return Column(
      key: PageStorageKey('informationKey'),
      children: <Widget>[
        const SizedBox(height: 5),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
            return value == UserType.employee ? _buildOTP() : _buildRoleField();
          },
        )
      ],
    );
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
      controller: textControllers['firstNameController'],
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
      controller: textControllers['lastNameController'],
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
      controller: textControllers['phoneController'],
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
      controller: textControllers['addressController'],
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
      controller: textControllers['emailController'],
      decoration: const InputDecoration(
        labelText: 'Email',
        prefixIcon: Icon(Icons.email),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.emailAddress,
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
      onSaved: (value) {},
    );
  }

  Widget _buildPasswordField() {
    return ValueListenableBuilder(
        valueListenable: isPasswordShown,
        builder: (context, value, child) {
          return TextFormField(
            controller: textControllers['passwordController'],
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
    return ElevatedButton(
      onPressed: () {
        log('Thực hiện đăng ký');
        // _register();
        _formKey.currentState!.validate();
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
        'ĐĂNG KÝ',
        style: TextStyle(fontSize: 17),
      ),
    );
  }

  Widget _buildNextButton() {
    return ElevatedButton(
      onPressed: () {
        _updateCurrentPageIndex(1);
        _bucket.writeState(context, addressController.value);
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
      controller: textControllers['companyNameController'],
      decoration: const InputDecoration(
        labelText: 'Company name',
        prefixIcon: Icon(Icons.business),
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
      controller: textControllers['roleController'],
      decoration: const InputDecoration(
        labelText: 'Role',
        prefixIcon: Icon(Icons.person_2_outlined),
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
      controller: textControllers['companyEmailController'],
      decoration: const InputDecoration(
        labelText: 'Company email',
        prefixIcon: Icon(Icons.email_outlined),
        border: OutlineInputBorder(),
      ),
      keyboardType: TextInputType.text,
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
      onSaved: (value) {},
    );
  }

  Widget _buildCompanyPhoneField() {
    return TextFormField(
      controller: textControllers['companyPhoneConroller'],
      decoration: const InputDecoration(
        labelText: 'Company phone',
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

  Widget _buildCompanyAddressField() {
    return TextFormField(
      controller: textControllers['companyAddressController'],
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
      height: 90,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: TextFormField(
              controller: textControllers['otpController'],
            
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
          Padding(
            padding: const EdgeInsets.only(top: 3),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                fixedSize: Size.fromHeight(55),
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                log('Gửi OTP');
                //Kiểm tra email trước khi gửi OTP
                // Define a regular expression pattern for validating email addresses
                String email = textControllers['emailController']!.text;
                // Define a regular expression pattern for validating email addresses
                final RegExp emailRegex = RegExp(
                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                );
            
                // Check if the email matches the pattern
                if (email.isEmpty || !emailRegex.hasMatch(email)) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Email không hợp lệ'),
                    duration: const Duration(seconds: 3),
                  ));
                  return;
                }
                _isSendingOTP.value = true;
                bool isEmployer =
                    userType.value == UserType.employer ? true : false;
                context
                    .read<AuthManager>()
                    .sendOTP(
                        email: textControllers['emailController']!.text,
                        isEmployer: isEmployer)
                    .then((value) {
                      _isSendingOTP.value = false;
                  return ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Gửi OTP thành công'),
                    duration: const Duration(seconds: 3),
                  ));
                });
              },
              child: ValueListenableBuilder<bool>(
                  valueListenable: _isSendingOTP,
                  builder: (context, value, child) {
                    return !value
                        ? const Text('Gửi OTP', style: TextStyle(fontSize: 17))
                        : const CircularProgressIndicator(color: Colors.white,);
                  }),
            ),
          )
        ],
      ),
    );
  }

  //Xây dựng Form nhập thông tin cá nhân dành cho Người tìm việc và nhà tuyển dụng
}
