import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/jobseeker_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/recent_jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/content_container.dart';
import 'package:job_finder_app/admin/ui/widgets/filter_box.dart';
import 'package:job_finder_app/admin/ui/widgets/overview_card.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';
import 'package:job_finder_app/admin/ui/widgets/search_box.dart';
import 'package:job_finder_app/admin/ui/widgets/table_number_pagination.dart';
import 'package:provider/provider.dart';

class JobseekerScreen extends StatefulWidget {
  const JobseekerScreen({super.key});

  @override
  State<JobseekerScreen> createState() => _JobseekerScreenState();
}

class _JobseekerScreenState extends State<JobseekerScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, void Function()> _filterOptions = {};
  final ValueNotifier<int> _selectedFilterOption = ValueNotifier(0);
  final ValueNotifier<List<Map<String, dynamic>>> _jobseekers =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> _recentJobseekers =
      ValueNotifier([]);
  final ValueNotifier<List<Map<String, dynamic>>> _lockedJobseekers =
      ValueNotifier([]);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _filterOptions.addAll({
      'Tất cả': () {
        Utils.logMessage('Tất cả');
        _selectedFilterOption.value = 0;
      },
      'Theo tỉnh/thành phố': () {
        Utils.logMessage('Theo tỉnh/thành phố');
        _selectedFilterOption.value = 1;
      },
      'Theo bảng chữ cái': () {
        Utils.logMessage('Theo bảng chữ cái');
        _selectedFilterOption.value = 2;
      },
      'Theo ngày đăng ký': () {
        Utils.logMessage('Theo ngày đăng ký');
        _selectedFilterOption.value = 3;
      },
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFirstTablePage();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadFirstTablePage() {
    //cần đổi lại cách lấy dữ liệu từ manager
    _jobseekers.value =
        context.read<JobseekerListManager>().getJobseekerByPage(1, 5);
    _recentJobseekers.value =
        context.read<JobseekerListManager>().getJobseekerByPage(1, 5);
    _lockedJobseekers.value =
        context.read<JobseekerListManager>().getJobseekerByPage(1, 5);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final jobseekerManager = context.read<JobseekerListManager>();
    //Lấy tổng số nhóm có thể hiển thị trong number pagination
    final totalGroupCount = jobseekerManager.getTotalGroupCount(5);
    //Thiết lập số lượng tab hiển thị trong number pagination
    final visiblePagesCount = totalGroupCount == 0
        ? 1
        : totalGroupCount < 5 && totalGroupCount > 0
            ? totalGroupCount
            : 5;
    //Thiết lập số lượng tối đa các tab hiển thị trong number pagination
    final totalPages = totalGroupCount == 0 ? 1 : totalGroupCount;
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Hiển thị tiêu đề của navigation item
        ScreenHeader(title: 'Ứng viên'),
        const Divider(
          thickness: 2,
        ),
        Expanded(
          child: ListView(
            children: [
              //Phần hiển thị thông tin chung
              ContentContainer(
                header: Text(
                  'Thông tin chung',
                  style: textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                child: Scrollbar(
                  controller: _scrollController,
                  thumbVisibility: true,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    controller: _scrollController,
                    child: Padding(
                      padding: const EdgeInsets.only(
                        bottom: 15,
                      ),
                      //Hiển thị các thẻ tổng quan về jobseeker
                      child: Row(
                        children: [
                          OverviewCard(
                            title: 'Tổng số ứng viên đăng ký',
                            value: '1,000',
                            imagePath: 'assets/images/jobseeker.png',
                          ),
                          OverviewCard(
                            title: 'Tổng số đăng ký gần đây',
                            value: '100',
                            imagePath: 'assets/images/recently-date.png',
                          ),
                          OverviewCard(
                            title: 'Tài khoản hoạt động',
                            value: '950',
                            imagePath: 'assets/images/verified-user.png',
                          ),
                          OverviewCard(
                            title: 'Tài khoản bị khóa',
                            value: '50',
                            imagePath: 'assets/images/locked-user.png',
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              //Hiển thị bảng chứa đựng danh sách ứng viên đã đăng ký tài khoản
              ContentContainer(
                header: Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      //Hiển thị tiêu đề và chế độ lọc đã chọn
                      Row(
                        children: [
                          Text(
                            'Danh sách tất cả ứng viên (${jobseekerManager.getJobseekersCount})',
                            style: textTheme.titleMedium!.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Chế độ lọc: ',
                            style: textTheme.bodyMedium!.copyWith(
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(width: 5),
                          ValueListenableBuilder(
                              valueListenable: _selectedFilterOption,
                              builder: (context, selectedIndex, child) {
                                return Chip(
                                  label: Text(_filterOptions.keys
                                      .elementAt(selectedIndex)),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    side: BorderSide(
                                      color: Colors.green.shade400,
                                    ),
                                  ),
                                  padding: EdgeInsets.only(left: 10, right: 10),
                                  backgroundColor: Colors.green.shade400,
                                  labelStyle: textTheme.bodyMedium!
                                      .copyWith(color: Colors.white),
                                );
                              }),
                        ],
                      ),
                      //Hiển thị box chọn chế độ lọc và thanh tìm kiếm
                      Row(
                        children: [
                          ValueListenableBuilder(
                              valueListenable: _selectedFilterOption,
                              builder: (context, value, child) {
                                return FilterBox(
                                  filterOptions: _filterOptions,
                                  selectedIndex: value,
                                );
                              }),
                          const SizedBox(width: 10),
                          SearchBox(
                            hintText: 'Tìm kiếm ứng viên',
                            prefixIcon: Icons.search,
                            controller: _searchController,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //Hiển thị bảng chứa danh sách ứng viên
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ValueListenableBuilder(
                        valueListenable: _jobseekers,
                        builder: (context, jobseekers, child) {
                          return JobseekerListTable(
                            jobseekers: jobseekers,
                          );
                        }),
                    const SizedBox(height: 10),
                    //Hiển thị number pagination cho phép admin chuyển đến các dữ liệu tiếp theo trong bảng
                    Align(
                      alignment: Alignment.centerRight,
                      //Sử dụng IntrinsicWidth để làm cho width của Container phụ thuộc vào width của con nó
                      child: TableNumberPagination(
                        onPageChanged: (value) {
                          Utils.logMessage('Chuyển đến trang $value');
                          //Nạp 5 phần tử tiếp theo trong bảng
                          _jobseekers.value =
                              jobseekerManager.getJobseekerByPage(value, 5);
                        },
                        visiblePagesCount: visiblePagesCount,
                        totalPages: totalPages,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    flex: 1,
                    child: ContentContainer(
                      header: Text(
                        'Ứng viên đăng ký gần đây (25)',
                        style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      child: Column(
                        children: [
                          ValueListenableBuilder(
                              valueListenable: _recentJobseekers,
                              builder: (context, jobseekers, child) {
                                return RecentJobseekerListTable(
                                  jobseekers: jobseekers,
                                );
                              }),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TableNumberPagination(
                              onPageChanged: (value) {
                                Utils.logMessage('Chuyển đến trang $value');
                                //Nạp 5 phần tử tiếp theo trong bảng
                                _recentJobseekers.value = jobseekerManager
                                    .getJobseekerByPage(value, 5);
                              },
                              visiblePagesCount: visiblePagesCount,
                              totalPages: totalPages,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Flexible(
                    flex: 1,
                    child: ContentContainer(
                      header: Text(
                        'Danh sách ứng viên bị khóa (30)',
                        style: textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      child: Column(
                        children: [
                          ValueListenableBuilder(
                              valueListenable: _lockedJobseekers,
                              builder: (context, jobseekers, child) {
                                return RecentJobseekerListTable(
                                  jobseekers: jobseekers,
                                );
                              }),
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TableNumberPagination(
                              onPageChanged: (value) {
                                Utils.logMessage('Chuyển đến trang $value');
                                //Nạp 5 phần tử tiếp theo trong bảng
                                _lockedJobseekers.value = jobseekerManager
                                    .getJobseekerByPage(value, 5);
                              },
                              visiblePagesCount: visiblePagesCount,
                              totalPages: totalPages,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
