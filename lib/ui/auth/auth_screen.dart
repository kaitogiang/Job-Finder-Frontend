
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:blur/blur.dart';
import 'package:job_finder_app/ui/auth/register_screen.dart';
import 'login_screen.dart';

class AuthScreen extends StatelessWidget {

  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color primaryColor = theme.primaryColor;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Blur(
            blur: 1.0,
            blurColor: const Color.fromARGB(255, 23, 48, 91),
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/job_background.jpg'),
                  fit: BoxFit.cover,
                )
              ),
            ),
          ),
          Positioned(
            top: 100,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'CHÀO MỪNG',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontFamily: 'Anton',
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: const Text(
                    'Hãy đăng nhập vào tìm kiếm việc làm và tuyển dụng',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontFamily: 'Anton',
                      fontWeight: FontWeight.normal,
                    ),
                    softWrap: true,
                    textAlign: TextAlign.center,
                  ),
                )
              ],
            ),
          ),
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,              
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(300, 50),
                    backgroundColor: primaryColor,
                  ),
                  
                  onPressed: () {
                    print('Đăng nhập');
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                    );
                  },
                  child: Text('Đăng nhập', style: TextStyle(fontSize: 20, color: Colors.white),),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(300, 50),
                  ),
                  onPressed: () {
                    print('Đăng ký');
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => RegisterScreen()),
                    );
                  },
                  child: Text('Đăng ký', style: TextStyle(fontSize: 20, color: primaryColor),),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}