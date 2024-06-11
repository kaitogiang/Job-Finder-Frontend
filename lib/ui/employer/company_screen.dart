import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/employer/company_manager.dart';
import 'package:job_finder_app/ui/shared/loading_screen.dart';
import 'package:provider/provider.dart';

import '../shared/image_container.dart';
import 'widgets/basic_info_card.dart';

class CompanyScreen extends StatelessWidget {
  const CompanyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    List<String> urlList = [
      'https://dplusvn.com/wp-content/uploads/2020/02/hinh-anh-van-phong-cong-ty-rigup-2.jpg',
      'https://dplusvn.com/wp-content/uploads/2020/02/hinh-anh-van-phong-cong-ty-carbonleo-2.jpg',
      'https://dplusvn.com/wp-content/uploads/2020/02/hinh-anh-van-phong-cong-ty-zola-2.jpg',
      'https://homehome.vn/wp-content/uploads/ngam-nhin-hinh-anh-van-phong-cong-ty-dep-an-tuong-13.jpg',
      'https://watermark.lovepik.com/photo/20211130/large/lovepik-corporate-team-image-picture_501247715.jpg'
    ];

    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    Size deviceSize = MediaQuery.of(context).size;
    context.read<CompanyManager>().fetchCompanyInfo();
    log('Ở company screen: ${context.read<CompanyManager>().company?.policy}');
    String? baseUrl = dotenv.env['DATABASE_BASE_URL'];
    return Scaffold(
      appBar: AppBar(
        title: Text('Công ty của tôi',
            style: textTheme.headlineMedium!.copyWith(
              color: theme.indicatorColor,
              fontWeight: FontWeight.bold,
            )),
        elevation: 5,
      ),
      body: FutureBuilder(
          future: context.read<CompanyManager>().fetchCompanyInfo(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const LoadingScreen();
            }

            return RefreshIndicator(
              onRefresh: () =>
                  context.read<CompanyManager>().fetchCompanyInfo(),
              child: Consumer<CompanyManager>(
                  builder: (context, companyManager, child) {
                return SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.blue[50]),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Container(
                          width: deviceSize.width,
                          padding: const EdgeInsets.only(
                              bottom: 40, top: 50, left: 10, right: 10),
                          decoration: const BoxDecoration(
                              image: DecorationImage(
                                  image: AssetImage(
                                      'assets/images/background.jpg'),
                                  fit: BoxFit.cover)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                height: 150,
                                width: 150,
                                decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.grey.shade600,
                                          spreadRadius: 1,
                                          blurRadius: 5,
                                          offset: const Offset(0, 3))
                                    ],
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            companyManager.company!.imageLink),
                                        fit: BoxFit.cover)),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              //todo Hiển thị tên công ty ở đây
                              Text(
                                companyManager.company!.companyName,
                                style: textTheme.titleLarge!.copyWith(
                                    color: theme.indicatorColor,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Lato',
                                    fontSize: 25),
                                softWrap: true,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  log('Chỉnh sửa công ty');
                                  context.pushNamed('company-edit',
                                      extra: companyManager.company);
                                },
                                child: const Text(
                                  'Chỉnh sửa',
                                  style: TextStyle(fontSize: 17),
                                ),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        BasicInfoCard(
                          title: 'Thông tin cơ bản',
                          children: [
                            //todo tiêu đề "Tên công ty" và giá trị
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 5),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Tên công ty: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(companyManager.company!.companyName,
                                  style: textTheme.bodyLarge),
                            ),
                            //todo Tiêu đề Email
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Email công ty: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(companyManager.company!.companyEmail,
                                  style: textTheme.bodyLarge),
                            ),
                            //todo Tiêu đề số diện thoại
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Số điện thoại: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(companyManager.company!.companyPhone,
                                  style: textTheme.bodyLarge),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Địa chỉ: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  companyManager.company!.companyAddress,
                                  style: textTheme.bodyLarge),
                            ),
                            //todo tiêu đề website
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Website: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  companyManager.company!.website!.isNotEmpty
                                      ? companyManager.company!.website!
                                      : 'Chưa thiết lập',
                                  style: textTheme.bodyLarge),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        //! Card hiển thị mô tả công ty
                        BasicInfoCard(
                          title: 'Mô tả về công ty',
                          children: <Widget>[
                            //? GIới thiệu về công ty
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Giới thiệu về công ty: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager
                                              .company!.description!.isEmpty ||
                                          companyManager
                                              .company!
                                              .description!['introduction']!
                                              .isEmpty)
                                      ? 'Viết mô tả tả về công ty của bạn, sứ mệnh và tầm nhìn'
                                      : companyManager.company!
                                          .description!['introduction']!,
                                  style: textTheme.bodyLarge),
                            ),
                            //? Lĩnh vực kinh doanh
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Lĩnh vực kinh doanh: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager
                                              .company!.description!.isEmpty ||
                                          companyManager.company!
                                              .description!['domain']!.isEmpty)
                                      ? 'Nghành nghề kinh doanh của công ty'
                                      : companyManager
                                          .company!.description!['domain']!,
                                  style: textTheme.bodyLarge),
                            ),
                            //? Quy mô công ty
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Quy mô công ty: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager
                                              .company!.description!.isEmpty ||
                                          companyManager
                                              .company!
                                              .description!['companySize']!
                                              .isEmpty)
                                      ? 'Quy mô công ty của bạn'
                                      : companyManager.company!
                                          .description!['companySize']!,
                                  style: textTheme.bodyLarge),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        //! Hình ảnh về công ty
                        BasicInfoCard(
                          title: 'Hình ảnh về công ty',
                          children: [
                            Container(
                              height: 300,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount:
                                    companyManager.company!.images.length,
                                itemBuilder: (context, index) {
                                  return Row(
                                    children: [
                                      ImageContainer(
                                        url:
                                            '$baseUrl${companyManager.company!.images[index]}',
                                        width: 250,
                                        height: 250,
                                      ),
                                      const SizedBox(
                                        width: 20,
                                      )
                                    ],
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        //! Thông tin liên hệ
                        BasicInfoCard(
                          title: 'Thông tin liên hệ',
                          children: [
                            //? Họ tên
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Họ và tên: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager.company!.contactInformation!
                                              .isEmpty ||
                                          companyManager
                                              .company!
                                              .contactInformation!['fullName']!
                                              .isEmpty)
                                      ? 'Hãy thiết lập tên người liên hệ'
                                      : companyManager.company!
                                          .contactInformation!['fullName']!,
                                  style: textTheme.bodyLarge),
                            ),
                            //? Chức vụ
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Chức vụ: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager.company!.contactInformation!
                                              .isEmpty ||
                                          companyManager
                                              .company!
                                              .contactInformation!['role']!
                                              .isEmpty)
                                      ? 'Hãy thiết lập chức vụ cho người liên hệ'
                                      : companyManager.company!
                                          .contactInformation!['role']!,
                                  style: textTheme.bodyLarge),
                            ),
                            //? Email
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Email: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager.company!.contactInformation!
                                              .isEmpty ||
                                          companyManager
                                              .company!
                                              .contactInformation!['email']!
                                              .isEmpty)
                                      ? 'Hãy thiết lập email cho người liên hệ'
                                      : companyManager.company!
                                          .contactInformation!['email']!,
                                  style: textTheme.bodyLarge),
                            ),
                            //? Số điện thoại
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Số điện thoại: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager.company!.contactInformation!
                                              .isEmpty ||
                                          companyManager
                                              .company!
                                              .contactInformation!['phone']!
                                              .isEmpty)
                                      ? 'Hãy thiết lập số điện thoại cho người liên hệ'
                                      : companyManager.company!
                                          .contactInformation!['phone']!,
                                  style: textTheme.bodyLarge),
                            )
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        //! Chính sách công ty
                        BasicInfoCard(
                          title: 'Chính sách công ty',
                          children: [
                            //? Chính sách tuyển dụng
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Chính sách tuyển dụng: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager.company!.policy!.isEmpty ||
                                          companyManager
                                              .company!
                                              .policy!['recruitmentPolicy']!
                                              .isEmpty)
                                      ? 'Hãy thiết lập chính sách tuyển dụng'
                                      : companyManager.company!
                                          .policy!['recruitmentPolicy']!,
                                  style: textTheme.bodyLarge),
                            ),
                            //? Chính sách làm việc
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Chính sách làm việc: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager.company!.policy!.isEmpty ||
                                          companyManager
                                              .company!
                                              .policy!['employmentPolicy']!
                                              .isEmpty)
                                      ? 'Hãy thiết lập chính sách làm viêc'
                                      : companyManager.company!
                                          .policy!['employmentPolicy']!,
                                  style: textTheme.bodyLarge),
                            ),
                            //? Chính sách phúc lợi
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Icon(
                                    Icons.star,
                                    color: theme.colorScheme.primary,
                                  ),
                                  Text(
                                    'Chính sách phúc lợi: ',
                                    style: textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30, right: 10),
                              child: Text(
                                  (companyManager.company!.policy!.isEmpty ||
                                          companyManager
                                              .company!
                                              .policy!['welfarePolicy']!
                                              .isEmpty)
                                      ? 'Hãy thiết lập chính sách phúc lợi'
                                      : companyManager
                                          .company!.policy!['welfarePolicy']!,
                                  style: textTheme.bodyLarge),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
    );
  }
}
