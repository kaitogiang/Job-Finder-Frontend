import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/admin/ui/manager/jobposting_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/application_view/application_detail_tabs/approved_application_screen.dart';
import 'package:job_finder_app/admin/ui/views/application_view/application_detail_tabs/received_application_screen.dart';
import 'package:job_finder_app/admin/ui/views/application_view/application_detail_tabs/rejected_application_screen.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/jobposting_detail_tabs/jobposting_detail_info.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/jobposting_detail_tabs/jobposting_general_info.dart';
import 'package:job_finder_app/models/application_storage.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/ui/shared/job_card.dart';
import 'package:provider/provider.dart';

class ApplicationDetailScreen extends StatefulWidget {
  const ApplicationDetailScreen({
    super.key,
    required this.applicationFuture,
  });

  final Future<ApplicationStorage?> applicationFuture;

  @override
  State<ApplicationDetailScreen> createState() =>
      _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen>
    with TickerProviderStateMixin {
  final ValueNotifier<double> _expandedHeight = ValueNotifier(230.0);
  // late Future<List<dynamic>> _combinedFuture;
  late Future<Jobposting?> _combinedFuture;
  late TabController _tabController;
  int currentPageIndex = 0;
  final _parentController = ScrollController();
  //Lưu trữ tab active hiện tại 0 -> 2
  final ValueNotifier<int> _currentActiveTab = ValueNotifier(0);
  /* 
   * NOTE KHI SỬ DỤNG NestedScrollView kết hợp với TabBarView
   * NestedSrollView cho phép liên kết giữa outer scroll và inner scroll, nó có
   * tác dụng tạo sự liên kết giữa hai scrollable widget, làm cho việc cuộn tiếp tục
   * mượt mà, khi widget cha cuộn xong thì chuyển sang widget con bên trong.
   * Nhưng một NestedScrollView chỉ truyền scrollController cho một scrollable widget thôi.
   * Nên khi dùng TabBarView mà mỗi TabView bên trong đều là các scrollable widget thì
   * sẽ phát sinh ra lỗi "The provided ScrollController is attached to more than one ScrollPosition."
   * Lỗi này xảy ra là do có nhiều scrollable widget sử dụng chung một scrollController 
   * của outer scroll. Điều này ngược với qui định của NestedScrollView là chỉ duy nhất
   * một inner scroll sử dụng scrollController cha. Tuy nhiên nó vẫn hoạt động được.
   * 
   * Để khắc phục lỗi này thì cần phải xác định scrollable widget nào ở các tabview
   * sẽ là primary. Theo như code của tôi thì mỗi page sử dụng ListView, và nó có
   * thuộc tính primary, cần sử dụng một biến để lưu lại trang nào đang active và 
   * cập nhật lại trạng thái của thuộc tính primary ở mỗi ListView trong các trang
   * là true or false. Đây là giải pháp mà tôi đã nghiên cứu ra và có vẻ nó hiệu quả.
   *
   */
  @override
  void initState() {
    super.initState();
    // _combinedFuture =
    //     Future.wait([widget.jobpostingFuture, widget.favoriteCountFuture]);
    _combinedFuture = context
        .read<JobpostingListManager>()
        .getJobpostingById('670e2f0cc0145fa0e11649fa');
    _tabController = TabController(length: 3, vsync: this);
    _parentController.addListener(() {
      Utils.logMessage('Parent Scroll Position: ${_parentController.offset}');
    });
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
    _parentController.dispose();
  }

  void _handlePageChanged(int currentIndex) {
    _tabController.index = currentIndex;
    currentPageIndex = currentIndex;
    _tabController.animateTo(
      currentIndex,
      duration: Duration(milliseconds: 300),
      curve: Curves.linear,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final basicInfoTitle = theme.textTheme.bodyMedium!
        .copyWith(fontWeight: FontWeight.bold, color: Colors.black54);

    return FutureBuilder(
        future: widget.applicationFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              width: 700,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          final applicationStorage = snapshot.data!;
          final jobposting = applicationStorage.jobposting;
          //Lấy danh sách tất cả các application, đã chấp nhận, đã từ chối
          final receivedApplications =
              applicationStorage.applications.where((application) {
            return application.status == 0;
          }).toList();
          final approvedApplications =
              applicationStorage.applications.where((application) {
            return application.status == 1;
          }).toList();
          final rejectedApplications =
              applicationStorage.applications.where((application) {
            return application.status == 2;
          }).toList();
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
                // controller: _parentController,
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
                  length: 3,
                  child: Column(
                    children: [
                      _buildTabBar(theme, _tabController, _currentActiveTab),
                      Expanded(
                        child: TabBarView(
                          // controller: _tabController,
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
                              child: ValueListenableBuilder(
                                  valueListenable: _currentActiveTab,
                                  builder: (context, currentIndex, child) {
                                    return ReceivedApplicationScreen(
                                      parentController: _parentController,
                                      isActive: currentIndex == 0,
                                      receivedApplications:
                                          receivedApplications,
                                    );
                                  }),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  )),
                              child: ValueListenableBuilder(
                                  valueListenable: _currentActiveTab,
                                  builder: (context, currentIndex, child) {
                                    return ApprovedApplicationScreen(
                                      parentController: _parentController,
                                      isActive: currentIndex == 1,
                                      approvedApplications:
                                          approvedApplications,
                                    );
                                  }),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  )),
                              child: ValueListenableBuilder(
                                  valueListenable: _currentActiveTab,
                                  builder: (context, currentIndex, child) {
                                    return RejectedApplicationScreen(
                                      parentController: _parentController,
                                      isActive: currentIndex == 2,
                                      rejectedApplications:
                                          rejectedApplications,
                                    );
                                  }),
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

  Container _buildTabBar(ThemeData theme, TabController tabController,
      ValueNotifier<int> currentTab) {
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
      child: TabBar(
        // controller: tabController,
        labelPadding: EdgeInsets.only(top: 0),
        isScrollable: true,
        tabAlignment: TabAlignment.start,
        onTap: (currentIndex) {
          // Utils.logMessage('TabIndex: $currentIndex');
          // _handlePageChanged(currentIndex);
          currentTab.value = currentIndex;
        },
        tabs: <Widget>[
          Tab(
            icon: Icon(Icons.assignment_turned_in),
            // text: 'Thông tin chung',
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Đã nhận'),
            ),
          ),
          Tab(
            icon: Icon(Icons.check_circle),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Đã chấp nhận'),
            ),
          ),
          Tab(
            icon: Icon(Icons.cancel),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Text('Đã từ chối'),
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
    required this.theme,
    required this.isActive,
  });

  final String createdTime;
  final Jobposting jobposting;
  final TextStyle basicInfoTitle;
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
                    // Container(
                    //   alignment: Alignment.centerRight,
                    //   child: Chip(
                    //     avatar: Icon(
                    //       Icons.favorite,
                    //       color: Colors.redAccent,
                    //     ),
                    //     label: Text(
                    //       '$favoriteCount',
                    //       style: theme.textTheme.bodyMedium!.copyWith(
                    //         color: Colors.redAccent,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //     shape: RoundedRectangleBorder(
                    //       borderRadius: BorderRadius.circular(10),
                    //       side: BorderSide(
                    //         color: Colors.redAccent,
                    //       ),
                    //     ),
                    //     labelPadding:
                    //         const EdgeInsets.symmetric(horizontal: 10),
                    //   ),
                    // ),
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
