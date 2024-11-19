import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:job_finder_app/admin/ui/manager/stats_manager.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/sample.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/dashboard_view/charts/account_status_chart.dart';
import 'package:job_finder_app/admin/ui/views/dashboard_view/charts/application_status_chart.dart';
import 'package:job_finder_app/admin/ui/views/dashboard_view/charts/recently_job_charts.dart';
import 'package:job_finder_app/admin/ui/views/dashboard_view/charts/user_stats_charts.dart';
import 'package:job_finder_app/admin/ui/widgets/content_container.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';
import 'package:job_finder_app/admin/ui/widgets/stats_card.dart';
import 'package:job_finder_app/admin/ui/widgets/stats_card_container.dart';
import 'package:job_finder_app/models/account_status_data.dart';
import 'package:job_finder_app/models/user_registration_data.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  //---------Các biến cho thống kê tổng người đăng ký trong thời gian nhất định-------
  //Lưu trữ loại biểu đồ hiện tại trong thống kê tổng số người đăng ký ứng dụng
  final ValueNotifier<Set<ChartTypeInUserStats>> _selectedUserChartType =
      ValueNotifier(<ChartTypeInUserStats>{ChartTypeInUserStats.barChart});
  //Lưu trữ lại mốc thời gian đã chọn cho thống kê tổng số người đăng ký ứng dụng
  final ValueNotifier<TimeRange> _selectedTimeRangeInUserStats =
      ValueNotifier(TimeRange.thisWeek);

  //---------Các biến cho thống kê công việc được tải đăng tải gần đây
  //Lưu trữ lại loại biểu đồ hiển tại để thống kê công việc
  final ValueNotifier<Set<ChartTypeInUserStats>> _selectedJobChartType =
      ValueNotifier(<ChartTypeInUserStats>{ChartTypeInUserStats.barChart});
  //Lưu trữ lại mốc thời gian đã chọn cho thống kê công việc
  final ValueNotifier<JobPostTimeRange> _selectedJobPostTimeRange =
      ValueNotifier(JobPostTimeRange.past7Days);

  //---------Các biến cho thống kê trạng thái ứng tuyển---------------
  //Lưu trữ trạng thái ứng tuyển theo từng mốc thời gian
  final ValueNotifier<TimeRange> _selectedApplicationStatusTimeRange =
      ValueNotifier(TimeRange.thisWeek);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    /*Giá trị để thống kê tổng số người đăng ký ứng dụng
    theo ngày lấy 7 ngày gần nhất, theo tuần lấy 4 tuần gần nhất,
    theo tháng lấy 12 tháng, theo năm thì lấy 5 năm gần nhất
    */
    final statsManager = context.read<StatsManager>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Hiển thị tiêu đề của navigation item
        ScreenHeader(title: 'Bảng điều khiển'),
        Divider(
          thickness: 2,
        ),
        Expanded(
          child: FutureBuilder(
              future: statsManager.fetchAllStatsData(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return SingleChildScrollView(
                  child: Column(
                    children: [
                      StaggeredGrid.count(
                        crossAxisCount: 6,
                        mainAxisSpacing: 5,
                        crossAxisSpacing: 5,
                        children: [
                          StaggeredGridTile.count(
                            crossAxisCellCount: 4,
                            mainAxisCellCount: 5,
                            child: Column(
                              children: [
                                Expanded(
                                  //Biểu đồ thống kê tổng số người đăng ký hệ thống
                                  child: ContentContainer(
                                    header: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Tổng người dùng đăng ký',
                                          style:
                                              textTheme.titleMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ValueListenableBuilder(
                                                valueListenable:
                                                    _selectedUserChartType,
                                                builder: (context,
                                                    selectedChart, child) {
                                                  return SegmentedButton<
                                                      ChartTypeInUserStats>(
                                                    emptySelectionAllowed:
                                                        false,
                                                    showSelectedIcon: false,
                                                    selected: selectedChart,
                                                    style: SegmentedButton
                                                        .styleFrom(
                                                            fixedSize:
                                                                Size(100, 70),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        19,
                                                                    horizontal:
                                                                        10),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            )),
                                                    onSelectionChanged:
                                                        (newSelection) {
                                                      Utils.logMessage(
                                                          "Selection chart is ${newSelection.first}");
                                                      _selectedUserChartType
                                                          .value = newSelection;
                                                    },
                                                    segments: [
                                                      ButtonSegment<
                                                              ChartTypeInUserStats>(
                                                          value:
                                                              ChartTypeInUserStats
                                                                  .barChart,
                                                          label: Text(
                                                              ChartTypeInUserStats
                                                                  .barChart
                                                                  .value)),
                                                      ButtonSegment<
                                                              ChartTypeInUserStats>(
                                                          value:
                                                              ChartTypeInUserStats
                                                                  .lineChart,
                                                          label: Text(
                                                              ChartTypeInUserStats
                                                                  .lineChart
                                                                  .value)),
                                                    ],
                                                  );
                                                }),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Transform.scale(
                                              scale: 0.9,
                                              child: DropdownMenu<TimeRange>(
                                                initialSelection:
                                                    _selectedTimeRangeInUserStats
                                                        .value,
                                                requestFocusOnTap: false,
                                                onSelected: (value) {
                                                  Utils.logMessage(
                                                      'Chọn $value');
                                                  _selectedTimeRangeInUserStats
                                                      .value = value!;
                                                  statsManager
                                                      .setUserStatsDataByTimeRange(
                                                          value);
                                                },
                                                inputDecorationTheme:
                                                    InputDecorationTheme(
                                                        border:
                                                            OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                )),
                                                dropdownMenuEntries:
                                                    TimeRange.values.map<
                                                            DropdownMenuEntry<
                                                                TimeRange>>(
                                                        (selectedRange) {
                                                  return DropdownMenuEntry<
                                                      TimeRange>(
                                                    value: selectedRange,
                                                    label: selectedRange.value,
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        //Nhãn hiển thị tổng số người đăng ký và trung bình theo từng mốc thời gian
                                        ValueListenableBuilder(
                                            valueListenable:
                                                _selectedTimeRangeInUserStats,
                                            builder: (context,
                                                selectedTimeRange, child) {
                                              //TODO gán lại giá trị tổng và trung bình ở đây
                                              //Hiển thị tổng người dùng trong khoảng thời gian nhất định
                                              int totalUsers = 0;
                                              //Hiển thị trung bình so với mốc thời gian
                                              int averageUsers = 0;
                                              if (selectedTimeRange ==
                                                  TimeRange.thisWeek) {
                                                totalUsers = statsManager
                                                    .totalUserRegistrationInWeek;
                                                averageUsers = statsManager
                                                    .averageUserRegistrationInWeek;
                                              } else if (selectedTimeRange ==
                                                  TimeRange.thisMonth) {
                                                totalUsers = statsManager
                                                    .totalUserRegistrationInMonth;
                                                averageUsers = statsManager
                                                    .averageUserRegistrationInMonth;
                                              } else if (selectedTimeRange ==
                                                  TimeRange.thisYear) {
                                                totalUsers = statsManager
                                                    .totalUserRegistrationInYear;
                                                averageUsers = statsManager
                                                    .averageUserRegistrationInYear;
                                              }

                                              String totalString = '';
                                              String avgString = '';
                                              switch (selectedTimeRange) {
                                                //Thống kê trong tuần này
                                                case TimeRange.thisWeek:
                                                  {
                                                    totalString =
                                                        'Tổng $totalUsers người trong tuần này';
                                                    avgString =
                                                        'Trung bình $averageUsers người/ngày';
                                                    break;
                                                  }
                                                //Thống kê trong tháng này
                                                case TimeRange.thisMonth:
                                                  {
                                                    totalString =
                                                        'Tổng $totalUsers người trong tháng này';
                                                    avgString =
                                                        'Trung bình $averageUsers người/tuần';
                                                    break;
                                                  }
                                                //Thống kê trong năm này
                                                case TimeRange.thisYear:
                                                  {
                                                    totalString =
                                                        'Tổng $totalUsers người trong năm này';
                                                    avgString =
                                                        'Trung bình $averageUsers người/tháng';
                                                    break;
                                                  }
                                              }

                                              return Row(
                                                children: [
                                                  RichText(
                                                    text: TextSpan(children: [
                                                      WidgetSpan(
                                                          alignment:
                                                              PlaceholderAlignment
                                                                  .middle,
                                                          child: Icon(
                                                            Icons.person,
                                                            color: Colors.blue,
                                                          )),
                                                      const WidgetSpan(
                                                          child: SizedBox(
                                                        width: 10,
                                                      )),
                                                      TextSpan(
                                                          text: totalString),
                                                    ]),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  RichText(
                                                    text: TextSpan(children: [
                                                      WidgetSpan(
                                                          alignment:
                                                              PlaceholderAlignment
                                                                  .middle,
                                                          child: Icon(
                                                            Icons.show_chart,
                                                            color:
                                                                Colors.orange,
                                                          )),
                                                      const WidgetSpan(
                                                          child: SizedBox(
                                                        width: 10,
                                                      )),
                                                      TextSpan(text: avgString),
                                                    ]),
                                                  ),
                                                ],
                                              );
                                            }),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        //Hiển thị tên của biểu đồ tùy theo mốc thời gian
                                        ValueListenableBuilder(
                                            valueListenable:
                                                _selectedTimeRangeInUserStats,
                                            builder: (context,
                                                selectedTimeRange, child) {
                                              String chartName = '';
                                              if (selectedTimeRange ==
                                                  TimeRange.thisWeek) {
                                                chartName =
                                                    'Biểu đồ tổng số người đăng ký tuần này';
                                              } else if (selectedTimeRange ==
                                                  TimeRange.thisMonth) {
                                                chartName =
                                                    'Biểu đồ tổng số người đăng ký tháng này';
                                              } else {
                                                chartName =
                                                    'Biểu đồ tổng số người đăng ký năm này';
                                              }
                                              return Text(
                                                chartName,
                                                style: textTheme.titleMedium!
                                                    .copyWith(
                                                  fontSize: 18,
                                                ),
                                              );
                                            }),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        /**
                                       * Hiển thị biểu đồ tương ứng dựa vào loại biểu đồ đã chọn
                                       * lắng nghe sự thay đổi của lựa chọn để rebuilt lại widget này
                                       * Wrap với Consumer để cập nhật lại giá trị truyền vào khi thay đổi mốc thời gian
                                       */
                                        Consumer<StatsManager>(builder:
                                            (context, statsManager, child) {
                                          final userStatsData =
                                              statsManager.userStatsData;
                                          return ValueListenableBuilder(
                                              valueListenable:
                                                  _selectedUserChartType,
                                              builder: (context, selectedChart,
                                                  child) {
                                                return UserStatsCharts(
                                                  statsData: userStatsData,
                                                  chartType:
                                                      selectedChart.first,
                                                );
                                              });
                                        }),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(children: [
                                                WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Icon(
                                                      Icons.square,
                                                      size: 13,
                                                      color: Colors.orange,
                                                    )),
                                                const WidgetSpan(
                                                    child: SizedBox(
                                                  width: 5,
                                                )),
                                                TextSpan(text: 'Người tìm việc')
                                              ]),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                            RichText(
                                              text: TextSpan(children: [
                                                WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Icon(
                                                      Icons.square,
                                                      size: 13,
                                                      color: Colors.blue,
                                                    )),
                                                const WidgetSpan(
                                                    child: SizedBox(
                                                  width: 5,
                                                )),
                                                TextSpan(text: 'Nhà tuyển dụng')
                                              ]),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Expanded(
                                  //Biểu đồ hiển thị công việc được đăng tải theo tuần, tháng, năm
                                  child: ContentContainer(
                                    header: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Công việc mới vừa đăng tải',
                                          style:
                                              textTheme.titleMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            ValueListenableBuilder(
                                                valueListenable:
                                                    _selectedJobChartType,
                                                builder: (context,
                                                    selectedChart, child) {
                                                  return SegmentedButton<
                                                      ChartTypeInUserStats>(
                                                    emptySelectionAllowed:
                                                        false,
                                                    showSelectedIcon: false,
                                                    selected: selectedChart,
                                                    style: SegmentedButton
                                                        .styleFrom(
                                                            fixedSize:
                                                                Size(100, 70),
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    vertical:
                                                                        19,
                                                                    horizontal:
                                                                        10),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            )),
                                                    onSelectionChanged:
                                                        (newSelection) {
                                                      Utils.logMessage(
                                                          "Selection chart is ${newSelection.first}");
                                                      _selectedJobChartType
                                                          .value = newSelection;
                                                    },
                                                    segments: [
                                                      ButtonSegment<
                                                              ChartTypeInUserStats>(
                                                          value:
                                                              ChartTypeInUserStats
                                                                  .barChart,
                                                          label: Text(
                                                              ChartTypeInUserStats
                                                                  .barChart
                                                                  .value)),
                                                      ButtonSegment<
                                                              ChartTypeInUserStats>(
                                                          value:
                                                              ChartTypeInUserStats
                                                                  .lineChart,
                                                          label: Text(
                                                              ChartTypeInUserStats
                                                                  .lineChart
                                                                  .value)),
                                                    ],
                                                  );
                                                }),
                                            const SizedBox(
                                              width: 10,
                                            ),
                                            Transform.scale(
                                              scale: 0.9,
                                              child: DropdownMenu<
                                                  JobPostTimeRange>(
                                                initialSelection:
                                                    _selectedJobPostTimeRange
                                                        .value,
                                                requestFocusOnTap: false,
                                                onSelected: (value) {
                                                  Utils.logMessage(
                                                      'Chọn $value');
                                                  _selectedJobPostTimeRange
                                                      .value = value!;
                                                  //TODO gọi hàm trong manager để cập nhật lại giao diện,
                                                  //Nạp dữ liệu theo mốc thời gian
                                                  statsManager
                                                      .setJobStatsDataByTimeRange(
                                                          value);
                                                },
                                                inputDecorationTheme:
                                                    InputDecorationTheme(
                                                        border:
                                                            OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                )),
                                                dropdownMenuEntries:
                                                    JobPostTimeRange.values.map<
                                                            DropdownMenuEntry<
                                                                JobPostTimeRange>>(
                                                        (selectedRange) {
                                                  return DropdownMenuEntry<
                                                      JobPostTimeRange>(
                                                    value: selectedRange,
                                                    label: selectedRange.value,
                                                  );
                                                }).toList(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        //Nhãn hiển thị tổng số người đăng ký và trung bình theo từng mốc thời gian
                                        ValueListenableBuilder(
                                            valueListenable:
                                                _selectedJobPostTimeRange,
                                            builder: (context,
                                                selectedTimeRange, child) {
                                              //TODO gán lại giá trị tổng và trung bình ở đây
                                              //Hiển thị tổng người dùng trong khoảng thời gian nhất định
                                              final totalUsers = 147;
                                              //Hiển thị trung bình so với mốc thời gian
                                              final averageUsers = 14;
                                              String totalString = '';
                                              String avgString = '';
                                              switch (selectedTimeRange) {
                                                //Thống kê trong tuần này
                                                case JobPostTimeRange.past7Days:
                                                  {
                                                    totalString =
                                                        'Tổng $totalUsers người trong 7 ngày qua';
                                                    avgString =
                                                        'Trung bình $averageUsers người/ngày';
                                                    break;
                                                  }
                                                //Thống kê trong tháng này
                                                case JobPostTimeRange
                                                      .past4Weeks:
                                                  {
                                                    totalString =
                                                        'Tổng $totalUsers người trong 4 tuần qua';
                                                    avgString =
                                                        'Trung bình $averageUsers người/tuần';
                                                    break;
                                                  }
                                                //Thống kê trong năm này
                                                case JobPostTimeRange
                                                      .past5Month:
                                                  {
                                                    totalString =
                                                        'Tổng $totalUsers người trong năm này';
                                                    avgString =
                                                        'Trung bình $averageUsers người/tháng';
                                                    break;
                                                  }
                                              }

                                              return Row(
                                                children: [
                                                  RichText(
                                                    text: TextSpan(children: [
                                                      WidgetSpan(
                                                          alignment:
                                                              PlaceholderAlignment
                                                                  .middle,
                                                          child: Icon(
                                                            Icons.person,
                                                            color: Colors.blue,
                                                          )),
                                                      const WidgetSpan(
                                                          child: SizedBox(
                                                        width: 10,
                                                      )),
                                                      TextSpan(
                                                          text: totalString),
                                                    ]),
                                                  ),
                                                  const SizedBox(
                                                    width: 20,
                                                  ),
                                                  // RichText(
                                                  //   text: TextSpan(children: [
                                                  //     WidgetSpan(
                                                  //         alignment:
                                                  //             PlaceholderAlignment
                                                  //                 .middle,
                                                  //         child: Icon(
                                                  //           Icons.show_chart,
                                                  //           color:
                                                  //               Colors.orange,
                                                  //         )),
                                                  //     const WidgetSpan(
                                                  //         child: SizedBox(
                                                  //       width: 10,
                                                  //     )),
                                                  //     TextSpan(text: avgString),
                                                  //   ]),
                                                  // ),
                                                ],
                                              );
                                            }),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                        //Hiển thị tên của biểu đồ tùy theo mốc thời gian
                                        ValueListenableBuilder(
                                            valueListenable:
                                                _selectedJobPostTimeRange,
                                            builder: (context,
                                                selectedTimeRange, child) {
                                              String chartName = '';
                                              if (selectedTimeRange ==
                                                  JobPostTimeRange.past7Days) {
                                                chartName =
                                                    'Biểu đồ tổng số công việc mới trong 7 ngày qua';
                                              } else if (selectedTimeRange ==
                                                  JobPostTimeRange.past4Weeks) {
                                                chartName =
                                                    'Biểu đồ tổng số công việc mới trong 2 tuần qua';
                                              } else {
                                                chartName =
                                                    'Biểu đồ tổng số công việc mới trong 1 tháng qua';
                                              }
                                              return Text(
                                                chartName,
                                                style: textTheme.titleMedium!
                                                    .copyWith(
                                                  fontSize: 18,
                                                ),
                                              );
                                            }),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        /**
                                       * Hiển thị biểu đồ tương ứng dựa vào loại biểu đồ đã chọn
                                       * lắng nghe sự thay đổi của lựa chọn để rebuilt lại widget này
                                       * Wrap với Consumer để cập nhật lại giá trị truyền vào khi thay đổi mốc thời gian
                                       */
                                        Consumer<StatsManager>(builder:
                                            (context, statsManager, child) {
                                          final jobStatsData =
                                              statsManager.jobStatsData;
                                          return ValueListenableBuilder(
                                              valueListenable:
                                                  _selectedJobChartType,
                                              builder: (context, selectedChart,
                                                  child) {
                                                return RecentlyJobCharts(
                                                  statsData: jobStatsData,
                                                  chartType:
                                                      selectedChart.first,
                                                );
                                              });
                                        }),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            RichText(
                                              text: TextSpan(children: [
                                                WidgetSpan(
                                                    alignment:
                                                        PlaceholderAlignment
                                                            .middle,
                                                    child: Icon(
                                                      Icons.square,
                                                      size: 13,
                                                      color: Colors.green,
                                                    )),
                                                const WidgetSpan(
                                                    child: SizedBox(
                                                  width: 5,
                                                )),
                                                TextSpan(
                                                    text:
                                                        'số lượng công việc mới')
                                              ]),
                                            ),
                                            const SizedBox(
                                              width: 20,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          //Trạng thái tài khoản
                          StaggeredGridTile.count(
                            crossAxisCellCount: 2,
                            mainAxisCellCount: 5,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.blue,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    //Hiển thị trạng thái tài khoản
                                    child: ContentContainer(
                                      header: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Trạng thái tài khoản',
                                            style:
                                                textTheme.titleMedium!.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          FractionallySizedBox(
                                            widthFactor: 0.9,
                                            child: const Divider(
                                              height: 2,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Selector<StatsManager,
                                                  AccountStatusData>(
                                              selector:
                                                  (context, statsManager) =>
                                                      statsManager
                                                          .accountStatusData,
                                              builder: (context,
                                                  acountStatusData, child) {
                                                return AccountStatusChart(
                                                  chartName: 'Nhà tuyển dụng',
                                                  activeCount: acountStatusData
                                                      .activeEmployer,
                                                  lockedCount: acountStatusData
                                                      .lockedEmployer,
                                                );
                                              }),
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Selector<StatsManager,
                                                  AccountStatusData>(
                                              selector:
                                                  (context, statsManager) =>
                                                      statsManager
                                                          .accountStatusData,
                                              builder: (context, statsManager,
                                                  child) {
                                                return AccountStatusChart(
                                                  chartName: 'Người tìm việc',
                                                  activeCount: statsManager
                                                      .activeJobseeker,
                                                  lockedCount: statsManager
                                                      .lockedJobseeker,
                                                );
                                              }),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Expanded(
                                    flex: 2,
                                    child: ContentContainer(
                                      header: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Các khu vực tuyển dụng',
                                            style:
                                                textTheme.titleMedium!.copyWith(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                        ],
                                      ),
                                      child: Expanded(
                                        child: ListView.builder(
                                          itemCount: 50,
                                          itemBuilder: (context, index) =>
                                              Text('Test $index'),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          //Trạng thái ứng tuyển
                          StaggeredGridTile.count(
                            crossAxisCellCount: 6,
                            mainAxisCellCount: 3,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black,
                              ),
                              padding: const EdgeInsets.all(10),
                              child: ContentContainer(
                                header: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Trạng thái ứng tuyển',
                                      style: textTheme.titleMedium!.copyWith(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                    Transform.scale(
                                      scale: 0.9,
                                      child: DropdownMenu<TimeRange>(
                                        initialSelection:
                                            _selectedApplicationStatusTimeRange
                                                .value,
                                        requestFocusOnTap: false,
                                        onSelected: (value) {
                                          Utils.logMessage('Chọn $value');
                                          _selectedApplicationStatusTimeRange
                                              .value = value!;
                                          //TODO gọi hàm trong manager để cập nhật lại giao diện,
                                          //Nạp dữ liệu theo mốc thời gian
                                          statsManager
                                              .setApplicationStatsDataByTimeRange(
                                                  value);
                                        },
                                        inputDecorationTheme:
                                            InputDecorationTheme(
                                                border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        )),
                                        dropdownMenuEntries: TimeRange.values
                                            .map<DropdownMenuEntry<TimeRange>>(
                                                (selectedRange) {
                                          return DropdownMenuEntry<TimeRange>(
                                            value: selectedRange,
                                            label: selectedRange.value,
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                child: Consumer<StatsManager>(
                                    builder: (context, statsManager, child) {
                                  final statsData =
                                      statsManager.applicationStatsData;
                                  return ApplicationStatusChart(
                                    statsData: statsData,
                                  );
                                }),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
        ),
      ],
    );
  }
}
