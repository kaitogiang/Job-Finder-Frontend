import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/auth/auth_manager.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/loading_screen.dart';
import 'package:provider/provider.dart';
import '../../models/resume.dart';
import '../shared/modal_bottom_sheet.dart';
import 'widgets/jobseeker_education_card.dart';
import 'widgets/jobseeker_experience_card.dart';
import 'widgets/jobseeker_info_card.dart';
import 'widgets/resume_infor_card.dart';

class JobseekerProfileScreen extends StatelessWidget {
  const JobseekerProfileScreen({super.key});

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
          flexibleSpace: Container(
            width: deviceSize.width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    Colors.blueAccent.shade700,
                    Colors.blueAccent.shade400,
                    theme.primaryColor,
                  ]),
            ),
          ),
        ),
        body: FutureBuilder(
            future: context.read<JobseekerManager>().fetchJobseekerInfo(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const LoadingScreen();
              }
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<JobseekerManager>().fetchJobseekerInfo(),
                child: Consumer<JobseekerManager>(
                    builder: (context, jobseekerManager, child) {
                  return SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Khung chứa ảnh đại diện và thông tin cơ bản ngắn gọn
                          Container(
                            height: 200,
                            padding: EdgeInsets.only(bottom: 13),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.blueAccent.shade700,
                                    Colors.blueAccent.shade400,
                                    theme.primaryColor,
                                  ]),
                              color: theme.primaryColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
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
                                        image: NetworkImage(jobseekerManager
                                            .jobseeker
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //Họ và Tên hiển thị ở đây
                                        Text(
                                          '${jobseekerManager.jobseeker.firstName} ${jobseekerManager.jobseeker.lastName}',
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
                                              color:
                                                  theme.colorScheme.secondary,
                                            ),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Expanded(
                                              child: Text(
                                                jobseekerManager
                                                    .jobseeker.email,
                                                style: textTheme.titleMedium!
                                                    .copyWith(
                                                  color: theme
                                                      .colorScheme.secondary,
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
                                                child: SizedBox(
                                              width: 10,
                                            )),
                                            TextSpan(
                                                text: jobseekerManager
                                                    .jobseeker.phone,
                                                style: textTheme.titleMedium!
                                                    .copyWith(
                                                  color: theme
                                                      .colorScheme.secondary,
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
                          JobseekerInfoCard(
                            title: 'Thông tin cá nhân',
                            iconButton: IconButton(
                              onPressed: () {
                                log('Chỉnh sửa thông tin cá nhân');
                                // jobseekerManager.modifyFirstName('Thị Nó');
                                context.pushNamed('information-edit',
                                    extra: jobseekerManager.jobseeker);
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
                                  value1: jobseekerManager.jobseeker.lastName,
                                  title2: 'Tên',
                                  value2: jobseekerManager.jobseeker.firstName,
                                  textTheme: textTheme,
                                  theme: theme),
                              _buildInfoRow(
                                  title1: 'Số điện thoại',
                                  value1: jobseekerManager.jobseeker.phone,
                                  title2: 'Địa chỉ',
                                  value2: jobseekerManager.jobseeker.address,
                                  textTheme: textTheme,
                                  theme: theme),
                              _buildInfoRow(
                                  title1: 'Email',
                                  value1: jobseekerManager.jobseeker.email,
                                  textTheme: textTheme,
                                  theme: theme),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //NOT USE: Card hiển thị thông tin CV đã tải lên
                          // JobseekerInfoCard(
                          //   //Tiêu đề cho Card
                          //   title: 'CV của tôi',
                          //   children: [
                          //     //Khung dùng để chứa thông tin tên CV và ngày tải lên cùng nút
                          //     //Hành động, một dòng chứa CV được tải lên
                          //     jobseekerManager.jobseeker.resume.isEmpty
                          //         ? Container(
                          //             margin: EdgeInsets.only(top: 10),
                          //             child: Text(
                          //               'Bạn chưa tải CV nào, hãy tải lên để các nhà tuyển dụng có thể thấy CV của bạn',
                          //               style: textTheme.bodyLarge,
                          //             ),
                          //           )
                          //         : ResumeInforCard(
                          //             resume: Resume(
                          //                 fileName: jobseekerManager
                          //                     .jobseeker.resume[0].fileName,
                          //                 url: jobseekerManager
                          //                     .jobseeker.resume[0].url,
                          //                 uploadedDate: jobseekerManager
                          //                     .jobseeker
                          //                     .resume[0]
                          //                     .uploadedDate),
                          //           ),
                          //     const SizedBox(
                          //       height: 20,
                          //     ),
                          //     //Nút tùy chỉnh CV
                          //     ElevatedButton(
                          //       onPressed: () {
                          //         log('Chỉnh sửa CV');
                          //         Resume? resume = jobseekerManager
                          //                 .jobseeker.resume.isEmpty
                          //             ? null
                          //             : jobseekerManager.jobseeker.resume[0];
                          //         context.pushNamed('resume-upload',
                          //             extra: resume);
                          //       },
                          //       style: ElevatedButton.styleFrom(
                          //         side: BorderSide(
                          //             color: theme.colorScheme.primary),
                          //         backgroundColor: theme.indicatorColor,
                          //         elevation: 0,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(10),
                          //         ),
                          //         foregroundColor: theme.colorScheme.primary,
                          //         fixedSize: Size(deviceSize.width - 30, 50),
                          //         textStyle: textTheme.titleLarge!.copyWith(
                          //             fontFamily: 'Lato', fontSize: 20),
                          //       ),
                          //       child: Text(
                          //           jobseekerManager.jobseeker.resume.isEmpty
                          //               ? 'Tải lên CV'
                          //               : 'Chỉnh sửa CV'),
                          //     )
                          //   ],
                          // ),
                          // const SizedBox(
                          //   height: 20,
                          // ),
                          //Card hiển thị các kinh nghiệm làm việc của ứng viên
                          JobseekerInfoCard(
                            title: 'Kinh nghiệm làm việc',
                            iconButton: IconButton(
                              onPressed: () {
                                log('Thêm kinh nghiệm mới');
                                context.pushNamed('experience-addition');
                              },
                              icon: Icon(
                                Icons.add_circle,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            children: [
                              //đại diện cho một kinh nghiệm làm việc, những kinh nghiệm
                              //sẽ được liệt kê tại đây
                              jobseekerManager.jobseeker.experience.isEmpty
                                  ? Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Thêm kinh nghiệm làm việc để tăng cơ hội trong mắt nhà tuyển dụng, 77% nhà tuyển dụng ưu tiên quan tâm khi xét duyệt hồ sơ',
                                        style: textTheme.bodyLarge,
                                      ),
                                    )
                                  : ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: jobseekerManager
                                          .jobseeker.experience.length,
                                      itemBuilder: (context, index) {
                                        return SizedBox(
                                          child: JobseekerExperienceCard(
                                            exp: jobseekerManager
                                                .jobseeker.experience[index],
                                            onCustomize: () {
                                              log('Chỉnh sửa hoặc xóa kinh nghiệm làm việc');
                                              showAdditionalScreen(
                                                  context: context,
                                                  title: 'Tùy chọn',
                                                  child: Builder(
                                                      builder: (context) {
                                                    return _buildActionButton(
                                                      context: context,
                                                      onDelete: () async {
                                                        log('Xóa bỏ kinh nghiệm');
                                                        await context
                                                            .read<
                                                                JobseekerManager>()
                                                            .removeExperience(
                                                                index);
                                                        if (context.mounted) {
                                                          Navigator.pop(
                                                              context);
                                                        }
                                                      },
                                                      onEdit: () {
                                                        log('Xem trước file');
                                                        Navigator.pop(context);
                                                        context.pushNamed(
                                                            'experience-addition',
                                                            extra: jobseekerManager
                                                                    .jobseeker
                                                                    .experience[
                                                                index]);
                                                      },
                                                    );
                                                  }),
                                                  heightFactor: 0.3);
                                            },
                                          ),
                                        );
                                      },
                                    )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //Card hiển thị thông tin học vấn
                          JobseekerInfoCard(
                            title: 'Học vấn của tôi',
                            iconButton: IconButton(
                              onPressed: () {
                                context.pushNamed('education-addition');
                              },
                              icon: Icon(
                                Icons.add_circle,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            children: [
                              jobseekerManager.jobseeker.education.isEmpty
                                  ? Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Thêm học vấn để tăng cơ hội khi ứng tuyển',
                                        style: textTheme.bodyLarge,
                                      ),
                                    )
                                  : ListView.builder(
                                      itemCount: jobseekerManager
                                          .jobseeker.education.length,
                                      physics: NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return JobseekerEducationCard(
                                          //Đại diện cho một học vấn, những học vấn sẽ được liệt kê tại đây
                                          edu: jobseekerManager
                                              .jobseeker.education[index],
                                          onCustomize: () {
                                            showAdditionalScreen(
                                                context: context,
                                                title: 'Tùy chọn',
                                                child:
                                                    Builder(builder: (context) {
                                                  return _buildActionButton(
                                                    context: context,
                                                    onDelete: () async {
                                                      log('Xóa bỏ kinh nghiệm');
                                                      await context
                                                          .read<
                                                              JobseekerManager>()
                                                          .removeEducation(
                                                              index);
                                                      if (context.mounted) {
                                                        Navigator.pop(context);
                                                      }
                                                    },
                                                    onEdit: () {
                                                      log('Xem trước file');
                                                      Navigator.pop(context);
                                                      context.pushNamed(
                                                          'education-addition',
                                                          extra: jobseekerManager
                                                                  .jobseeker
                                                                  .education[
                                                              index]);
                                                    },
                                                  );
                                                }),
                                                heightFactor: 0.3);
                                          },
                                        );
                                      },
                                    )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //Card hiển thị kỹ năng (mềm, lập trình, v.vv.)
                          JobseekerInfoCard(
                            title: 'Kỹ năng của tôi',
                            iconButton: IconButton(
                              onPressed: () {
                                log('Tùy chỉnh kỹ năng');
                                context.pushNamed('skill-addition');
                              },
                              icon: Icon(
                                Icons.edit,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            children: [
                              jobseekerManager.jobseeker.skills.isEmpty
                                  ? Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Thêm học kỹ năng để nhà tuyển dụng có thể xác định khả năng của bạn',
                                        style: textTheme.bodyLarge,
                                      ),
                                    )
                                  : Wrap(
                                      alignment: WrapAlignment.start,
                                      spacing: 5,
                                      runSpacing: 3,
                                      children: List<Widget>.generate(
                                          jobseekerManager.skills.length,
                                          (index) {
                                        return InputChip(
                                          label: Text(
                                            jobseekerManager.skills[index],
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          onDeleted: () async {
                                            log('Xóa kỹ năng ${jobseekerManager.skills[index]}');
                                            await context
                                                .read<JobseekerManager>()
                                                .removeSkill(jobseekerManager
                                                    .skills[index]);
                                          },
                                          labelStyle: TextStyle(
                                              color: Colors.grey.shade700),
                                        );
                                      }).toList(),
                                    )
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          //TODO Demo thử nghiệm tạo CV cứng

                          // JobseekerInfoCard(
                          //   title: 'Danh sach CV',
                          //   children: [
                          //     TextButton(
                          //       onPressed: () {
                          //         context.pushNamed('resume-creation',
                          //             extra: jobseekerManager.jobseeker);
                          //       },
                          //       child: Text('Tạo CV mới'),
                          //     ),
                          //     const SizedBox(
                          //       height: 10,
                          //     ),
                          //     TextButton(
                          //       onPressed: () {
                          //         Navigator.of(context, rootNavigator: true)
                          //             .push(
                          //           MaterialPageRoute(
                          //             builder: (context) =>
                          //                 const ResumePreviewScreen(
                          //               url:
                          //                   '/pdfs/jobseeker-1729431205323-171481625.pdf',
                          //             ),
                          //           ),
                          //         );
                          //       },
                          //       child: Text('Xem CV trực tiếp'),
                          //     ),
                          //   ],
                          // ),
                          JobseekerInfoCard(
                            title: 'CV của tôi',
                            children: [
                              //Khung dùng để chứa thông tin tên CV và ngày tải lên cùng nút
                              //Hành động, một dòng chứa CV được tải lên
                              jobseekerManager.jobseeker.resume.isEmpty
                                  ? Container(
                                      margin: EdgeInsets.only(top: 10),
                                      child: Text(
                                        'Bạn chưa tạo CV nào, hãy tạo CV để các nhà tuyển dụng có thể thấy CV của bạn',
                                        style: textTheme.bodyLarge,
                                      ),
                                    )
                                  : ListView.builder(
                                      physics: NeverScrollableScrollPhysics(),
                                      itemCount: jobseekerManager
                                          .jobseeker.resume.length,
                                      shrinkWrap: true,
                                      itemBuilder: (context, index) {
                                        return Padding(
                                          padding:
                                              const EdgeInsets.only(bottom: 7),
                                          child: ResumeInforCard(
                                            resume: Resume(
                                              fileName: jobseekerManager
                                                  .jobseeker
                                                  .resume[index]
                                                  .fileName,
                                              url: jobseekerManager
                                                  .jobseeker.resume[index].url,
                                              uploadedDate: jobseekerManager
                                                  .jobseeker
                                                  .resume[index]
                                                  .uploadedDate,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                              const SizedBox(
                                height: 20,
                              ),
                              //Nút tùy chỉnh CV
                              ElevatedButton(
                                onPressed: () {
                                  log('Chỉnh sửa CV');
                                  Resume? resume = jobseekerManager
                                          .jobseeker.resume.isEmpty
                                      ? null
                                      : jobseekerManager.jobseeker.resume[0];
                                  context.pushNamed('resume-list',
                                      extra: resume);
                                },
                                style: ElevatedButton.styleFrom(
                                  side: BorderSide(
                                      color: theme.colorScheme.primary),
                                  backgroundColor: theme.indicatorColor,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  foregroundColor: theme.colorScheme.primary,
                                  fixedSize: Size(deviceSize.width - 30, 50),
                                  textStyle: textTheme.titleLarge!.copyWith(
                                      fontFamily: 'Lato', fontSize: 20),
                                ),
                                child: Text(
                                    jobseekerManager.jobseeker.resume.isEmpty
                                        ? 'Tạo mới CV'
                                        : 'Chỉnh sửa CV'),
                              )
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
                    ),
                  );
                }),
              );
            }));
  }

  ListView _buildActionButton({
    required BuildContext context,
    void Function()? onDelete,
    void Function()? onEdit,
  }) {
    return ListView(
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
