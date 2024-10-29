import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/employer_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_account_list_table.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_list_table.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/locked_employer_list_table.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/recent_employer_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/content_container.dart';
import 'package:job_finder_app/admin/ui/widgets/sort_box.dart';
import 'package:job_finder_app/admin/ui/widgets/overview_card.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';
import 'package:job_finder_app/admin/ui/widgets/search_box.dart';
import 'package:job_finder_app/admin/ui/widgets/table_number_pagination.dart';
import 'package:job_finder_app/models/employer.dart';
import 'package:provider/provider.dart';

class EmployerScreen extends StatefulWidget {
  const EmployerScreen({super.key});

  @override
  State<EmployerScreen> createState() => _EmployerScreenState();
}

class _EmployerScreenState extends State<EmployerScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, void Function()> _sortOptions = {};
  final ValueNotifier<int> _selectedSortOption = ValueNotifier(0);
  final ValueNotifier<List<Employer>> _employers = ValueNotifier([]);
  final ValueNotifier<List<Employer>> _recentEmployers = ValueNotifier([]);
  final ValueNotifier<List<Employer>> _lockedEmployers = ValueNotifier([]);

  int _currentPage =
      1; //Lưu trữ lại trang hiển tại của bảng tổng danh sách jobseeker

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // _loadAllJobseekers();
      // _loadFirstTablePage();
    });
    _sortOptions.addAll({
      'Mặc định': () {
        Utils.logMessage('Mặc định');
        _selectedSortOption.value = 0;
        // context.read<JobseekerListManager>().sortJobseekers(0);
        // _jobseekers.value =
        //     context.read<JobseekerListManager>().filteredJobseekers;
      },
      'Theo tỉnh/thành phố': () {
        Utils.logMessage('Theo tỉnh/thành phố');
        _selectedSortOption.value = 1;
        // context.read<JobseekerListManager>().sortJobseekers(1);
        // _jobseekers.value =
        //     context.read<JobseekerListManager>().filteredJobseekers;
      },
      'Theo bảng chữ cái': () {
        Utils.logMessage('Theo bảng chữ cái');
        _selectedSortOption.value = 2;
        // context.read<JobseekerListManager>().sortJobseekers(2);
        // _jobseekers.value =
        //     context.read<JobseekerListManager>().filteredJobseekers;
      },
      'Theo ngày đăng ký': () {
        Utils.logMessage('Theo ngày đăng ký');
        _selectedSortOption.value = 3;
      },
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
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
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final employerManager = context.read<EmployerListManager>();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Hiển thị tiêu đề của navigation item
        ScreenHeader(title: 'Nhà tuyển dụng'),
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
                          Selector<EmployerListManager, int>(
                              selector: (context, employerManager) =>
                                  employerManager.getEmployersCount,
                              builder: (context, totalEmployer, child) {
                                return OverviewCard(
                                  title: 'Tổng số công ty đăng ký',
                                  value: totalEmployer.toString(),
                                  imagePath: 'assets/images/jobseeker.png',
                                );
                              }),
                          Selector<EmployerListManager, int>(
                              selector: (context, employerManager) =>
                                  employerManager.getRecentEmployersCount,
                              builder: (context, recentEmployer, child) {
                                return OverviewCard(
                                  title: 'Tổng số đăng ký gần đây',
                                  value: recentEmployer.toString(),
                                  imagePath: 'assets/images/recently-date.png',
                                );
                              }),
                          Selector<EmployerListManager, int>(
                              selector: (context, employerManager) =>
                                  employerManager.activeEmployersCount,
                              builder: (context, activeEmployer, child) {
                                return OverviewCard(
                                  title: 'Tài khoản hoạt động',
                                  value: activeEmployer.toString(),
                                  imagePath: 'assets/images/verified-user.png',
                                );
                              }),
                          Selector<EmployerListManager, int>(
                              selector: (context, employerManager) =>
                                  employerManager.getLockedEmployersCount,
                              builder: (context, lockedEmployer, child) {
                                return OverviewCard(
                                  title: 'Tài khoản bị khóa',
                                  value: lockedEmployer.toString(),
                                  imagePath: 'assets/images/locked-user.png',
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
                            'Danh sách tất cả công ty (${employerManager.getEmployersCount})',
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
                              // if (searchText.isEmpty) {
                              //   jobseekerManager.resetSearch();
                              // } else {
                              //   jobseekerManager
                              //       .searchJobseeker(searchText);
                              // }
                              //Gán _jobseekers lại để truyền dữ liệu cho bảng
                              //Nếu mà người dùng xóa bỏ dữ liệu nhập thì, lệnh bên dưới
                              //Sẽ nạp lại toàn bộ dữ liệu ban đầu. Còn nếu có nhập
                              //Thì danh sách filteredJobseekers sẽ chỉ chứa các phần tử
                              //thỏa mãn điều kiện tìm kiếm
                              _employers.value =
                                  employerManager.filteredEmployers;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //Hiển thị bảng chứa danh sách ứng viên
                child: Consumer<EmployerListManager>(
                    builder: (context, employerManager, child) {
                  // _jobseekers.value = jobseekerManager.getJobseekers();

                  //Lấy tổng số nhóm có thể hiển thị trong number pagination
                  final totalGroupCount = employerManager.getTotalGroupCount(
                      5, employerManager.filteredEmployers);
                  //Thiết lập số lượng tab hiển thị trong number pagination
                  final visiblePagesCount = totalGroupCount == 0
                      ? 1
                      : totalGroupCount < 5 && totalGroupCount > 0
                          ? totalGroupCount
                          : 5;
                  //Thiết lập số lượng tối đa các tab hiển thị trong number pagination
                  final totalPages = totalGroupCount == 0 ? 1 : totalGroupCount;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: _employers,
                          builder: (context, employers, child) {
                            return EmployerListTable(
                              employers: employers,
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
                            _employers.value =
                                employerManager.getEmployerByPage(
                                    value, 5, employerManager.employerList);
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
              //Danh sách tài khoản công ty
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
                            'Danh sách tất cả tài khoản (${employerManager.getEmployersCount})',
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
                                Utils.logMessage(
                                    'selectedIndex: $_sortOptions');

                                return Chip(
                                  label: Text(_sortOptions.keys
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
                            hintText: 'Tìm kiếm tài khoản',
                            prefixIcon: Icons.search,
                            controller: _searchController,
                            onChanged: (searchText) {
                              // if (searchText.isEmpty) {
                              //   jobseekerManager.resetSearch();
                              // } else {
                              //   jobseekerManager
                              //       .searchJobseeker(searchText);
                              // }
                              //Gán _jobseekers lại để truyền dữ liệu cho bảng
                              //Nếu mà người dùng xóa bỏ dữ liệu nhập thì, lệnh bên dưới
                              //Sẽ nạp lại toàn bộ dữ liệu ban đầu. Còn nếu có nhập
                              //Thì danh sách filteredJobseekers sẽ chỉ chứa các phần tử
                              //thỏa mãn điều kiện tìm kiếm
                              _employers.value =
                                  employerManager.filteredEmployers;
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                //Hiển thị bảng chứa danh sách ứng viên
                child: Consumer<EmployerListManager>(
                    builder: (context, employerManager, child) {
                  // _jobseekers.value = jobseekerManager.getJobseekers();

                  //Lấy tổng số nhóm có thể hiển thị trong number pagination
                  final totalGroupCount = employerManager.getTotalGroupCount(
                      5, employerManager.filteredEmployers);
                  //Thiết lập số lượng tab hiển thị trong number pagination
                  final visiblePagesCount = totalGroupCount == 0
                      ? 1
                      : totalGroupCount < 5 && totalGroupCount > 0
                          ? totalGroupCount
                          : 5;
                  //Thiết lập số lượng tối đa các tab hiển thị trong number pagination
                  final totalPages = totalGroupCount == 0 ? 1 : totalGroupCount;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ValueListenableBuilder(
                          valueListenable: _employers,
                          builder: (context, employers, child) {
                            return EmployerAccountListTable(
                              employers: employers,
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
                            _employers.value =
                                employerManager.getEmployerByPage(
                                    value, 5, employerManager.employerList);
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
                    child: Consumer<EmployerListManager>(
                        builder: (context, employerManager, child) {
                      _recentEmployers.value =
                          employerManager.recentEmployersList;
                      //Lấy tổng số nhóm có thể hiển thị trong number pagination
                      final totalGroupCount =
                          employerManager.getTotalGroupCount(
                              5, employerManager.recentEmployersList);
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
                          'Công ty đăng ký gần đây (${employerManager.getRecentEmployersCount})',
                          style: textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        child: Column(
                          children: [
                            ValueListenableBuilder(
                                valueListenable: _recentEmployers,
                                builder: (context, employers, child) {
                                  return RecentEmployerListTable(
                                    employers: employers,
                                  );
                                }),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TableNumberPagination(
                                onPageChanged: (value) {
                                  Utils.logMessage('Chuyển đến trang $value');
                                  //Nạp 5 phần tử tiếp theo trong bảng
                                  _recentEmployers.value =
                                      employerManager.getEmployerByPage(
                                          value,
                                          5,
                                          employerManager.recentEmployersList);
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
                    child: Consumer<EmployerListManager>(
                        builder: (context, employerManager, child) {
                      _lockedEmployers.value =
                          employerManager.lockedEmployersList;
                      //Lấy tổng số nhóm có thể hiển thị trong number pagination
                      final totalGroupCount =
                          employerManager.getTotalGroupCount(
                              5, employerManager.lockedEmployersList);
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
                          'Danh sách công ty bị khóa (${employerManager.getLockedEmployersCount})',
                          style: textTheme.titleMedium!.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        child: Column(
                          children: [
                            ValueListenableBuilder(
                                valueListenable: _lockedEmployers,
                                builder: (context, employers, child) {
                                  return LockedEmployerListTable(
                                    employers: employers,
                                  );
                                }),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TableNumberPagination(
                                onPageChanged: (value) {
                                  Utils.logMessage('Chuyển đến trang $value');
                                  //Nạp 5 phần tử tiếp theo trong bảng
                                  _lockedEmployers.value =
                                      employerManager.getEmployerByPage(
                                          value,
                                          5,
                                          employerManager.lockedEmployersList);
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
          ),
        ),
      ],
    );
  }
}
