import 'dart:developer';

import 'package:flutter/material.dart';

import '../shared/modal_bottom_sheet.dart';

class SubmittedApplicationScreen extends StatelessWidget {
  const SubmittedApplicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
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
        body: TabBarView(
          children: [
            ReceivedApplicationList(),
            const Center(
              child: Text('Danh sách đã chấp nhận'),
            ),
            const Center(
              child: Text('Danh sách đã từ chối'),
            ),
          ],
        ),
      ),
    );
  }
}

class ReceivedApplicationList extends StatelessWidget {
  const ReceivedApplicationList({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
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
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5,
            ),
            child: DateLine(
              date: DateTime.now(),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          const PostApplicationCard(
            status: ApplicationStatus.pending,
          )
        ],
      ),
    );
  }
}

class PostApplicationCard extends StatelessWidget {
  const PostApplicationCard({
    super.key,
    required this.status,
  });

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 5,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.only(
          bottom: 15,
          left: 5,
          right: 15,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              title: const Text('Seneior Front End Developer'),
              subtitle: Row(children: [
                const Text('Đã nộp: 25'),
                const SizedBox(
                  width: 10,
                ),
                const Text('Đã duyệt: 10'),
              ]),
              contentPadding: const EdgeInsets.only(
                left: 10,
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: status == ApplicationStatus.pending
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
              trailing: IconButton(
                onPressed: () {
                  log('Chuyển hướng tới trang xem chi tiết bài đăng');
                },
                icon: status == ApplicationStatus.pending
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
                          color: status == ApplicationStatus.pending
                              ? theme.primaryColor
                              : Colors.green,
                        )),
                    const WidgetSpan(
                      child: SizedBox(
                        width: 5,
                      ),
                    ),
                    TextSpan(
                      text: '30-6-2024',
                      style: theme.textTheme.bodyLarge,
                    )
                  ]),
                ),
              ],
            )
          ],
        ),
      ),
    );
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
          // ListTile(
          //   title: Text(
          //     'Xóa bỏ',
          //     style: Theme.of(context).textTheme.titleMedium,
          //   ),
          //   leading: Icon(Icons.delete),
          //   onTap: onDelete,
          // ),
          // const Divider(),
          ListTile(
            title: Text(
              'Xem bài đăng',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            leading: const Icon(Icons.preview),
            onTap: onEdit,
          ),
        ],
      ),
    );
  }
}

enum ApplicationStatus {
  pending,
  done,
}

//? Nút trạng thái
class PostApplicationStatus extends StatelessWidget {
  const PostApplicationStatus({
    super.key,
    required this.status,
  });

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    String statusText = switch (status) {
      ApplicationStatus.pending => 'Đang xử lý',
      ApplicationStatus.done => 'Đã xong'
    };
    Color? statusColor = switch (status) {
      ApplicationStatus.pending => theme.primaryColor,
      ApplicationStatus.done => Colors.green
    };
    Color? backgroud = switch (status) {
      ApplicationStatus.pending => Colors.blue[50],
      ApplicationStatus.done => Colors.green[50],
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
