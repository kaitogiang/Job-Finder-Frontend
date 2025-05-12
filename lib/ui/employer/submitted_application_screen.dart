import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/application_storage.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:provider/provider.dart';

enum PostStatus {
  pending,
  done,
}

enum PostCardType {
  all,
  approved,
  rejected,
}

class SubmittedApplicationScreen extends StatelessWidget {
  const SubmittedApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    Future<void> applicationStorageFuture =
        context.read<ApplicationManager>().fetchApplicationStorage();
    return FutureBuilder(
        future: applicationStorageFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                elevation: 0,
                centerTitle: false,
                title: const Text(
                  'Hồ sơ đã nhận',
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
                  preferredSize: Size(deviceSize.width, 60),
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      color: theme.indicatorColor,
                    ),
                    child: const TabBar(
                      indicatorSize: TabBarIndicatorSize.tab,
                      tabs: [
                        Tab(
                          child: Text('Đã nhận'),
                        ),
                        Tab(
                          child: Text('Đã chấp nhận'),
                        ),
                        Tab(
                          child: Text('Đã từ chối'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              body: const TabBarView(
                children: [
                  ReceivedApplicationList(),
                  AcceptedApplicationList(),
                  RejectedApplicationList(),
                ],
              ),
            ),
          );
        });
  }
}

//Tab Đã nhận
class ReceivedApplicationList extends StatelessWidget {
  const ReceivedApplicationList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: RefreshIndicator(
        onRefresh: () =>
            context.read<ApplicationManager>().fetchApplicationStorage(),
        child: Consumer<ApplicationManager>(
            builder: (context, applicationManager, child) {
          final applicationStorage = applicationManager.applicationStorage;
          String currentDate = applicationStorage.isNotEmpty
              ? applicationStorage[0].deadline
              : '';
          return ListView(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
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
                        'Nhấp vào bài viết để xem chi tiết về các hồ sơ đã nộp',
                        textAlign: TextAlign.justify,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                itemCount: applicationStorage.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  bool isSameDateLine = applicationStorage[index]
                      .isTheSameMonthAndYear(currentDate);
                  if (!isSameDateLine) {
                    currentDate = applicationStorage[index].deadline;
                  }
                  return Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                        ),
                        child: DateLine(
                          date: applicationStorage[index].deadlineDate,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      PostApplicationCard(
                        applicationStorage: applicationStorage[index],
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class PostApplicationCard extends StatelessWidget {
  const PostApplicationCard({
    super.key,
    required this.applicationStorage,
    this.type = PostCardType.all,
  });

  final ApplicationStorage applicationStorage;
  final PostCardType type;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = applicationStorage.jobposting.title;
    final sentApplications = applicationStorage.applicationNumber;
    final approvedApplication = applicationStorage.passApplicationNumber;
    final rejectedApplication = applicationStorage.failApplicationNumber;
    final consideredApplications =
        applicationStorage.consideredApplicationNumber;
    final isCompleted = applicationStorage.isCompletedApplications;
    String formattedDate =
        DateFormat('dd-MM-yyyy').format(applicationStorage.deadlineDate);
    PostStatus status = isCompleted ? PostStatus.done : PostStatus.pending;
    return Card(
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 15,
          left: 5,
          right: 15,
        ),
        child: GestureDetector(
          onTap: () {
            log('Chuyển hướng tới application detail');
            if (type == PostCardType.all) {
              context.pushNamed('application-detail',
                  extra: applicationStorage.id);
            } else if (type == PostCardType.approved) {
              context.pushNamed('approved-application',
                  extra: applicationStorage.id);
            } else {
              context.pushNamed('rejected-application',
                  extra: applicationStorage.id);
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                title: Text(title),
                subtitle:
                    //! Nếu là loại đang chờ xử lý
                    type == PostCardType.all
                        ? Row(children: [
                            Text('Đã nộp: $sentApplications'),
                            const SizedBox(
                              width: 10,
                            ),
                            Text('Đã duyệt: $consideredApplications'),
                          ])
                        //! Nếu là loại đã chấp nhận
                        : type == PostCardType.approved
                            ? Text('Đã chấp nhận: $approvedApplication')
                            : Text('Đã từ chối: $rejectedApplication'),
                contentPadding: const EdgeInsets.only(
                  left: 10,
                ),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: status == PostStatus.pending
                      ? Icon(
                          Icons.pending_actions,
                          color: theme.primaryColor,
                          size: 25,
                        )
                      : const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 25,
                        ),
                ),
                trailing: Tooltip(
                  message: 'Chi tiết bài đăng',
                  child: IconButton(
                    onPressed: () {
                      log('Chuyển hướng tới trang xem chi tiết bài đăng');
                      context.pushNamed('job-detail',
                          extra: applicationStorage.jobposting);
                    },
                    icon: status == PostStatus.pending
                        ? Icon(
                            Icons.remove_red_eye_outlined,
                            color: theme.primaryColor,
                            weight: 5,
                          )
                        : const Icon(
                            Icons.remove_red_eye_outlined,
                            color: Colors.green,
                            weight: 5,
                          ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  PostApplicationStatus(
                    status: status,
                  ),
                  RichText(
                    text: TextSpan(children: [
                      WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.timer,
                            color: status == PostStatus.pending
                                ? theme.primaryColor
                                : Colors.green,
                          )),
                      const WidgetSpan(
                        child: SizedBox(
                          width: 5,
                        ),
                      ),
                      TextSpan(
                        text: formattedDate,
                        style: theme.textTheme.bodyLarge,
                      )
                    ]),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

}

//? Nút trạng thái
class PostApplicationStatus extends StatelessWidget {
  const PostApplicationStatus({
    super.key,
    required this.status,
  });

  final PostStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String statusText = switch (status) {
      PostStatus.pending => 'Đang xử lý',
      PostStatus.done => 'Đã xong'
    };
    Color? statusColor = switch (status) {
      PostStatus.pending => theme.primaryColor,
      PostStatus.done => Colors.green
    };
    Color? backgroud = switch (status) {
      PostStatus.pending => Colors.blue[50],
      PostStatus.done => Colors.green[50],
    };
    return Container(
      margin: const EdgeInsets.only(
        left: 10,
      ),
      alignment: Alignment.center,
      height: 50,
      width: 100,
      decoration: BoxDecoration(
        color: backgroud,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        statusText,
        style: theme.textTheme.titleMedium!.copyWith(
          color: statusColor,
        ),
      ),
    );
  }
}

class DateLine extends StatelessWidget {
  const DateLine({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    int month = date.month;
    int year = date.year;
    return Row(
      children: [
        const Expanded(child: Divider()),
        const SizedBox(
          width: 10,
        ),
        Text(
          'Tháng $month/$year',
          style: theme.textTheme.titleLarge!.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        const Expanded(child: Divider()),
      ],
    );
  }
}

class AcceptedApplicationList extends StatelessWidget {
  const AcceptedApplicationList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: RefreshIndicator(
        onRefresh: () =>
            context.read<ApplicationManager>().fetchApplicationStorage(),
        child: Consumer<ApplicationManager>(
            builder: (context, applicationManager, child) {
          final applicationStorage = applicationManager.applicationStorage;
          return ListView(
            children: [
              //? Tiêu đề nhắc nhở chức năng
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
                      'Danh sách tất cả những ứng viên được chấp nhận',
                      textAlign: TextAlign.justify,
                    ),
                  ),
                ],
              ),
              //todo Danh sách tất cả các ứng viên được chấp nhận
              const SizedBox(
                height: 10,
              ),
              ListView.builder(
                itemCount: applicationStorage.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      PostApplicationCard(
                        applicationStorage: applicationStorage[index],
                        type: PostCardType.approved,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                    ],
                  );
                },
              ),
            ],
          );
        }),
      ),
    );
  }
}

class RejectedApplicationList extends StatelessWidget {
  const RejectedApplicationList({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Consumer<ApplicationManager>(
          builder: (context, applicationManager, child) {
        final applicationStorage = applicationManager.applicationStorage;
        return ListView(
          children: [
            //? Tiêu đề nhắc nhở chức năng
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
                    'Danh sách tất cả những ứng viên chưa đủ yêu cầu',
                    textAlign: TextAlign.justify,
                  ),
                ),
              ],
            ),
            //todo Danh sách tất cả các ứng viên được chấp nhận
            const SizedBox(
              height: 10,
            ),
            ListView.builder(
              itemCount: applicationStorage.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    PostApplicationCard(
                      applicationStorage: applicationStorage[index],
                      type: PostCardType.rejected,
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                  ],
                );
              },
            ),
          ],
        );
      }),
    );
  }
}
