import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/empty_jobposting_table.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/jobposting.dart';

class JobpostingTable extends StatelessWidget {
  final List<Jobposting> jobpostings;

  const JobpostingTable({super.key, required this.jobpostings});

  Color? _findTheJobLevelColor(String levelString) {
    const Color internTextColor = Color(0xFF007BFF); // Màu xanh nhạt cho Intern
    const Color fresherTextColor =
        Color(0xFF28A745); // Màu xanh lá nhạt cho Fresher
    const Color juniorTextColor =
        Color(0xFFFFC107); // Màu xanh dương nhạt cho Junior
    const Color middleTextColor =
        Color(0xFFDC3545); // Màu xanh dương đậm cho Middle
    const Color seniorTextColor = Color(0xFF6F42C1); // Màu cam nhạt cho Senior
    const Color managerTextColor =
        Color(0xFFFF6F20); // Màu cam đậm cho Trưởng phòng
    const Color leaderTextColor =
        Color(0xFF343A40); // Màu đỏ đậm cho Trưởng nhóm
    if (levelString.toLowerCase() ==
        FilterByJobLevel.intern.value.toLowerCase()) {
      return internTextColor;
    } else if (levelString.toLowerCase() ==
        FilterByJobLevel.fresher.value.toLowerCase()) {
      return fresherTextColor;
    } else if (levelString.toLowerCase() ==
        FilterByJobLevel.junior.value.toLowerCase()) {
      return juniorTextColor;
    } else if (levelString.toLowerCase() ==
        FilterByJobLevel.middle.value.toLowerCase()) {
      return middleTextColor;
    } else if (levelString.toLowerCase() ==
        FilterByJobLevel.senior.value.toLowerCase()) {
      return seniorTextColor;
    } else if (levelString.toLowerCase() ==
        FilterByJobLevel.manager.value.toLowerCase()) {
      return managerTextColor;
    } else if (levelString.toLowerCase() ==
        FilterByJobLevel.leader.value.toLowerCase()) {
      return leaderTextColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );

    final headers = [
      'Tên công ty',
      'Tiêu đề',
      'Ngày đăng',
      'Ngày hết hạn',
      'Trình độ',
      'Trạng thái',
      'Hành động',
    ];

    final cellHeight = 80.0;

    return jobpostings.isEmpty
        ? EmptyJobpostingTable(headers: headers)
        : Table(
            border: TableBorder.all(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade400,
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
              4: FlexColumnWidth(),
              5: IntrinsicColumnWidth(),
              6: IntrinsicColumnWidth(),
            },
            children: [
              TableRow(
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                children: [
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Tên công ty', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Tiêu đề', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Ngày đăng', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Ngày hết hạn', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Trình độ', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Trạng thái', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20, top: 10.0, bottom: 10.0),
                      child: Text('Hành động', style: headerTextStyle),
                    ),
                  ),
                ],
              ),
              ...List<TableRow>.generate(5, (index) {
                //Trích xuấ dữ liệu từng ô của mỗi cột
                String companyName = '';
                String title = '';
                String createdAt = '';
                String deadline = '';
                List<String> level = [];
                String status = '';
                bool isActive = true;
                //Kiểm tra xem index hợp lệ thì mới gán lại các giá trị đó
                if (index < jobpostings.length) {
                  companyName =
                      jobpostings[index].company?.companyName ?? 'N/A';
                  title = jobpostings[index].title;
                  //Format lại kiểu hiện thị cho ngày giờ
                  createdAt = DateFormat('dd/MM/yyyy\nh:mm a')
                      .format(DateTime.parse(jobpostings[index].createdAt));
                  deadline = DateFormat('dd/MM/yyyy\nh:mm a')
                      .format(DateTime.parse(jobpostings[index].deadline));
                  //Xác định trạng thái của bài đăng, còn hạn hay hết hạn
                  DateTime now = DateTime.now();
                  if (DateTime.parse(jobpostings[index].deadline)
                      .isBefore(now)) {
                    status = 'Hết hạn';
                    isActive = false;
                  } else {
                    status = 'Còn hoạt động';
                    isActive = true;
                  }
                  //Thêm danh sách trình độ vào bảng
                  // final levelList = jobpostings[index].level;
                  level = jobpostings[index].level;
                  // for (var levelString in levelList) {
                  //   if (levelString == levelList.last) {
                  //     level += levelString;
                  //   } else {
                  //     level += '$levelString, ';
                  //   }
                  // }
                }

                return TableRow(children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        companyName,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        createdAt,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        deadline,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: level.isEmpty
                          ? Text(
                              '',
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            )
                          : RichText(
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              text: TextSpan(
                                  children: List<TextSpan>.generate(
                                      level.length, (index) {
                                if (index == level.length - 1) {
                                  return TextSpan(
                                    text: level[index],
                                    style: TextStyle(
                                      color:
                                          _findTheJobLevelColor(level[index]),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                } else {
                                  return TextSpan(
                                      text: '${level[index]}, ',
                                      style: TextStyle(
                                        color:
                                            _findTheJobLevelColor(level[index]),
                                        fontWeight: FontWeight.bold,
                                      ));
                                }
                              })),
                            ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        status,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: index < jobpostings.length
                          ? UserActionButton(
                              paddingLeft: 22,
                              onViewDetailsPressed: () {
                                Utils.logMessage('Xem chi tiet bai dang');
                              },
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                ]);
              })
            ],
          );
  }
}
