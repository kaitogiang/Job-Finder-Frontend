import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/manager/application_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/application_view/application_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/content_container.dart';
import 'package:job_finder_app/admin/ui/widgets/overview_card.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';
import 'package:job_finder_app/admin/ui/widgets/search_box.dart';
import 'package:job_finder_app/admin/ui/widgets/table_number_pagination.dart';
import 'package:job_finder_app/models/application.dart';
import 'package:job_finder_app/models/application_storage.dart';
import 'package:provider/provider.dart';

class ApplicationScreen extends StatefulWidget {
  const ApplicationScreen({super.key});

  @override
  State<ApplicationScreen> createState() => _ApplicationScreenState();
}

class _ApplicationScreenState extends State<ApplicationScreen> {
  final _scrollController = ScrollController();

  final ValueNotifier<List<ApplicationStorage>> _storage = ValueNotifier([]);
  final _searchController = TextEditingController();

  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _searchController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final applicationListManager = context.read<ApplicationListManager>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Hiển thị tiêu đề của navigation item
        ScreenHeader(title: 'Hồ sơ ứng tuyển'),
        const Divider(
          thickness: 2,
        ),
        Expanded(
          child: FutureBuilder(
              future: applicationListManager.fetchJobpostings(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                //Khởi tạo danh sách các bảng
                _storage.value = applicationListManager.applications;
                return ListView(
                  children: [
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
                                Selector<ApplicationListManager, int>(
                                    selector: (context, applicationManager) =>
                                        applicationManager
                                            .totalJobseekerApplication,
                                    builder:
                                        (context, totalApplication, child) {
                                      return OverviewCard(
                                        title: 'Tổng số hồ sơ đã nhận',
                                        value: '$totalApplication',
                                        imagePath:
                                            'assets/images/total_application.png',
                                      );
                                    }),
                                Selector<ApplicationListManager, int>(
                                    selector: (context, applicationManager) =>
                                        applicationManager
                                            .applicationCountWithinOneWeek,
                                    builder: (context, totalOneWeekApplications,
                                        child) {
                                      return OverviewCard(
                                        title: 'Tổng số hồ sơ trong 1 tuần',
                                        value: '$totalOneWeekApplications',
                                        imagePath:
                                            'assets/images/one_week_application.png',
                                      );
                                    }),
                                Selector<ApplicationListManager, int>(
                                    selector: (context, applicationManager) =>
                                        applicationManager
                                            .totalProgressingApplications,
                                    builder: (context,
                                        totalProgressingApplications, child) {
                                      return OverviewCard(
                                        title: 'Tổng số hồ sơ đang xử lý',
                                        value: '$totalProgressingApplications',
                                        imagePath:
                                            'assets/images/processing_application.png',
                                      );
                                    }),
                                Selector<ApplicationListManager, int>(
                                    selector: (context, applicationManager) =>
                                        applicationManager
                                            .totalApprovedApplications,
                                    builder: (context,
                                        totalApprovedApplications, child) {
                                      return OverviewCard(
                                        title: 'Tổng số hồ sơ được chấp nhận',
                                        value: '$totalApprovedApplications',
                                        imagePath:
                                            'assets/images/application_approve.png',
                                      );
                                    }),
                                Selector<ApplicationListManager, int>(
                                    selector: (context, applicationManager) =>
                                        applicationManager
                                            .totalRejectedApplications,
                                    builder: (context,
                                        totalRejectedApplications, child) {
                                      return OverviewCard(
                                        title: 'Tổng số bị từ chối',
                                        value: '$totalRejectedApplications',
                                        imagePath: 'assets/images/cancel.png',
                                      );
                                    }),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    //Hiển thị bảng thông kê số lượng đơn nộp cho mỗi bài tuyển dụng còn hạn
                    //Hiển thị các thanh lọc dữ liệu và sắp xếp
                    ContentContainer(
                      header: Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Selector<ApplicationListManager, int>(
                                selector: (context, applicationManager) =>
                                    applicationManager
                                        .totalJobseekerApplication,
                                builder: (context, totalJobseekerApplications,
                                    child) {
                                  return Text(
                                    'Danh sách hồ sơ ứng tuyển ($totalJobseekerApplications)',
                                    style: textTheme.titleMedium!.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  );
                                }),
                            const SizedBox(
                              width: 10,
                            ),
                            SearchBox(
                              hintText: 'Tìm kiếm bài đăng',
                              controller: _searchController,
                              prefixIcon: Icons.search,
                              onChanged: (searchText) {
                                //Thực hiện tìm kiếm
                                if (searchText.isEmpty) {
                                  applicationListManager.resetSearch();
                                } else {
                                  applicationListManager
                                      .searchApplicationJobposting(searchText);
                                }

                                //Cập nhật lại _application để truyền lại list hiển thị mới trên bảng
                                _storage.value =
                                    applicationListManager.filteredApplication;
                              },
                            )
                          ],
                        ),
                      ),
                      //Hiển thị bảng chứa hồ sơ đã nộp
                      child: Consumer<ApplicationListManager>(
                          builder: (context, applicationManager, child) {
                        //TODO Gọi hàm cập nhật lại _applications để hiển thị cho trạng thái hiện tại

                        //Lấy tổng số nhóm có thể hiển thị trong number pagination
                        final totalGroupCount =
                            applicationManager.getTotalGroupCount(
                                5, applicationManager.filteredApplication);
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
                            // truyền danh sách application vào widget này
                            ValueListenableBuilder(
                              valueListenable: _storage,
                              builder: (context, storage, child) {
                                return ApplicationListTable(
                                  storages: storage,
                                );
                              },
                            ),
                            const SizedBox(
                              height: 10,
                            ),
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
                                  _storage.value =
                                      applicationManager.getJobpostingByPage(
                                          value,
                                          5,
                                          applicationManager.applications);
                                },
                                visiblePagesCount: visiblePagesCount,
                                totalPages: totalPages,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ],
                );
              }),
        )
      ],
    );
  }
}
