import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:job_finder_app/ui/employer/widgets/applicant_card.dart';
import 'package:job_finder_app/ui/shared/enums.dart';
import 'package:provider/provider.dart';

class ApprovedApplicationScreen extends StatelessWidget {
  const ApprovedApplicationScreen({
    super.key,
    required this.applicationStorageId,
  });

  final String applicationStorageId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    final textTheme = theme.textTheme;
    final applicationStorage = context
        .watch<ApplicationManager>()
        .getApplicationStorageById(applicationStorageId);
    final approvedApplications = applicationStorage.approvedApplications;
    final jobposting = applicationStorage.jobposting;
    final deadline =
        DateFormat('dd-MM-yyyy').format(applicationStorage.deadlineDate);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Hồ sơ được nhận (${applicationStorage.passApplicationNumber})',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
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
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(90),
          child: //? Hiển thị tên bài viết và nút để xem chi tiết
              Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: Card(
              elevation: 5,
              color: theme.indicatorColor,
              child: ListTile(
                title: Text(
                  jobposting.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleMedium,
                ),
                leading: Icon(
                  Icons.comment_rounded,
                  color: theme.primaryColor,
                ),
                subtitle: RichText(
                  text: TextSpan(children: [
                    const WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.timer,
                        color: Colors.red,
                      ),
                    ),
                    const WidgetSpan(
                        child: SizedBox(
                      width: 7,
                    )),
                    TextSpan(
                      text: deadline,
                      style: textTheme.bodyLarge,
                    )
                  ]),
                ),
                trailing: TextButton(
                  onPressed: () {
                    context.pushNamed('job-detail', extra: jobposting);
                  },
                  child: const Text('Chi tiết'),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(10),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.info,
                color: theme.primaryColor,
              ),
              const SizedBox(
                width: 7,
              ),
              const Expanded(
                child: Text(
                  'Danh sách những ứng viên sẽ được mời phỏng vấn',
                  textAlign: TextAlign.justify,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          approvedApplications.isNotEmpty
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: approvedApplications.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: ApplicantCard(
                        application: approvedApplications[index],
                        isRead: true,
                        status: ApplicationStatus.accepted,
                      ),
                    );
                  },
                )
              : SizedBox(
                  height: deviceSize.height / 2,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/folder.png',
                        width: 200,
                      ),
                      Text(
                        'Hiện tại chưa có ứng viên nào',
                        style: textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}
