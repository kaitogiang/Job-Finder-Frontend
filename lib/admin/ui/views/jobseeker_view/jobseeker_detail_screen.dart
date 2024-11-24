import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/jobseeker_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_detail_tabview/jobseeker_educations_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_detail_tabview/jobseeker_experiences_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_detail_tabview/jobseeker_skills_screen.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:provider/provider.dart';

class JobseekerDetailScreen extends StatelessWidget {
  const JobseekerDetailScreen({super.key, required this.jobseekerFuture});

  final Future<Jobseeker?> jobseekerFuture;

  Future<void> _downloadResume(
      BuildContext context, String url, String fileName) async {
    Utils.logMessage('Tải CV');
    if (context.mounted) {
      await context.read<JobseekerListManager>().downloadCV(url, fileName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final basicInfoTitle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black54);
    final basicInfoTitleIcon = Colors.black54;
    final titleCardStyle =
        textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);
    //Trích xuất các thông tin trong Jobseeker
    Utils.logMessage("JobseekerDetailScreen rebuilt");
    return FutureBuilder<Jobseeker?>(
        future: jobseekerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SizedBox(
              width: 800,
              child: const Center(child: CircularProgressIndicator()),
            );
          }
          final jobseeker = snapshot.data!;
          final techList = jobseeker.skills;
          final expList = jobseeker.experience;
          final eduList = jobseeker.education;
          final isEmptyResum = jobseeker.resume.isEmpty;
          return SizedBox(
            width: 800,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        //Ảnh đại diện của ứng viên
                        Container(
                          alignment: Alignment.center,
                          child: SizedBox(
                            width: 150,
                            child: CircleAvatar(
                              radius: 100,
                              backgroundImage:
                                  NetworkImage(jobseeker.getImageUrl()),
                              onBackgroundImageError: (exception, stackTrace) {
                                debugPrint(exception.toString());
                              },
                            ),
                          ),
                        ),
                        Text(
                          '${jobseeker.firstName} ${jobseeker.lastName}',
                          textAlign: TextAlign.center,
                          style: textTheme.titleMedium!.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Thông tin cơ bản',
                                  style: titleCardStyle,
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: textTheme.bodyMedium,
                                      children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.email,
                                            size: 17,
                                            color:
                                                basicInfoTitleIcon, // Added color property
                                          ),
                                        ),
                                        WidgetSpan(
                                            child: const SizedBox(width: 5)),
                                        TextSpan(
                                            text: 'Email',
                                            style: basicInfoTitle),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    jobseeker.email,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: textTheme.bodyMedium,
                                      children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.phone,
                                            size: 17,
                                            color:
                                                basicInfoTitleIcon, // Added color property
                                          ),
                                        ),
                                        WidgetSpan(
                                            child: const SizedBox(width: 5)),
                                        TextSpan(
                                            text: 'Số điện thoại',
                                            style: basicInfoTitle),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    jobseeker.phone,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: RichText(
                                    text: TextSpan(
                                      style: textTheme.bodyMedium,
                                      children: [
                                        WidgetSpan(
                                          alignment:
                                              PlaceholderAlignment.middle,
                                          child: Icon(
                                            Icons.location_on,
                                            size: 17,
                                            color:
                                                basicInfoTitleIcon, // Added color property
                                          ),
                                        ),
                                        WidgetSpan(
                                            child: const SizedBox(width: 5)),
                                        TextSpan(
                                            text: 'Tỉnh/thành phố',
                                            style: basicInfoTitle),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                    jobseeker.address,
                                    style: textTheme.bodyMedium,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Center(
                                  child: TextButton(
                                    style: TextButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          Colors.grey.shade300,
                                      disabledForegroundColor: Colors.white,
                                      textStyle: theme.textTheme.bodyMedium!
                                          .copyWith(color: Colors.white),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 30, vertical: 15),
                                    ),
                                    onPressed: isEmptyResum
                                        ? null
                                        : () async {
                                            if (jobseeker.resume.isEmpty) {
                                              return;
                                            }
                                            final url = jobseeker.resume[0].url;
                                            final fileName =
                                                '${jobseeker.firstName}_${jobseeker.lastName}_${jobseeker.id}_resume.pdf';
                                            await _downloadResume(
                                                context, url, fileName);
                                          },
                                    child: Text('Tải CV'),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                    ),
                    child: DefaultTabController(
                      length: 3,
                      child: Column(
                        children: [
                          const TabBar(
                            tabs: <Widget>[
                              Tab(
                                icon: Icon(Icons.code),
                                text: 'Kỹ năng',
                              ),
                              Tab(
                                icon: Icon(Icons.business_center),
                                text: 'Kinh nghiệm',
                              ),
                              Tab(
                                icon: Icon(Icons.school),
                                text: 'Học vấn',
                              ),
                            ],
                          ),
                          Expanded(
                            child: TabBarView(
                              children: <Widget>[
                                JobseekerSkillsScreen(
                                  techList: techList,
                                ),
                                JobseekerExperiencesScreen(
                                  expList: expList,
                                ),
                                JobseekerEducationsScreen(
                                  eduList: eduList,
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }
}
