import 'dart:developer';

import 'package:blur/blur.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:provider/provider.dart';

import 'register_card.dart';

class RegisterScreen extends StatefulWidget {
  RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  ValueNotifier<bool> isFocus = new ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    Color primaryColor = theme.primaryColor;
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Blur(
              blur: 1.0,
              blurColor: const Color.fromARGB(255, 23, 48, 91),
              child: Container(
                height: deviceSize.height,
                width: deviceSize.width,
                decoration: BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/images/job_background.jpg'),
                  fit: BoxFit.cover,
                )),
              ),
            ),
            Positioned(
              top: 40,
              left: 0,
              right: 0,
              child: Text(
                    'ĐĂNG KÝ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 35,
                      fontFamily: 'Anton',
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
            ),
            
            Container(
              margin: EdgeInsets.only(top: 90),
              child: RegisterCard()
            )
          ],
        ),
      ),
    );
  }
}

