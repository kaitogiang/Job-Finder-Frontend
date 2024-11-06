import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/jobposting_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/jobposting_table.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/most_favorite_jobposting_table.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/recent_jobposting_table.dart';
import 'package:job_finder_app/admin/ui/widgets/content_container.dart';
import 'package:job_finder_app/admin/ui/widgets/multi_filter_box.dart';
import 'package:job_finder_app/admin/ui/widgets/overview_card.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';
import 'package:job_finder_app/admin/ui/widgets/search_box.dart';
import 'package:job_finder_app/admin/ui/widgets/table_number_pagination.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:provider/provider.dart';

class JobpostingScreen extends StatefulWidget {
  const JobpostingScreen({super.key});

  @override
  State<JobpostingScreen> createState() => _JobpostingScreenState();
}

class _JobpostingScreenState extends State<JobpostingScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final ValueNotifier<List<Jobposting>> _jobpostings = ValueNotifier([]);
  final ValueNotifier<List<Jobposting>> _mostFavoriteJobpostings =
      ValueNotifier([]);
  //Bộ lọc của All Jobposting và option của nó
  // final ValueNotifier<int> _allJobpostingSelectedFOption = ValueNotifier(0);
  // final Map<String, void Function()> _allJobpostingSortOptions = {};

  //Khởi tạo danh sách điều kiện lọc theo từng nhóm
  final ValueNotifier<List<FilterByTime>> _filterByTimeNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<FilterByJobpostingStatus>> _filterByStatusNotifier =
      ValueNotifier([]);
  final ValueNotifier<List<FilterByJobLevel>> _filterByLevelNotifer =
      ValueNotifier([]);

  //Listener dùng để cho biết khi nào hiển thị label Chip mặc định
  final ValueNotifier<bool> _isShowDefaultFilterLabel = ValueNotifier(true);

  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    //Khởi tạo bộ lọc
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _fetchDataDemo();
    // });
    _filterByTimeNotifier.addListener(_checkDefaultFilterLabelApperance);
    _filterByStatusNotifier.addListener(_checkDefaultFilterLabelApperance);
    _filterByLevelNotifer.addListener(_checkDefaultFilterLabelApperance);
  }

  void _showOverlayMenu(BuildContext context) {
    showMenu(
        context: context,
        position: RelativeRect.fromLTRB(50, 50, 100, 100),
        items: []);
  }

  void _checkDefaultFilterLabelApperance() {
    Utils.logMessage('Goi ham checkDefaultFilterLabel');
    if (_filterByTimeNotifier.value.isEmpty &&
        _filterByStatusNotifier.value.isEmpty &&
        _filterByLevelNotifer.value.isEmpty) {
      _isShowDefaultFilterLabel.value = true;
    } else {
      _isShowDefaultFilterLabel.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final jobpostingListManager = context.read<JobpostingListManager>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Hiển thị tiêu đề của navigation item
        ScreenHeader(title: 'Bài tuyển dụng'),
        const Divider(
          thickness: 2,
        ),
        Expanded(
          child: FutureBuilder(
              future: jobpostingListManager.fetchJobpostings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final favoriteList =
                    context.read<JobpostingListManager>().favoriteList;
                Utils.logMessage('Favorite Number is: ${favoriteList.length}');
                //Khởi tạo dữ liệu cho bảng
                _jobpostings.value = jobpostingListManager.jobpostings;
                _mostFavoriteJobpostings.value =
                    jobpostingListManager.mostFavoriteJobpostings;
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
                                Selector<JobpostingListManager, int>(
                                    selector: (contex, jobpostingManager) =>
                                        jobpostingManager.jobpostingsCount,
                                    builder: (context, totalJobposting, child) {
                                      return OverviewCard(
                                        title: 'Tổng số bài tuyển dụng',
                                        value: '$totalJobposting',
                                        imagePath:
                                            'assets/images/jobposting.png',
                                      );
                                    }),
                                Selector<JobpostingListManager, int>(
                                    selector: (context, jobpostingManager) =>
                                        jobpostingManager
                                            .recentJobpostingsCount,
                                    builder:
                                        (context, recentJobposting, child) {
                                      return OverviewCard(
                                        title: 'Bài tuyển dụng gần đây',
                                        value: '$recentJobposting',
                                        imagePath:
                                            'assets/images/recent_jobposting.png',
                                      );
                                    }),
                                Selector<JobpostingListManager, int>(
                                    selector: (context, jobpostingManager) =>
                                        jobpostingManager
                                            .mostFavoriteJobpostingsCount,
                                    builder: (context, favoriteCount, child) {
                                      return OverviewCard(
                                        title:
                                            'Số Lượng Bài Đăng Được Yêu Thích',
                                        value: '$favoriteCount',
                                        imagePath: 'assets/images/favorite.png',
                                      );
                                    }),
                                Selector<JobpostingListManager, int>(
                                    selector: (context, jobpostingManager) =>
                                        jobpostingManager.activeJobpostingCount,
                                    builder:
                                        (context, activeJobposting, child) {
                                      return OverviewCard(
                                        title: 'Bài tuyển dụng còn hạn',
                                        value: '$activeJobposting',
                                        imagePath:
                                            'assets/images/valid_jobposting.png',
                                      );
                                    }),
                                Selector<JobpostingListManager, int>(
                                    selector: (context, jobpostingManager) =>
                                        jobpostingManager
                                            .expiredJobpostingCount,
                                    builder:
                                        (context, expiredJobposting, child) {
                                      return OverviewCard(
                                        title: 'Bài tuyển dụng hết hạn',
                                        value: '$expiredJobposting',
                                        imagePath:
                                            'assets/images/overdue_jobposting.png',
                                      );
                                    }),
                                // OverviewCard(
                                //   title: 'Bài tuyển bị vô hiệu hóa',
                                //   value: '0',
                                //   imagePath: 'assets/images/cancel.png',
                                // ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    //Danh sách bài tuyển dụng gần đây
                    ContentContainer(
                      header: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            //Phần header bên trên gồm tiêu đề của bảng, filter box và thanh tìm kiếm
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                //Hiển thị tiêu đề và chế độ sắp xếp đã chọn
                                Row(
                                  children: [
                                    Text(
                                      'Danh sách bài tuyển dụng (${jobpostingListManager.jobpostingsCount})',
                                      style: textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                  ],
                                ),
                                //Hiển thị box chọn chế độ sắp xếp và thanh tìm kiếm
                                Row(
                                  children: [
                                    // ValueListenableBuilder(
                                    //     valueListenable: _selectedSortOption,
                                    //     builder: (context, value, child) {
                                    //       return SortBox(
                                    //         sortOptions: _sortOptions,
                                    //         selectedIndex: value,
                                    //       );
                                    //     }),
                                    MultiFilterBox(
                                      filterByTimeSelection:
                                          _filterByTimeNotifier,
                                      filterByStatusSelection:
                                          _filterByStatusNotifier,
                                      filterByLevelSelection:
                                          _filterByLevelNotifer,
                                    ),
                                    const SizedBox(width: 10),
                                    SearchBox(
                                      hintText: 'Tìm kiếm bài tuyển dụng',
                                      prefixIcon: Icons.search,
                                      controller: _searchController,
                                      onChanged: (searchText) {
                                        //Gán lại giá trị tìm kiếm
                                        context
                                            .read<JobpostingListManager>()
                                            .searchText = searchText;
                                        if (searchText.isEmpty) {
                                          jobpostingListManager.resetSearch();
                                        } else {
                                          Utils.logMessage('Tim kiem');
                                          jobpostingListManager
                                              .searchJobpostings(searchText);
                                        }
                                        //Gán _jobseekers lại để truyền dữ liệu cho bảng
                                        //Nếu mà người dùng xóa bỏ dữ liệu nhập thì, lệnh bên dưới
                                        //Sẽ nạp lại toàn bộ dữ liệu ban đầu. Còn nếu có nhập
                                        //Thì danh sách filteredJobseekers sẽ chỉ chứa các phần tử
                                        //thỏa mãn điều kiện tìm kiếm
                                        _jobpostings.value =
                                            jobpostingListManager
                                                .filteredJobpostings;
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Text(
                              'Chế độ lọc hiện tại',
                              style: textTheme.bodyMedium!.copyWith(
                                color: Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Wrap(
                              runSpacing: 10,
                              children: [
                                ValueListenableBuilder(
                                    valueListenable: _isShowDefaultFilterLabel,
                                    builder: (context, isShowDefaultFilterLabel,
                                        child) {
                                      return isShowDefaultFilterLabel
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15),
                                              child: Chip(
                                                label: Text("Tất cả bài đăng"),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                    color:
                                                        Colors.green.shade400,
                                                  ),
                                                ),
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                backgroundColor:
                                                    Colors.green.shade400,
                                                labelStyle: textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            )
                                          : SizedBox.shrink();
                                    }),
                                ValueListenableBuilder(
                                    valueListenable: _filterByTimeNotifier,
                                    builder: (context, filterByTime, child) {
                                      String filterLabelList = '';
                                      for (var filterLabel in filterByTime) {
                                        //Nếu bằng phần tử cuối cùng thì không cần thêm
                                        //dấu phẩy vào
                                        if (filterByTime.last == filterLabel) {
                                          filterLabelList += filterLabel.value;
                                        } else {
                                          //Ghép chuỗi và thêm dấu phẩy ở cuối
                                          filterLabelList +=
                                              '${filterLabel.value}, ';
                                        }
                                      }
                                      return filterByTime.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15),
                                              child: Chip(
                                                label: Text(
                                                    "Thời gian: $filterLabelList"),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                    color:
                                                        Colors.green.shade400,
                                                  ),
                                                ),
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                backgroundColor:
                                                    Colors.green.shade400,
                                                labelStyle: textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            )
                                          : SizedBox.shrink();
                                    }),
                                ValueListenableBuilder(
                                    valueListenable: _filterByStatusNotifier,
                                    builder: (context, filterByStatus, child) {
                                      String filterLabelList = '';
                                      for (var filterLabel in filterByStatus) {
                                        //Nếu là phẩn tử cuối thì không cần thêm dấu
                                        //phẩy vào
                                        if (filterByStatus.last ==
                                            filterLabel) {
                                          filterLabelList += filterLabel.value;
                                        } else {
                                          filterLabelList +=
                                              '${filterLabel.value}, ';
                                        }
                                      }
                                      return filterByStatus.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15),
                                              child: Chip(
                                                label: Text(
                                                    "Trạng thái: $filterLabelList"),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                    color:
                                                        Colors.green.shade400,
                                                  ),
                                                ),
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                backgroundColor:
                                                    Colors.green.shade400,
                                                labelStyle: textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            )
                                          : SizedBox.shrink();
                                    }),
                                ValueListenableBuilder(
                                    valueListenable: _filterByLevelNotifer,
                                    builder: (context, filterByLevel, child) {
                                      String filterLabelList = '';
                                      for (var filterLabel in filterByLevel) {
                                        if (filterByLevel.last == filterLabel) {
                                          filterLabelList += filterLabel.value;
                                        } else {
                                          filterLabelList +=
                                              '${filterLabel.value}, ';
                                        }
                                      }
                                      return filterByLevel.isNotEmpty
                                          ? Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 15),
                                              child: Chip(
                                                label: Text(
                                                    "Trình độ: $filterLabelList"),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(20),
                                                  side: BorderSide(
                                                    color:
                                                        Colors.green.shade400,
                                                  ),
                                                ),
                                                padding: EdgeInsets.only(
                                                    left: 10, right: 10),
                                                backgroundColor:
                                                    Colors.green.shade400,
                                                labelStyle: textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Colors.white),
                                              ),
                                            )
                                          : SizedBox.shrink();
                                    }),
                              ],
                            )
                          ],
                        ),
                      ),
                      //Hiển thị bảng chứa danh các bài tuyển dụng
                      child: Consumer<JobpostingListManager>(
                          builder: (context, jobpostingListManager, child) {
                        _jobpostings.value =
                            jobpostingListManager.filteredJobpostings;
                        Utils.logMessage(
                            'Gọi cập nhật: ${_jobpostings.value.length}');
                        //Lấy tổng số nhóm có thể hiển thị trong number pagination
                        final totalGroupCount =
                            jobpostingListManager.getTotalGroupCount(
                                5, jobpostingListManager.filteredJobpostings);
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
                                valueListenable: _jobpostings,
                                builder: (context, jobpostings, child) {
                                  return JobpostingTable(
                                    jobpostings: jobpostings,
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
                                  _jobpostings.value =
                                      jobpostingListManager.getJobpostingByPage(
                                          value,
                                          5,
                                          jobpostingListManager.jobpostings);
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
                          child: Consumer<JobpostingListManager>(
                              builder: (context, jobpostingListManager, child) {
                            // _mostFavoriteJobpostings.value =
                            //     jobpostingListManager.mostFavoriteJobpostings;
                            //Lấy tổng số nhóm có thể hiển thị trong number pagination
                            final totalGroupCount =
                                jobpostingListManager.getTotalGroupCount(
                                    5,
                                    jobpostingListManager
                                        .mostFavoriteJobpostings);
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
                                'Bài tuyển dụng được yêu thích nhiều nhất (${jobpostingListManager.mostFavoriteJobpostingsCount})',
                                style: textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              child: Column(
                                children: [
                                  ValueListenableBuilder(
                                      valueListenable: _mostFavoriteJobpostings,
                                      builder: (context, jobpostings, child) {
                                        return MostFavoriteJobpostingTable(
                                          jobpostings: jobpostings,
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
                                        _mostFavoriteJobpostings.value =
                                            jobpostingListManager
                                                .getJobpostingByPage(
                                                    value,
                                                    5,
                                                    jobpostingListManager
                                                        .mostFavoriteJobpostings);
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
                        // Flexible(
                        //   flex: 1,
                        //   child: Consumer<EmployerListManager>(
                        //       builder: (context, employerManager, child) {
                        //     _lockedEmployers.value =
                        //         employerManager.lockedEmployersList;
                        //     //Lấy tổng số nhóm có thể hiển thị trong number pagination
                        //     final totalGroupCount =
                        //         employerManager.getTotalGroupCount(
                        //             5, employerManager.lockedEmployersList);
                        //     //Thiết lập số lượng tab hiển thị trong number pagination
                        //     final visiblePagesCount = totalGroupCount == 0
                        //         ? 1
                        //         : totalGroupCount < 5 && totalGroupCount > 0
                        //             ? totalGroupCount
                        //             : 5;
                        //     //Thiết lập số lượng tối đa các tab hiển thị trong number pagination
                        //     final totalPages =
                        //         totalGroupCount == 0 ? 1 : totalGroupCount;
                        //     return ContentContainer(
                        //       header: Text(
                        //         'Danh sách công ty bị khóa (${employerManager.getLockedEmployersCount})',
                        //         style: textTheme.titleMedium!.copyWith(
                        //           fontWeight: FontWeight.bold,
                        //           fontSize: 18,
                        //         ),
                        //       ),
                        //       child: Column(
                        //         children: [
                        //           ValueListenableBuilder(
                        //               valueListenable: _lockedEmployers,
                        //               builder: (context, employers, child) {
                        //                 return LockedEmployerListTable(
                        //                   employers: employers,
                        //                 );
                        //               }),
                        //           const SizedBox(height: 10),
                        //           Align(
                        //             alignment: Alignment.centerRight,
                        //             child: TableNumberPagination(
                        //               onPageChanged: (value) {
                        //                 Utils.logMessage('Chuyển đến trang $value');
                        //                 //Nạp 5 phần tử tiếp theo trong bảng
                        //                 _lockedEmployers.value =
                        //                     employerManager.getEmployerByPage(
                        //                         value,
                        //                         5,
                        //                         employerManager.lockedEmployersList);
                        //               },
                        //               visiblePagesCount: visiblePagesCount,
                        //               totalPages: totalPages,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     );
                        //   }),
                        // ),
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
