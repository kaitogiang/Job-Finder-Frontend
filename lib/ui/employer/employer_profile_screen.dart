import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/employer/employer_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/loading_screen.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';
import '../../models/education.dart';
import '../../models/experience.dart';
import '../../models/resume.dart';
import '../shared/modal_bottom_sheet.dart';
import '../shared/user_info_card.dart';

class EmployerProfileScreen extends StatelessWidget {
  const EmployerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = Theme.of(context).textTheme;
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
        appBar: AppBar(
          title: Text(
            "Hồ sơ của tôi",
            style: textTheme.headlineMedium!.copyWith(
              color: theme.indicatorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(
                  Icons.settings,
                  color: theme.indicatorColor,
                ),
                onPressed: () {
                  log('Vào cài đặt');
                  context.pushNamed('jobseeker-setting');
                })
          ],
        ),
        body: FutureBuilder(
            future: context.read<EmployerManager>().fetchEmployerInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<EmployerManager>().fetchEmployerInfo(),
                child: Consumer<EmployerManager>(
                    builder: (context, employerManager, child) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Khung chứa ảnh đại diện và thông tin cơ bản ngắn gọn
                        Container(
                          height: 200,
                          padding: EdgeInsets.only(bottom: 13),
                          decoration: BoxDecoration(
                            color: theme.primaryColor,
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            //Một dòng để chứa ảnh đại diện và các thông tin cơ bản
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                //Hiển thị ảnh đại diện trong Container
                                Container(
                                  width: 130,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.shade600,
                                        spreadRadius: 1,
                                        blurRadius: 5,
                                        offset: const Offset(0, 3),
                                      )
                                    ],
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                      image: NetworkImage(employerManager
                                          .employer
                                          .getImageUrl()),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  width: 15,
                                ),
                                //Hiển thị các thông tin cơ bản bên trong
                                Expanded(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //Họ và Tên hiển thị ở đây
                                      Text(
                                        '${employerManager.employer.firstName} ${employerManager.employer.lastName}',
                                        style: textTheme.titleLarge!.copyWith(
                                            color: theme.indicatorColor,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Lato',
                                            fontSize: 25),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      //Thông tin địa chỉ email
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Icon(
                                            Icons.email,
                                            color: theme.colorScheme.secondary,
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          Expanded(
                                            child: Text(
                                              employerManager.employer.email,
                                              style: textTheme.titleMedium!
                                                  .copyWith(
                                                color:
                                                    theme.colorScheme.secondary,
                                              ),
                                              softWrap: true,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      //Thông tin số điện thoại
                                      RichText(
                                        text: TextSpan(children: [
                                          WidgetSpan(
                                            child: Icon(
                                              Icons.phone,
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                          ),
                                          const WidgetSpan(
                                              child: const SizedBox(
                                            width: 10,
                                          )),
                                          TextSpan(
                                              text: employerManager
                                                  .employer.phone,
                                              style: textTheme.titleMedium!
                                                  .copyWith(
                                                color:
                                                    theme.colorScheme.secondary,
                                              ))
                                        ]),
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Card hiển thị chi tiết thông tin cá nhân
                        UserInfoCard(
                          title: 'Thông tin cá nhân',
                          iconButton: IconButton(
                            onPressed: () {
                              log('Chỉnh sửa thông tin cá nhân');
                              // EmployerManager.modifyFirstName('Thị Nó');
                              context.pushNamed('employer-edit',
                                  extra: employerManager.employer);
                            },
                            icon: Icon(
                              Icons.edit,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          children: [
                            //Hiển thông tin họ và tên
                            _buildInfoRow(
                                title1: 'Họ',
                                value1: employerManager.employer.lastName,
                                title2: 'Tên',
                                value2: employerManager.employer.firstName,
                                textTheme: textTheme,
                                theme: theme),
                            _buildInfoRow(
                                title1: 'Số điện thoại',
                                value1: employerManager.employer.phone,
                                title2: 'Địa chỉ',
                                value2: employerManager.employer.address,
                                textTheme: textTheme,
                                theme: theme),
                            _buildInfoRow(
                                title1: 'Chức vụ',
                                value1: employerManager.employer.role,
                                textTheme: textTheme,
                                theme: theme),
                            _buildInfoRow(
                                title1: 'Email',
                                value1: employerManager.employer.email,
                                textTheme: textTheme,
                                theme: theme),
                          ],
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //Hiển thị nút đăng xuất ở cuối cùng
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 3,
                              fixedSize: Size(deviceSize.width, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              backgroundColor: Colors.grey.shade300,
                            ),
                            onPressed: () {
                              log('Đăng xuất');
                              context.read<AuthManager>().logout();
                            },
                            child: Text(
                              'Đăng xuất',
                              style: theme.textTheme.titleMedium!.copyWith(
                                fontSize: 18,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  );
                }),
              );
            }));
  }

  Container _buildActionButton({
    required BuildContext context,
    void Function()? onDelete,
    void Function()? onEdit,
  }) {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(
              'Xóa bỏ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            leading: Icon(Icons.delete),
            onTap: onDelete,
          ),
          Divider(),
          ListTile(
            title: Text(
              'Chỉnh sửa',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            leading: Icon(Icons.preview),
            onTap: onEdit,
          ),
        ],
      ),
    );
  }

  Row _buildInfoRow(
      {required String title1,
      required String value1,
      String? title2,
      String? value2,
      required TextTheme textTheme,
      required ThemeData theme}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title1,
                style: textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.secondary,
                    fontFamily: 'Lato',
                    fontSize: 20,
                    fontWeight: FontWeight.normal),
              ),
              Text(
                value1,
                style: textTheme.titleMedium!.copyWith(
                    color: theme.colorScheme.onSecondary,
                    fontFamily: 'Lato',
                    fontSize: 20,
                    fontWeight: FontWeight.normal),
              )
            ],
          ),
        ),
        if (title2 != null)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title2,
                  style: textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.secondary,
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
                ),
                Text(
                  value2!,
                  style: textTheme.titleMedium!.copyWith(
                      color: theme.colorScheme.onSecondary,
                      fontFamily: 'Lato',
                      fontSize: 20,
                      fontWeight: FontWeight.normal),
                )
              ],
            ),
          ),
      ],
    );
  }
}
