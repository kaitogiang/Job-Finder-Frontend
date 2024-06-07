import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_info_card.dart';

import 'user_info_card.dart';

class UserSettingScreen extends StatelessWidget {
  const UserSettingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Cài đặt',
          style: textTheme.headlineMedium!.copyWith(
            color: theme.indicatorColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: <Widget>[
            UserInfoCard(
              title: 'Tài khoản',
              children: [
                ListTile(
                  leading: Icon(Icons.email),
                  title: Text('Đổi email truy cập'),
                  trailing: Icon(Icons.keyboard_arrow_right_outlined),
                  onTap: () {
                    log('Chuyến hướng tới đổi email');
                    context.goNamed('change-email');
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock),
                  title: Text('Đổi mật khẩu'),
                  trailing: Icon(Icons.keyboard_arrow_right_outlined),
                  onTap: () {
                    log('Chuyển hướng tới đổi mật khẩu');
                    context.goNamed('change-password');
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
