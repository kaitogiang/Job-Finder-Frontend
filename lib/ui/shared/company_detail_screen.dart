import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/shared/image_container.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:provider/provider.dart';
import 'package:shadow_overlay/shadow_overlay.dart';

import '../../models/company.dart';

class CompanyDetailScreen extends StatelessWidget {
  const CompanyDetailScreen(this.company, {super.key});

  final Company company;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsCrolled) => [
            SliverAppBar(
              expandedHeight: 400.0,
              floating: false,
              pinned: true,
              toolbarHeight: 80,
              title: Padding(
                padding: const EdgeInsets.only(left: 0, right: 30),
                //? Hiển thị tên công ty ở phần giữa AppBar
                child: Text(
                  company.companyName,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleLarge!
                      .copyWith(color: Colors.white, fontSize: 20),
                ),
              ),
              centerTitle: true,
              leading: Padding(
                padding: const EdgeInsets.only(left: 20),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              // backgroundColor: const Color.fromRGBO(39, 107, 152, 1),
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 1,
                background: Container(
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage(
                            'assets/images/company_detail_background.jpg'),
                        fit: BoxFit.cover),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                      top: 100,
                      left: 20,
                      right: 20,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          //? Hiển thị ảnh đại diện của công ty
                          child: Image.network(
                            company.avatarLink,
                            width: 150,
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //? Hiển thị tiêu đề của bài tuyển dụng
                        Text(
                          company.companyName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        //? Hiển thị ngày hết hạn ứng tuyển của bài viết
                        Text(
                          '${company.description?['domain']}',
                          style: theme.textTheme.bodySmall!.copyWith(
                            color: Colors.grey.shade400,
                            fontSize: 15,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                titlePadding: EdgeInsets.zero,
              ),
            ),
            SliverAppBar(
              toolbarHeight: 30,
              centerTitle: true,
              elevation: 0,
              flexibleSpace: Container(
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: theme.indicatorColor,
                ),
                child: TabBar(
                  labelColor: theme.primaryColor,
                  automaticIndicatorColorAdjustment: false,
                  dividerHeight: 3,
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelStyle: theme.textTheme.bodyLarge!.copyWith(
                    color: Colors.blue,
                  ),
                  unselectedLabelColor: Colors.grey.shade600,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(
                      height: 70,
                      child: Text('Thông tin'),
                    ),
                    Tab(
                      height: 70,
                      child: Text('Tuyển dụng'),
                    )
                  ],
                ),
              ),
              pinned: true,
              forceElevated: false,
            ),
          ],
          body: TabBarView(
            children: [
              CompanyInfoScreen(company),
              CompanyRecruitmentScreen(company.id),
            ],
          ),
        ),
      ),
    );
  }
}

class CompanyInfoScreen extends StatefulWidget {
  const CompanyInfoScreen(this.company, {super.key});

  final Company company;

  @override
  State<CompanyInfoScreen> createState() => _CompanyInfoScreenState();
}

class _CompanyInfoScreenState extends State<CompanyInfoScreen> {
  bool _isExpanded = false;
  bool _isExpandedPolicy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    return SingleChildScrollView(
      child: Container(
        decoration: BoxDecoration(color: Colors.blue[50]),
        child: Column(
          children: <Widget>[
            //? Hiển thị thông tin cơ bản
            Container(
              decoration: BoxDecoration(
                color: theme.indicatorColor,
              ),
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info,
                        color: Color.fromRGBO(12, 54, 117, 1),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Thông tin cơ bản',
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(12, 54, 117, 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: AnimatedCrossFade(
                      crossFadeState: _isExpanded
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 400),
                      firstChild: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                widget.company.companyEmail,
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Số điện thoại công ty:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                widget.company.companyPhone,
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Địa chỉ:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                widget.company.companyAddress,
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Lĩnh vực:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                '${widget.company.description?['domain']}',
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Quy mô công ty:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                '${widget.company.description?['companySize']} nhân viên',
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Website:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                widget.company.website,
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Giới thiệu:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              ShadowOverlay(
                                shadowHeight: 150,
                                shadowWidth: deviceSize.width,
                                shadowColor:
                                    const Color.fromRGBO(249, 249, 249, 1),
                                child: Text(
                                  '${widget.company.description?['introduction']}',
                                  style: theme.textTheme.bodyLarge,
                                  softWrap: true,
                                  maxLines: 4,
                                  textAlign: TextAlign.justify,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = true;
                                    });
                                  },
                                  child: const Text(
                                    'Xem thêm',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      secondChild: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Email:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                widget.company.companyEmail,
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Số điện thoại công ty:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                widget.company.companyPhone,
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Địa chỉ:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                widget.company.companyAddress,
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Lĩnh vực:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                '${widget.company.description?['domain']}',
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Quy mô công ty:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                '${widget.company.description?['companySize']} nhân viên',
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Website:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                widget.company.website,
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Giới thiệu:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                '${widget.company.description?['introduction']}',
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Divider(),
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpanded = false;
                                    });
                                  },
                                  child: const Text(
                                    'thu bớt',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.indicatorColor,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info,
                        color: Color.fromRGBO(12, 54, 117, 1),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Hình ảnh công ty',
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(12, 54, 117, 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    height: 170,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                    ),
                    child: widget.company.images.isNotEmpty
                        ? ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: widget.company.images.length,
                            itemBuilder: (context, index) {
                              List<String> imagesList = widget.company.images
                                  .map((e) =>
                                      '${dotenv.env['DATABASE_BASE_URL']}/$e')
                                  .toList();
                              return Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      log('Coi preview $index');
                                      Map<String, dynamic> data = {
                                        'images': imagesList,
                                        'index': index,
                                      };
                                      final root = Navigator.of(context,
                                              rootNavigator: true)
                                          .toString();
                                      log('Navigator root la: $root');
                                      context.pushNamed('image-preview',
                                          extra: data);
                                    },
                                    child: ImageContainer(
                                      height: 150,
                                      width: 150,
                                      url: imagesList[index],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              );
                            },
                          )
                        : Center(
                            child: Text(
                            'Chưa có hình ảnh',
                            style: theme.textTheme.bodyLarge,
                          )),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.indicatorColor,
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.info,
                        color: Color.fromRGBO(12, 54, 117, 1),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                        'Chính sách công ty',
                        style: theme.textTheme.titleLarge!.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(12, 54, 117, 1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  FractionallySizedBox(
                    widthFactor: 1,
                    child: AnimatedCrossFade(
                      crossFadeState: _isExpandedPolicy
                          ? CrossFadeState.showSecond
                          : CrossFadeState.showFirst,
                      duration: const Duration(milliseconds: 400),
                      firstChild: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chính sách tuyển dụng:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              ShadowOverlay(
                                shadowHeight: 150,
                                shadowWidth: deviceSize.width,
                                shadowColor:
                                    const Color.fromRGBO(249, 249, 249, 1),
                                child: Text(
                                  '${widget.company.policy?['recruitmentPolicy']}',
                                  style: theme.textTheme.bodyLarge,
                                  softWrap: true,
                                  textAlign: TextAlign.justify,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpandedPolicy = true;
                                    });
                                  },
                                  child: const Text(
                                    'Xem thêm',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      secondChild: Card(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 25,
                            vertical: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Chính sách tuyển dụng:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                '${widget.company.policy?['recruitmentPolicy']}',
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Chính sách làm việc:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                '${widget.company.policy?['employmentPolicy']}',
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                'Chính sách phúc lợi:',
                                style: theme.textTheme.bodyLarge!.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              Text(
                                '${widget.company.policy?['welfarePolicy']}',
                                style: theme.textTheme.bodyLarge,
                                softWrap: true,
                                textAlign: TextAlign.justify,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                child: Divider(),
                              ),
                              Center(
                                child: TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _isExpandedPolicy = false;
                                    });
                                  },
                                  child: const Text(
                                    'thu bớt',
                                    style: TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CompanyRecruitmentScreen extends StatelessWidget {
  const CompanyRecruitmentScreen(this.id, {super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: theme.indicatorColor,
        ),
        child: Consumer<JobpostingManager>(
            builder: (context, jobpostingManager, child) {
          final companyPosts = jobpostingManager.companyJobpostings(id);
          return Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.work,
                    color: Color.fromRGBO(12, 54, 117, 1),
                  ),
                  const SizedBox(
                    width: 4,
                  ),
                  Text(
                    'Việc đang tuyển dụng',
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromRGBO(12, 54, 117, 1),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              ...List<Widget>.generate(
                companyPosts.length,
                (index) => Column(
                  children: [
                    JobCard(companyPosts[index]),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
