import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class AccountStatusChart extends StatefulWidget {
  const AccountStatusChart({
    super.key,
    required this.chartName,
    required this.activeCount,
    required this.lockedCount,
  });

  final String chartName;
  final int activeCount;
  final int lockedCount;

  @override
  State<AccountStatusChart> createState() => _AccountStatusChartState();
}

class _AccountStatusChartState extends State<AccountStatusChart> {
  final ValueNotifier<int> _touchIndex = ValueNotifier(-1);

  List<PieChartSectionData> showingSections(
      double activeSection, double lockedSection) {
    final fontSize = 13.0;
    final touchFontSize = 15.0;
    final touchRadius = 85.0;
    final radius = 80.0;
    const shadows = [Shadow(color: Colors.black, blurRadius: 2)];
    return [
      PieChartSectionData(
          showTitle: true,
          titlePositionPercentageOffset: lockedSection == 0.0 ? 0 : 0.6,
          color: Colors.green,
          value: activeSection,
          title: '$activeSection%',
          radius: _touchIndex.value == 0 ? touchRadius : radius,
          titleStyle: TextStyle(
            fontSize: _touchIndex.value == 0 ? touchFontSize : fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          )),
      PieChartSectionData(
          color: Colors.red,
          value: lockedSection,
          titlePositionPercentageOffset: 0.6,
          title: '$lockedSection%',
          radius: _touchIndex.value == 1 ? touchRadius : radius,
          titleStyle: TextStyle(
            fontSize: _touchIndex.value == 1 ? touchFontSize : fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: shadows,
          )),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    //Lấy giá trị
    final activeCount = widget.activeCount;
    final lockedCount = widget.lockedCount;
    final total = activeCount + lockedCount;
    //Tính toán các phần chiếm bao nhiêu /100 phần
    final activeSection =
        double.parse((activeCount / total * 100).toStringAsFixed(2));
    final lockedSection =
        double.parse((lockedCount / total * 100).toStringAsFixed(2));
    return SizedBox(
      height: 230,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Nhà tuyển dụng',
            style: textTheme.titleMedium,
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: _touchIndex,
                    builder: (context, touchIndex, value) {
                      return PieChart(
                        PieChartData(
                          borderData: FlBorderData(
                            show: false,
                          ),
                          pieTouchData: PieTouchData(
                              touchCallback: (event, pieTouchResponse) {
                            if (!event.isInterestedForInteractions ||
                                pieTouchResponse == null ||
                                pieTouchResponse.touchedSection == null) {
                              _touchIndex.value = -1;
                            }
                            _touchIndex.value = pieTouchResponse
                                    ?.touchedSection?.touchedSectionIndex ??
                                -1;
                          }),
                          sectionsSpace: 3, //Khoảng cách giữa các section
                          centerSpaceRadius:
                              0, //Không cho phép khoét rỗng chính giữa biểu đồ
                          sections: showingSections(
                            activeSection,
                            lockedSection,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(children: [
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Icon(
                            Icons.circle,
                            size: 10,
                            color: Colors.green,
                          ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(
                            width: 5,
                          ),
                        ),
                        TextSpan(text: 'Còn hoạt động: $activeCount'),
                      ]),
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
                            color: Colors.red,
                          ),
                        ),
                        const WidgetSpan(
                          child: SizedBox(
                            width: 5,
                          ),
                        ),
                        TextSpan(text: 'Đã khóa: $lockedCount'),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
