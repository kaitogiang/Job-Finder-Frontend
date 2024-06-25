import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/models/resume.dart';
import 'package:job_finder_app/ui/employer/widgets/basic_info_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_education_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_experience_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/resume_infor_card.dart';
import 'package:quickalert/quickalert.dart';

import '../../models/experience.dart';
import 'modal_bottom_sheet.dart';

class JobseekerDetailScreen extends StatefulWidget {
  const JobseekerDetailScreen({super.key});

  @override
  State<JobseekerDetailScreen> createState() => _JobseekerDetailScreenState();
}

class _JobseekerDetailScreenState extends State<JobseekerDetailScreen> {
  final _scrollController = ScrollController();

  ValueNotifier<bool> isShowNameTitle = ValueNotifier(false);

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(() {
      if (_scrollController.offset > 164) {
        isShowNameTitle.value = true;
      } else {
        isShowNameTitle.value = false;
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    List<String> list = ['Java', 'Kỹ năng giao tiếp', 'Xử lý vấn đề', 'Nodejs'];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.blueAccent.shade700,
              Colors.blueAccent.shade400,
              theme.primaryColor,
            ],
          ),
        ),
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            SliverAppBar(
              elevation: 0,
              centerTitle: true,
              expandedHeight: 300,
              pinned: true,
              title: ValueListenableBuilder(
                  valueListenable: isShowNameTitle,
                  builder: (context, isShow, child) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 2700),
                      child: Text(
                        isShow ? 'Nguyễn Văn Tèo' : '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }),
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  padding: EdgeInsets.only(
                    top: 60,
                    bottom: 20,
                    left: 20,
                    right: 20,
                  ),
                  width: deviceSize.width,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.blueAccent.shade700,
                        Colors.blueAccent.shade400,
                        theme.primaryColor,
                      ],
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 48,
                            backgroundImage: NetworkImage(
                              'https://neural.love/cdn/ai-photostock/1edd0a8a-40e9-6bf8-94c0-6b682aa3e89d/0.jpg?Expires=1722470399&Signature=0KZ831ioyN-LnEPKtkfiaJ0BVkCFI~nnq8C7ppPJ1HFNFZuQ4wbtInE6ok2Apr1qD0MZTvnvQCw0xZ4rJoR7Gz~h3x-7wa~8D2MniCx5uW9k2WiEydgiZZkoPrr1xsYnG78FAo-7WvnQ8H9i8bisgDf8zDwTZI5b0y-bTh7Nubo1JzRau0kJ2rkPkLgmsH7NiU7Cs8njEfT89eLJOpenzUKPb-rTe-JXRDY1Y2l0T~zoGQA19-U1su40Nrfej1DovFLLwcoAPvZJ--e5kOSLd8R~Q~mEHAknf2eETm~8~DmWEayBezWw9hwnOrOjK30FgTSREgYD3Tj4N4jmT7GmfA__&Key-Pair-Id=K2RFTOXRBNSROX',
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text(
                            'Như Nguyễn',
                            style: textTheme.titleLarge!.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.email,
                              color: Colors.grey[300],
                            ),
                          ),
                          const WidgetSpan(
                              child: SizedBox(
                            width: 6,
                          )),
                          TextSpan(
                            text: '359hked2@lastmx.com',
                            style: textTheme.bodyLarge!.copyWith(
                              color: Colors.grey[300],
                            ),
                          )
                        ]),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.phone,
                              color: Colors.white,
                            ),
                          ),
                          const WidgetSpan(
                              child: SizedBox(
                            width: 6,
                          )),
                          TextSpan(
                              text: '0396922685',
                              style: textTheme.bodyLarge!.copyWith(
                                color: Colors.white,
                              ))
                        ]),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      RichText(
                        text: TextSpan(children: [
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: Icon(
                              Icons.location_on,
                              color: Colors.white,
                            ),
                          ),
                          const WidgetSpan(
                              child: SizedBox(
                            width: 6,
                          )),
                          TextSpan(
                              text: 'Bạc Liêu',
                              style: textTheme.bodyLarge!.copyWith(
                                color: Colors.white,
                              ))
                        ]),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: deviceSize.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  children: [
                    BasicInfoCard(
                      title: 'Thông tin học vấn',
                      children: [
                        JobseekerEducationCard(
                          edu: Education(
                            specialization: 'Cử nhân',
                            degree: 'Đại học',
                            school: 'Đại Học hoàn hảo',
                            startDate: '06/2020',
                            endDate: '12/2024',
                          ),
                        ),
                        JobseekerEducationCard(
                          edu: Education(
                            specialization: 'Cử nhân',
                            degree: 'Đại học',
                            school: 'Đại Học hoàn hảo',
                            startDate: '06/2020',
                            endDate: '12/2024',
                          ),
                        ),
                        JobseekerEducationCard(
                          edu: Education(
                            specialization: 'Cử nhân',
                            degree: 'Đại học',
                            school: 'Đại Học hoàn hảo',
                            startDate: '06/2020',
                            endDate: '12/2024',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            ColorDivider(),
            SliverToBoxAdapter(
              child: Container(
                width: deviceSize.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: BasicInfoCard(
                  title: 'Kinh nghiệm làm việc',
                  children: [
                    JobseekerExperienceCard(
                      exp: Experience(
                        role: 'Chuyên gia bảo mật',
                        company: 'Công ty hòa bình xanh',
                        duration: '06/2015 - Hiện nay',
                      ),
                    ),
                    JobseekerExperienceCard(
                      exp: Experience(
                        role: 'Chuyên gia bảo mật',
                        company: 'Công ty hòa bình xanh',
                        duration: '06/2015 - Hiện nay',
                      ),
                    ),
                    JobseekerExperienceCard(
                      exp: Experience(
                        role: 'Chuyên gia bảo mật',
                        company: 'Công ty hòa bình xanh',
                        duration: '06/2015 - Hiện nay',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ColorDivider(),
            SliverToBoxAdapter(
              child: Container(
                width: deviceSize.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: BasicInfoCard(
                  title: 'Kỹ năng',
                  children: [
                    Wrap(
                      direction: Axis.horizontal,
                      spacing: 5,
                      children: List<Widget>.generate(list.length, (index) {
                        return InputChip(
                          label: Text(
                            list[index],
                            style: TextStyle(
                              color: theme.primaryColor,
                            ),
                          ),
                          elevation: 2,
                          padding: const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(40),
                            side: BorderSide(
                              color: Colors.grey[400]!,
                            ),
                          ),
                          backgroundColor: Colors.blue[200],
                          color: WidgetStateColor.resolveWith((state) {
                            return Colors.blue[50]!;
                          }),
                          onSelected: (value) {},
                        );
                      }),
                    )
                  ],
                ),
              ),
            ),
            ColorDivider(),
            SliverToBoxAdapter(
              child: Container(
                width: deviceSize.width,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: BasicInfoCard(
                  title: 'CV',
                  children: [
                    resume_info_card(
                      resume: Resume(
                          fileName: 'MyCV.pdf',
                          url: 'jljkaljlksdaf',
                          uploadedDate: DateTime.now()),
                      onAction: () {
                        log('Tải xuống CV');
                        showAdditionalScreen(
                            context: context,
                            title: 'Tùy chọn',
                            child: Builder(builder: (context) {
                              return _buildActionButton(
                                context: context,
                                onDownload: () async {
                                  log('Xóa bỏ kinh nghiệm');

                                  Navigator.pop(context);
                                },
                              );
                            }),
                            heightFactor: 0.25);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container _buildActionButton({
    required BuildContext context,
    void Function()? onDownload,
  }) {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(
              'Tải xuống',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            leading: Icon(Icons.download),
            onTap: onDownload,
          ),
          Divider(),
        ],
      ),
    );
  }
}

class ColorDivider extends StatelessWidget {
  const ColorDivider({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return SliverToBoxAdapter(
      child: Container(
        width: deviceSize.width,
        height: 15,
        decoration: BoxDecoration(
          color: Colors.blue[50],
        ),
      ),
    );
  }
}
