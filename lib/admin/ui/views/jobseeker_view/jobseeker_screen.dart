import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/jobseeker_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_tables/jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_tables/locked_jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_tables/recent_jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/content_container.dart';
import 'package:job_finder_app/admin/ui/widgets/sort_box.dart';
import 'package:job_finder_app/admin/ui/widgets/overview_card.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';
import 'package:job_finder_app/admin/ui/widgets/search_box.dart';
import 'package:job_finder_app/admin/ui/widgets/table_number_pagination.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:provider/provider.dart';

class JobseekerScreen extends StatefulWidget {
  const JobseekerScreen({super.key});

  @override
  State<JobseekerScreen> createState() => _JobseekerScreenState();
}

class _JobseekerScreenState extends State<JobseekerScreen>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, void Function()> _sortOptions = {};
  final ValueNotifier<int> _selectedSortOption = ValueNotifier(0);
  final ValueNotifier<List<Jobseeker>> _jobseekers = ValueNotifier([]);
  final ValueNotifier<List<Jobseeker>> _recentJobseekers = ValueNotifier([]);
  final ValueNotifier<List<Jobseeker>> _lockedJobseekers = ValueNotifier([]);

  int _currentPage =
      1; //Lưu trữ lại trang hiển tại của bảng tổng danh sách jobseeker

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadAllJobseekers();
      // _loadFirstTablePage();
      _sortOptions.addAll({
        'Mặc định': () {
          Utils.logMessage('Mặc định');
          _selectedSortOption.value = 0;
          context.read<JobseekerListManager>().sortJobseekers(0);
          _jobseekers.value =
              context.read<JobseekerListManager>().filteredJobseekers;
        },
        'Theo tỉnh/thành phố': () {
          Utils.logMessage('Theo tỉnh/thành phố');
          _selectedSortOption.value = 1;
          context.read<JobseekerListManager>().sortJobseekers(1);
          _jobseekers.value =
              context.read<JobseekerListManager>().filteredJobseekers;
        },
        'Theo bảng chữ cái': () {
          Utils.logMessage('Theo bảng chữ cái');
          _selectedSortOption.value = 2;
          context.read<JobseekerListManager>().sortJobseekers(2);
          _jobseekers.value =
              context.read<JobseekerListManager>().filteredJobseekers;
        },
        'Theo ngày đăng ký': () {
          Utils.logMessage('Theo ngày đăng ký');
          _selectedSortOption.value = 3;
        },
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    Utils.logMessage('Joseker Screen dispose');
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    Utils.logMessage('Jobseeker Screen didChangeDependencies');
  }

  // void _loadFirstTablePage() {
  //   //cần đổi lại cách lấy dữ liệu từ manager
  //   _jobseekers.value =
  //       context.read<JobseekerListManager>().getJobseekerByPage(1, 5);
  //   _recentJobseekers.value =
  //       context.read<JobseekerListManager>().getJobseekerByPage(1, 5);
  //   _lockedJobseekers.value =
  //       context.read<JobseekerListManager>().getJobseekerByPage(1, 5);
  // }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final jobseekerManager = context.read<JobseekerListManager>();
    Utils.logMessage('Jobseeker screen build');
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
          child: FutureBuilder(
              future: jobseekerManager.getAllJobseekers(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                //Khởi tạo dữ liệu cho các bảng
                _jobseekers.value = jobseekerManager.getJobseekers();

                return ListView(
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
                                Selector<JobseekerListManager, int>(
                                    selector: (context, jobseekerManager) =>
                                        jobseekerManager.getJobseekersCount,
                                    builder: (context, totalJobseeker, child) {
                                      return OverviewCard(
                                        title: 'Tổng số ứng viên đăng ký',
                                        value: totalJobseeker.toString(),
                                        imagePath:
                                            'assets/images/jobseeker.png',
                                      );
                                    }),
                                Selector<JobseekerListManager, int>(
                                    selector: (context, jobseekerManager) =>
                                        jobseekerManager
                                            .getRecentJobseekersCount,
                                    builder: (context, recentJobseeker, child) {
                                      return OverviewCard(
                                        title: 'Tổng số đăng ký gần đây',
                                        value: recentJobseeker.toString(),
                                        imagePath:
                                            'assets/images/recently-date.png',
                                      );
                                    }),
                                Selector<JobseekerListManager, int>(
                                    selector: (context, jobseekerManager) =>
                                        jobseekerManager.activeJobseekersCount,
                                    builder: (context, activeJobseeker, child) {
                                      return OverviewCard(
                                        title: 'Tài khoản hoạt động',
                                        value: activeJobseeker.toString(),
                                        imagePath:
                                            'assets/images/verified-user.png',
                                      );
                                    }),
                                Selector<JobseekerListManager, int>(
                                    selector: (context, jobseekerManager) =>
                                        jobseekerManager
                                            .getLockedJobseekersCount,
                                    builder: (context, lockedJobseeker, child) {
                                      return OverviewCard(
                                        title: 'Tài khoản bị khóa',
                                        value: lockedJobseeker.toString(),
                                        imagePath:
                                            'assets/images/locked-user.png',
                                      );
                                    }),
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
                            //Hiển thị tiêu đề và chế độ sắp xếp đã chọn
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
                                  'Sắp xếp theo: ',
                                  style: textTheme.bodyMedium!.copyWith(
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                ValueListenableBuilder(
                                    valueListenable: _selectedSortOption,
                                    builder: (context, selectedIndex, child) {
                                      return Chip(
                                        label: Text(_sortOptions.keys
                                            .elementAt(selectedIndex)),
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          side: BorderSide(
                                            color: Colors.green.shade400,
                                          ),
                                        ),
                                        padding: EdgeInsets.only(
                                            left: 10, right: 10),
                                        backgroundColor: Colors.green.shade400,
                                        labelStyle: textTheme.bodyMedium!
                                            .copyWith(color: Colors.white),
                                      );
                                    }),
                              ],
                            ),
                            //Hiển thị box chọn chế độ sắp xếp và thanh tìm kiếm
                            Row(
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: _selectedSortOption,
                                    builder: (context, value, child) {
                                      return SortBox(
                                        sortOptions: _sortOptions,
                                        selectedIndex: value,
                                      );
                                    }),
                                const SizedBox(width: 10),
                                SearchBox(
                                  hintText: 'Tìm kiếm ứng viên',
                                  prefixIcon: Icons.search,
                                  controller: _searchController,
                                  onChanged: (searchText) {
                                    if (searchText.isEmpty) {
                                      jobseekerManager.resetSearch();
                                    } else {
                                      jobseekerManager
                                          .searchJobseeker(searchText);
                                    }
                                    //Gán _jobseekers lại để truyền dữ liệu cho bảng
                                    //Nếu mà người dùng xóa bỏ dữ liệu nhập thì, lệnh bên dưới
                                    //Sẽ nạp lại toàn bộ dữ liệu ban đầu. Còn nếu có nhập
                                    //Thì danh sách filteredJobseekers sẽ chỉ chứa các phần tử
                                    //thỏa mãn điều kiện tìm kiếm
                                    _jobseekers.value =
                                        jobseekerManager.filteredJobseekers;
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      //Hiển thị bảng chứa danh sách ứng viên
                      child: Consumer<JobseekerListManager>(
                          builder: (context, jobseekerManager, child) {
                        // _jobseekers.value = jobseekerManager.getJobseekers();

                        //Lấy tổng số nhóm có thể hiển thị trong number pagination
                        final totalGroupCount =
                            jobseekerManager.getTotalGroupCount(
                                5, jobseekerManager.filteredJobseekers);
                        Utils.logMessage('Total group count: $totalGroupCount');
                        //Thiết lập số lượng tab hiển thị trong number pagination
                        final visiblePagesCount = totalGroupCount == 0
                            ? 1
                            : totalGroupCount < 5 && totalGroupCount > 0
                                ? totalGroupCount
                                : 5;
                        //Thiết lập số lượng tối đa các tab hiển thị trong number pagination
                        final totalPages =
                            totalGroupCount == 0 ? 1 : totalGroupCount;

                        return Column(
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
                                currentPage: _currentPage,
                                onPageChanged: (value) {
                                  _currentPage = value;

                                  Utils.logMessage('Chuyển đến trang $value');
                                  //Nạp 5 phần tử tiếp theo trong bảng
                                  _jobseekers.value =
                                      jobseekerManager.getJobseekerByPage(value,
                                          5, jobseekerManager.jobseekerList);
                                },
                                visiblePagesCount: visiblePagesCount,
                                totalPages: totalPages,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Flexible(
                          flex: 1,
                          child: Consumer<JobseekerListManager>(
                              builder: (context, jobseekerManager, child) {
                            _recentJobseekers.value =
                                jobseekerManager.recentJobseekersList;
                            //Lấy tổng số nhóm có thể hiển thị trong number pagination
                            final totalGroupCount =
                                jobseekerManager.getTotalGroupCount(
                                    5, jobseekerManager.recentJobseekersList);
                            //Thiết lập số lượng tab hiển thị trong number pagination
                            final visiblePagesCount = totalGroupCount == 0
                                ? 1
                                : totalGroupCount < 5 && totalGroupCount > 0
                                    ? totalGroupCount
                                    : 5;
                            //Thiết lập số lượng tối đa các tab hiển thị trong number pagination
                            final totalPages =
                                totalGroupCount == 0 ? 1 : totalGroupCount;
                            return ContentContainer(
                              header: Text(
                                'Ứng viên đăng ký gần đây (${jobseekerManager.getRecentJobseekersCount})',
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
                                        Utils.logMessage(
                                            'Chuyển đến trang $value');
                                        //Nạp 5 phần tử tiếp theo trong bảng
                                        _recentJobseekers.value =
                                            jobseekerManager.getJobseekerByPage(
                                                value,
                                                5,
                                                jobseekerManager
                                                    .recentJobseekersList);
                                      },
                                      visiblePagesCount: visiblePagesCount,
                                      totalPages: totalPages,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          flex: 1,
                          child: Consumer<JobseekerListManager>(
                              builder: (context, jobseekerManager, child) {
                            _lockedJobseekers.value =
                                jobseekerManager.lockedJobseekersList;
                            //Lấy tổng số nhóm có thể hiển thị trong number pagination
                            final totalGroupCount =
                                jobseekerManager.getTotalGroupCount(
                                    5, jobseekerManager.lockedJobseekersList);
                            //Thiết lập số lượng tab hiển thị trong number pagination
                            final visiblePagesCount = totalGroupCount == 0
                                ? 1
                                : totalGroupCount < 5 && totalGroupCount > 0
                                    ? totalGroupCount
                                    : 5;
                            //Thiết lập số lượng tối đa các tab hiển thị trong number pagination
                            final totalPages =
                                totalGroupCount == 0 ? 1 : totalGroupCount;
                            return ContentContainer(
                              header: Text(
                                'Danh sách ứng viên bị khóa (${jobseekerManager.getLockedJobseekersCount})',
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
                                        return LockedJobseekerListTable(
                                          jobseekers: jobseekers,
                                        );
                                      }),
                                  const SizedBox(height: 10),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: TableNumberPagination(
                                      onPageChanged: (value) {
                                        Utils.logMessage(
                                            'Chuyển đến trang $value');
                                        //Nạp 5 phần tử tiếp theo trong bảng
                                        _lockedJobseekers.value =
                                            jobseekerManager.getJobseekerByPage(
                                                value,
                                                5,
                                                jobseekerManager
                                                    .lockedJobseekersList);
                                      },
                                      visiblePagesCount: visiblePagesCount,
                                      totalPages: totalPages,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                );
              }),
        ),
      ],
    );
  }
}
