import 'package:blur/blur.dart';
import 'package:flutter/material.dart';

import 'register_card.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  ValueNotifier<bool> isFocus = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
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
                decoration: const BoxDecoration(
                    image: DecorationImage(
                  image: AssetImage('assets/images/job_background.jpg'),
                  fit: BoxFit.cover,
                )),
              ),
            ),
            const Positioned(
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
                margin: const EdgeInsets.only(top: 90), child: RegisterCard())
          ],
        ),
      ),
    );
  }
}
