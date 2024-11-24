import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/application_stats_data.dart';
import 'package:job_finder_app/models/user_registration_data.dart';

class ApplicationStatusChart extends StatefulWidget {
  const ApplicationStatusChart({
    super.key,
    required this.statsData,
  });

  final List<ApplicationStatsData> statsData;

  @override
  State<ApplicationStatusChart> createState() => _ApplicationStatusChartState();
}

class _ApplicationStatusChartState extends State<ApplicationStatusChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  BarChartGroupData generateBarGroup(
      int x, double receivedCount, double approvedCount, double rejectedCount) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: receivedCount,
        color: Colors.blue,
        width: 20,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: approvedCount,
        color: Colors.green,
        width: 20,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: rejectedCount,
        color: Colors.red,
        width: 20,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
    ]);
  }

  void _getTotalCountByTimeRange(
      int receivedCount, int approvedCount, int rejectedCount) {
    final statsData = widget.statsData;
    //Đếm số lượng đã nhập ở những mốc thời gian con
    receivedCount = statsData.fold(0, (previous, data) {
      return previous + data.receivedApplicationCount;
    });
    //Đếm số lượng đã chấp nhận ở những mốc thời gian con
    approvedCount = statsData.fold(0, (previous, data) {
      return previous + data.approvedApplicationCount;
    });
    //Đếm số lượng đã từ chối ở những mốc thời gian con
    rejectedCount = statsData.fold(0, (previous, data) {
      return previous + data.rejectedApplicationCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    //Ghi nhận lại tổng số đã nhận, đã chấp nhận, đã từ chối theo từng mốc thời gian
    int totalReceivedCount = 0;
    int totalApprovedCount = 0;
    int totalRejectedCount = 0;
    totalReceivedCount = widget.statsData.fold(0, (previous, data) {
      return previous + data.receivedApplicationCount;
    });
    //Đếm số lượng đã chấp nhận ở những mốc thời gian con
    totalApprovedCount = widget.statsData.fold(0, (previous, data) {
      return previous + data.approvedApplicationCount;
    });
    //Đếm số lượng đã từ chối ở những mốc thời gian con
    totalRejectedCount = widget.statsData.fold(0, (previous, data) {
      return previous + data.rejectedApplicationCount;
    });
    return Container(
        height: 450,
        padding: const EdgeInsets.only(right: 10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //Card hiển thị số lượng hồ sơ đã nộp
                _buildApplicationCountCard(
                  theme,
                  totalReceivedCount,
                  'Đã nộp',
                  Colors.blue,
                ),
                const SizedBox(
                  width: 30,
                ),
                //Card hiển thị số lượng thành công
                _buildApplicationCountCard(
                  theme,
                  totalApprovedCount,
                  'Đã chấp nhận',
                  Colors.green,
                ),
                const SizedBox(
                  width: 30,
                ),
                //Card hiển thị số lượng
                _buildApplicationCountCard(
                  theme,
                  totalRejectedCount,
                  'Đã từ chối',
                  Colors.red,
                ),
              ],
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              'Biểu đồ trạng thái ứng tuyển tuần này',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  titlesData: FlTitlesData(
                    show: true,
                    //Đặt các nhãn số ở bên trái tự động điều chỉnh giá trị dựa vào giá trị được truyền vào
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) {
                            return Container();
                          }
                          const style = TextStyle(
                            fontSize: 12,
                          );
                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            //Dùng meta.formattedValue để cho char tự động điều chỉnh lại giá trị
                            //Nếu nó quá lớn, nếu là 1500 thì nó sẽ format lại là 1.5k
                            child: Text(
                              meta.formattedValue,
                              textAlign: TextAlign.left,
                              style: style,
                            ),
                          );
                        },
                      ),
                    ),
                    //Hiển thị các nhãn bên dưới các cột để ám chỉ cho từng mốc thời gian nhỏ
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          final index = value.toInt();
                          final label = widget.statsData[index].label;

                          return SideTitleWidget(
                            axisSide: meta.axisSide,
                            child: Text(
                              label,
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  //Tùy chỉnh background phía sau biểu đồ, cho phép hiển thị lưới ngang và dọc
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                  ),
                  borderData: FlBorderData(
                      show: true,
                      border: Border(
                          left: BorderSide(color: Colors.black, width: 1),
                          bottom: BorderSide(color: Colors.black, width: 1))),
                  barGroups: List<BarChartGroupData>.generate(
                      widget.statsData.length, (index) {
                    final receivedCount =
                        widget.statsData[index].receivedApplicationCount;
                    final approvedCount =
                        widget.statsData[index].approvedApplicationCount;
                    final rejectedCount =
                        widget.statsData[index].rejectedApplicationCount;
                    return generateBarGroup(index, receivedCount.toDouble(),
                        approvedCount.toDouble(), rejectedCount.toDouble());
                  }).toList(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      String unit = '';
                      //Nếu cột nhất nhất của nhóm được rê chuột đến thì kèm theo đơn vị "đã nộp"
                      if (rodIndex == 0) {
                        unit = 'đã nộp';
                      }
                      //Nếu cột nhất nhất của nhóm được rê chuột đến thì kèm theo đơn vị "đã chấp nhận"

                      else if (rodIndex == 1) {
                        unit = 'đã chấp nhận';
                      } else {
                        unit = 'đã từ chối';
                      }
                      return BarTooltipItem(
                        '${rod.toY} hồ sơ $unit',
                        TextStyle(
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.bold, // Text weight
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  Column _buildApplicationCountCard(
      ThemeData theme, int quantity, String label, Color iconColor) {
    return Column(
      children: [
        Text(
          '$quantity',
          style: theme.textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        RichText(
          text: TextSpan(children: [
            WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.square,
                  color: iconColor,
                )),
            const WidgetSpan(
                child: SizedBox(
              width: 5,
            )),
            TextSpan(
                text: label,
                style: theme.textTheme.bodyMedium!.copyWith(
                  fontSize: 15,
                ))
          ]),
        ),
      ],
    );
  }
}
