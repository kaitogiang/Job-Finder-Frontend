import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/admin/ui/manager/jobposting_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/jobposting_detail_tabs/jobposting_detail_info.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/jobposting_detail_tabs/jobposting_general_info.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';
import 'package:provider/provider.dart';

class JobpostingDetailScreen extends StatefulWidget {
  const JobpostingDetailScreen({
    super.key,
    required this.jobpostingFuture,
    required this.favoriteCountFuture,
  });

  final Future<Jobposting?> jobpostingFuture;
  final Future<int> favoriteCountFuture;

  @override
  State<JobpostingDetailScreen> createState() => _JobpostingDetailScreenState();
}

class _JobpostingDetailScreenState extends State<JobpostingDetailScreen> {
  final ValueNotifier<double> _expandedHeight = ValueNotifier(230.0);
  late Future<List<dynamic>> _combinedFuture;
  @override
  void initState() {
    super.initState();
    _combinedFuture =
        Future.wait([widget.jobpostingFuture, widget.favoriteCountFuture]);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basicInfoTitle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black54);

    return FutureBuilder(
        future: _combinedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 700,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final jobposting = snapshot.data![0];
          final favoriteCount = snapshot.data![1];
          final deadline = DateTime.parse(jobposting.deadline);
          final createdDate = DateTime.parse(jobposting.createdAt);
          final currentDate = DateTime.now();
          bool isActive = deadline.isAfter(currentDate);
          final duration = currentDate.difference(createdDate);
          String createdTime = '';
          if (duration.inSeconds < 60) {
            createdTime = 'Đã đăng ${duration.inSeconds} giây trước';
          } else if (duration.inMinutes < 60) {
            createdTime = 'Đã đăng ${duration.inMinutes} phút trước';
          } else if (duration.inHours < 24) {
            createdTime = 'Đã đăng vào ${duration.inHours} giờ trước';
          } else {
            createdTime = 'Đã đăng vào ${duration.inDays} ngày trước';
          }
          return SizedBox(
              width: 700,
              child: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) => [
                  ValueListenableBuilder(
                      valueListenable: _expandedHeight,
                      builder: (context, expandedHeight, child) {
                        return SliverAppBar(
                          automaticallyImplyLeading: false,
                          expandedHeight: 250, //230 default
                          floating: false,
                          pinned: false,
                          toolbarHeight: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          title: Padding(
                            padding: const EdgeInsets.only(left: 0, right: 30),
                            //? Hiển thị tên công ty ở phần giữa AppBar
                            child: SizedBox.fromSize(),
                          ),
                          centerTitle: true,
                          // backgroundColor: const Color.fromRGBO(39, 107, 152, 1),
                          flexibleSpace: FlexibleSpaceBar(
                            expandedTitleScale: 1,
                            background: JobpostingBasicCard(
                              createdTime: createdTime,
                              jobposting: jobposting,
                              basicInfoTitle: basicInfoTitle,
                              favoriteCount: favoriteCount,
                              theme: theme,
                              isActive: isActive,
                            ),
                            titlePadding: EdgeInsets.zero,
                          ),
                        );
                      }),
                  SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ],
                body: DefaultTabController(
                  length: 2,
                  child: Column(
                    children: [
                      _buildTabBar(theme),
                      Expanded(
                        child: TabBarView(
                          children: <Widget>[
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(10),
                                  bottomRight: Radius.circular(10),
                                ),
                              ),
                              padding: EdgeInsets.all(10),
                              child: JobpostingGeneralInfo(
                                jobposting: jobposting,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  )),
                              child: JobpostingDetailInfo(
                                jobposting: jobposting,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ));
        });
  }

  Container _buildTabBar(ThemeData theme) {
    return Container(
      height: 70,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: theme.indicatorColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: const TabBar(
        labelPadding: EdgeInsets.only(top: 0),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        tabs: <Widget>[
          Tab(
            icon: Icon(Icons.info),
            // text: 'Thông tin chung',
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Thông tin chung'),
            ),
          ),
          Tab(
            icon: Icon(Icons.open_in_new),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Thông tin chi tiết'),
            ),
          ),
        ],
      ),
    );
  }
}

class JobpostingBasicCard extends StatelessWidget {
  const JobpostingBasicCard({
    super.key,
    required this.createdTime,
    required this.jobposting,
    required this.basicInfoTitle,
    required this.favoriteCount,
    required this.theme,
    required this.isActive,
  });

  final String createdTime;
  final Jobposting jobposting;
  final TextStyle basicInfoTitle;
  final int favoriteCount;
  final ThemeData theme;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        minHeight: 200,
      ),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
            )
          ]),
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 20,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    image: DecorationImage(
                        image: NetworkImage(jobposting.company!.avatarLink))),
              ),
              const SizedBox(
                height: 10,
              ),
              RichText(
                text: TextSpan(children: [
                  WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: Icon(
                        Icons.circle,
                        size: 10,
                        color: Colors.green,
                      )),
                  const WidgetSpan(
                      child: SizedBox(
                    width: 10,
                  )),
                  TextSpan(text: createdTime, style: basicInfoTitle)
                ]),
              )
            ],
          ),
          const SizedBox(
            width: 20,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  jobposting.title,
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  jobposting.company!.companyName,
                  style: theme.textTheme.titleLarge!.copyWith(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                  softWrap: true,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(
                  height: 5,
                ),
                ExtraLabel(
                  leadingIcon: Icons.location_on,
                  leadingTitle: 'Nơi làm việc',
                  label: jobposting.workLocation,
                ),
                const SizedBox(
                  height: 5,
                ),
                ExtraLabel(
                  leadingIcon: Icons.timelapse,
                  leadingTitle: 'Hạn chót nộp',
                  label: DateFormat('dd/MM/yyyy')
                      .format(DateTime.parse(jobposting.deadline)),
                ),
                const SizedBox(
                  height: 5,
                ),
                ExtraLabel(
                  leadingIcon: Icons.money,
                  leadingTitle: 'Mức lương',
                  label: jobposting.salary,
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 0),
                      child: JobpostingStatusChip(
                        isActive: isActive,
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                      alignment: Alignment.centerRight,
                      child: Chip(
                        avatar: Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                        ),
                        label: Text(
                          '$favoriteCount',
                          style: theme.textTheme.bodyMedium!.copyWith(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: Colors.redAccent,
                          ),
                        ),
                        labelPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    // const SizedBox(
                    //   width: 10,
                    // ),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}

class JobpostingStatusChip extends StatelessWidget {
  const JobpostingStatusChip({
    super.key,
    required this.isActive,
  });

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      label: Text(
        isActive ? 'Còn hạn' : 'Hết hạn',
        style: theme.textTheme.bodyMedium!.copyWith(
          color: isActive ? Colors.green : Colors.red,
          fontWeight: FontWeight.bold,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isActive ? Colors.green : Colors.red,
        ),
      ),
      labelPadding: const EdgeInsets.symmetric(horizontal: 10),
    );
  }
}

class ExtraLabel extends StatelessWidget {
  const ExtraLabel({
    super.key,
    required this.leadingIcon,
    required this.leadingTitle,
    required this.label,
  });
  final IconData leadingIcon;
  final String leadingTitle;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          leadingIcon,
          color: Colors.grey.shade700,
        ),
        Text(
          '$leadingTitle:',
          style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Colors.grey.shade700,
              ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.grey.shade700,
                  // overflow: TextOverflow.ellipsis,
                ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        )
      ],
    );
  }
}
