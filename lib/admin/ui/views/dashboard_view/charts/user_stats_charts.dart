import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/models/user_registration_data.dart';

class UserStatsCharts extends StatefulWidget {
  const UserStatsCharts({
    super.key,
    this.chartType = ChartTypeInUserStats.barChart,
    required this.statsData,
  });

  final ChartTypeInUserStats chartType;
  final List<UserRegistrationData> statsData;

  @override
  State<UserStatsCharts> createState() => _UserStatsChartsState();
}

class _UserStatsChartsState extends State<UserStatsCharts> {
  int maximumRange = 7;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  double getTheMaximumYAxis(List<UserRegistrationData> data) {
    double max = 0;
    for (var userReg in data) {
      double innerMax = userReg.employerCount > userReg.jobseekerCount
          ? userReg.employerCount
          : userReg.jobseekerCount;
      if (max < innerMax) {
        max = innerMax;
      }
    }

    return max + 10;
  }

  BarChartGroupData generateBarGroup(
      int x, double jobseekerValue, double employerValue) {
    return BarChartGroupData(x: x, barRods: [
      BarChartRodData(
        toY: jobseekerValue,
        color: Colors.orange,
        width: 20,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
      BarChartRodData(
        toY: employerValue,
        color: Colors.blue,
        width: 20,
        borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
      ),
    ]);
  }

  List<LineChartBarData> generateLineGroup(List<UserRegistrationData> data) {
    //tạo ra 2 đường, một đường cho employer và một đường cho jobseeker
    return [
      //Đường cho jobseeker
      LineChartBarData(
        isCurved: false,
        color: Colors.orange,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: List<FlSpot>.generate(data.length, (index) {
          final x = index as double;
          final y = data[index].jobseekerCount;
          return FlSpot(x, y);
        }).toList(),
      ),
      LineChartBarData(
        isCurved: false,
        color: Colors.blue,
        barWidth: 5,
        isStrokeCapRound: true,
        dotData: const FlDotData(show: false),
        belowBarData: BarAreaData(show: false),
        spots: List<FlSpot>.generate(data.length, (index) {
          final x = index as double;
          final y = data[index].employerCount;
          return FlSpot(x, y);
        }).toList(),
      ),
    ];
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    final data = widget.statsData;
    final index = value as int;
    return SideTitleWidget(
      axisSide: meta.axisSide,
      space: 8,
      child: Text(
        data[index].label,
        style: TextStyle(
          fontSize: 12,
        ),
        // textAlign: TextAlign.left,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isShowBarChart = widget.chartType == ChartTypeInUserStats.barChart;
    final value = getTheMaximumYAxis(widget.statsData);
    Utils.logMessage('Max la: $value');
    return Container(
      height: 300,
      padding: const EdgeInsets.only(right: 10),
      child: isShowBarChart
          ? Padding(
              padding: const EdgeInsets.only(right: 10),
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  titlesData: FlTitlesData(
                    show: true,
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) {
                            return Container();
                          }
                          const style = TextStyle(
                            fontSize: 10,
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
                    final jobseekerValue =
                        widget.statsData[index].jobseekerCount;
                    final employerValue = widget.statsData[index].employerCount;
                    return generateBarGroup(
                        index, jobseekerValue, employerValue);
                  }).toList(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      return BarTooltipItem(
                        '${rod.toY} người',
                        TextStyle(
                          color: Colors.white, // Text color
                          fontWeight: FontWeight.bold, // Text weight
                        ),
                      );
                    }),
                  ),
                  // maxY: getTheMaximumYAxis(widget.statsData),
                ),
              ),
            )
          //Biểu đồ đường
          : Padding(
              padding: const EdgeInsets.only(right: 16),
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value == meta.max) {
                            return Container();
                          }
                          const style = TextStyle(
                            fontSize: 10,
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
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 36,
                        interval:
                            1, //Thiết lập mỗi giá trị cách nhau một đơn vị
                        getTitlesWidget: bottomTitleWidgets,
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: true,
                    drawHorizontalLine: true,
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border(
                      left: BorderSide(
                        color: Colors.black,
                        width: 1,
                      ),
                      bottom: BorderSide(color: Colors.black, width: 1),
                    ),
                  ),
                  lineBarsData: generateLineGroup(widget.statsData),
                  minX: 0,
                  maxX: widget.statsData.length.toDouble() - 1,
                  minY: 0,
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                        getTooltipColor: (touchoSpot) => Colors.grey[200]!,
                        getTooltipItems: (touchedBarSports) {
                          return touchedBarSports.map((barSpot) {
                            final flSpot = barSpot;
                            Utils.logMessage('BarIndex: ${flSpot.barIndex}');
                            return LineTooltipItem(
                                '',
                                TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                                children: [
                                  TextSpan(
                                    text: flSpot.y.toString(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      color: flSpot.barIndex == 0
                                          ? Colors.orange
                                          : Colors.blue,
                                    ),
                                  ),
                                ]);
                          }).toList();
                        }),
                  ),
                ),
              ),
            ),
    );
  }
}
