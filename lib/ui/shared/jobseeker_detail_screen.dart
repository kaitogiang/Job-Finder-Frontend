import 'dart:developer';
import 'dart:math' as math;

import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:job_finder_app/ui/employer/widgets/basic_info_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_education_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_experience_card.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/resume_infor_card.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../../models/jobseeker.dart';
import 'modal_bottom_sheet.dart';

class JobseekerDetailScreen extends StatefulWidget {
  const JobseekerDetailScreen({required this.jobseekerId, super.key});

  final String jobseekerId;

  @override
  State<JobseekerDetailScreen> createState() => _JobseekerDetailScreenState();
}

class _JobseekerDetailScreenState extends State<JobseekerDetailScreen> {
  final _scrollController = ScrollController();

  ValueNotifier<bool> isShowNameTitle = ValueNotifier(false);

  @override
  void initState() {
    //  implement initState
    _scrollController.addListener(() {
      if (_scrollController.offset > 253) {
        isShowNameTitle.value = true;
      } else {
        isShowNameTitle.value = false;
      }
    });

    // AwesomeNotifications().setListeners(
    //   onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    //   onNotificationCreatedMethod:
    //       NotificationController.onNotificationCreatedMethod,
    //   onNotificationDisplayedMethod:
    //       NotificationController.onNotificationDisplayedMethod,
    //   onDismissActionReceivedMethod:
    //       NotificationController.onDismissActionReceivedMethod,
    // );
    super.initState();
  }

  @override
  void dispose() {
    // implement dispose
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    // List<String> list = ['Java', 'Kỹ năng giao tiếp', 'Xử lý vấn đề', 'Nodejs'];
    Future<Jobseeker?> jobseekerFuture =
        context.read<ApplicationManager>().getJobseekerById(widget.jobseekerId);

    return Scaffold(
      body: FutureBuilder(
          future: jobseekerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            final jobseeker = snapshot.data;
            return Container(
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
                              isShow
                                  ? '${jobseeker?.firstName} ${jobseeker?.lastName}'
                                  : '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }),
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        padding: const EdgeInsets.only(
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
                                    jobseeker!.getImageUrl(),
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  '${jobseeker.firstName} ${jobseeker.lastName}',
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
                              overflow: TextOverflow.ellipsis,
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
                                  text: jobseeker.email,
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
                                const WidgetSpan(
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
                                    text: jobseeker.phone,
                                    style: textTheme.bodyLarge!.copyWith(
                                      color: Colors.white,
                                    ))
                              ]),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            RichText(
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(children: [
                                const WidgetSpan(
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
                                    text: jobseeker.address,
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
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Column(
                        children: [
                          BasicInfoCard(
                            title: 'Thông tin học vấn',
                            children: List<Widget>.generate(
                              jobseeker.education.length,
                              (index) => JobseekerEducationCard(
                                edu: jobseeker.education[index],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const ColorDivider(),
                  SliverToBoxAdapter(
                    child: Container(
                      width: deviceSize.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: BasicInfoCard(
                          title: 'Kinh nghiệm làm việc',
                          children: List<Widget>.generate(
                            jobseeker.experience.length,
                            (index) => JobseekerExperienceCard(
                              exp: jobseeker.experience[index],
                            ),
                          )),
                    ),
                  ),
                  const ColorDivider(),
                  SliverToBoxAdapter(
                    child: Container(
                      width: deviceSize.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
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
                            children: List<Widget>.generate(
                                jobseeker.skills.length, (index) {
                              return InputChip(
                                label: Text(
                                  jobseeker.skills[index],
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
                  const ColorDivider(),
                  SliverToBoxAdapter(
                    child: Container(
                      width: deviceSize.width,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: BasicInfoCard(
                        title: 'CV',
                        children: [
                          ResumeInforCard(
                            resume: jobseeker.resume[0],
                            onAction: () {
                              log('Tải xuống CV');
                              showAdditionalScreen(
                                  context: context,
                                  title: 'Tùy chọn',
                                  child: Builder(builder: (context) {
                                    return _buildActionButton(
                                      context: context,
                                      onDownload: () async {
                                        log('Tải xuống tài liệu');
                                        bool isAllowedToSendNotification =
                                            await AwesomeNotifications()
                                                .isNotificationAllowed();
                                        if (!isAllowedToSendNotification) {
                                          AwesomeNotifications()
                                              .requestPermissionToSendNotifications();
                                        }
                                        DateTime.now().toIso8601String();
                                        if (context.mounted) {
                                          final path = await context
                                              .read<ApplicationManager>()
                                              .downloadFile(
                                                  jobseeker.resume[0].url,
                                                  jobseeker.resume[0].fileName);
                                          if (path != null && context.mounted) {
                                            QuickAlert.show(
                                                context: context,
                                                type: QuickAlertType.info,
                                                title: 'Tải xuống thành công',
                                                text:
                                                    'File được tải xuống tại $path',
                                                confirmBtnText: 'Tôi biết rồi');
                                          }
                                        }

                                        int random =
                                            math.Random(10).nextInt(1000);
                                        final Map<String, String> data = {
                                          'type': 'download_notification',
                                        };
                                        AwesomeNotifications()
                                            .createNotification(
                                          content: NotificationContent(
                                            id: random,
                                            channelKey: 'basic_channel',
                                            actionType: ActionType.Default,
                                            title: 'Tải xuống thành công',
                                            body:
                                                'Tại xuống tại thư mục /storage/emulated/0/Download/, nhấn vào để mở',
                                            payload: data,
                                          ),
                                        );
                                      },
                                    );
                                  }),
                                  heightFactor: 0.25);
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const ColorDivider(),
                ],
              ),
            );
          }),
    );
  }

  ListView _buildActionButton({
    required BuildContext context,
    void Function()? onDownload,
  }) {
    return ListView(
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
        const Divider(),
      ],
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
