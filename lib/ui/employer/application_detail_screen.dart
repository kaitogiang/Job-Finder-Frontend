import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:provider/provider.dart';

import '../shared/enums.dart';
import 'widgets/applicant_card.dart';

class ApplicationDetailScreen extends StatelessWidget {
  const ApplicationDetailScreen(
      {super.key, required this.applicationStorageId});

  final String applicationStorageId;

  @override
  Widget build(BuildContext context) {
    final applicationStorage = context
        .watch<ApplicationManager>()
        .applicationStorageById(applicationStorageId);
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final applicationList = applicationStorage.applications;
    context.read<ApplicationManager>().sortApplicationsList(applicationList);
    final jobposting = applicationStorage.jobposting;
    //todo khởi tạo dữ liệu
    final title = jobposting.title;
    final deadline =
        DateFormat("dd-MM-yyyy").format(applicationStorage.deadlineDate);
    final recievedNumber = applicationStorage.applicationNumber;
    final passNumber = applicationStorage.passApplicationNumber;
    final failNumber = applicationStorage.failApplicationNumber;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Danh sách ứng viên',
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
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            //? Hiển thị tên bài viết và nút để xem chi tiết
            Card(
              elevation: 5,
              color: theme.indicatorColor,
              child: ListTile(
                title: Text(
                  title,
                  maxLines: 2,
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
            const SizedBox(
              height: 10,
            ),
            //? Hiển thị số lượng đã nhận, đã chấp nhận và đã từ chối
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'Đã nhận',
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.primaryColor,
                          ),
                        ),
                        Text(
                          '$recievedNumber',
                          style: textTheme.bodyLarge!.copyWith(
                            color: theme.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(10)),
                    child: Column(
                      children: [
                        Text(
                          'Đã chấp nhận',
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          '$passNumber',
                          style: textTheme.bodyLarge!.copyWith(
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  width: 6,
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Đã từ chối',
                          style: textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                        Text(
                          '$failNumber',
                          style: textTheme.bodyLarge!.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            //? Hiển thị danh sách ứng viên
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => context
                    .read<ApplicationManager>()
                    .fetchApplicationStorage(),
                child: ListView.builder(
                  itemCount: applicationList.length,
                  itemBuilder: (context, index) {
                    final mapStatus = {
                      0: ApplicationStatus.pending,
                      1: ApplicationStatus.accepted,
                      2: ApplicationStatus.rejected,
                    };
                    ApplicationStatus status =
                        mapStatus[applicationList[index].status]!;
                    return Column(
                      children: [
                        ApplicantCard(
                          status: status,
                          application: applicationList[index],
                          jobpostingId: applicationStorage.jobposting.id,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
