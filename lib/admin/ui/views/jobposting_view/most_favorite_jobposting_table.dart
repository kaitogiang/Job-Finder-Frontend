import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/admin/ui/manager/jobposting_list_manager.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/empty_jobposting_table.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:provider/provider.dart';

class MostFavoriteJobpostingTable extends StatelessWidget {
  const MostFavoriteJobpostingTable({super.key, required this.jobpostings});

  final List<Jobposting> jobpostings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );
    // Update the headers to match job posting attributes
    final headers = [
      'Tên công ty',
      'Tiêu đề',
      'Ngày đăng',
      'Ngày hết hạn',
      'Số lượng yêu thích',
      'Hành động'
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
              0: IntrinsicColumnWidth(),
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
                      padding: EdgeInsets.only(
                          left: 10.0, top: 10.0, bottom: 10.0, right: 10),
                      child: Text('Số thứ tự', style: headerTextStyle),
                    ),
                  ),
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
                      padding: EdgeInsets.only(
                        left: 10.0,
                        top: 10.0,
                        bottom: 10.0,
                        right: 10,
                      ),
                      child: Text('Số lượng yêu thích', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 10.0,
                        top: 10.0,
                        bottom: 10.0,
                        right: 10,
                      ),
                      child: Text('Hành động', style: headerTextStyle),
                    ),
                  ),
                ],
              ),
              ...List<TableRow>.generate(
                5,
                (index) {
                  String companyName = '';
                  String title = '';
                  String favoriteCount = '';
                  String createdAt = '';
                  String deadline = '';
                  //Kiểm tra xem index có hợp lệ không thì mới gán lại giá trị đó
                  if (index < jobpostings.length) {
                    companyName = jobpostings[index].company?.companyName ?? '';
                    title = jobpostings[index].title;
                    createdAt = DateFormat('dd/MM/yyyy\nh:mm a')
                        .format(DateTime.parse(jobpostings[index].createdAt));
                    deadline = DateFormat('dd/MM/yyyy\nh:mm a')
                        .format(DateTime.parse(jobpostings[index].deadline));
                    favoriteCount = context
                        .read<JobpostingListManager>()
                        .getJobpostingFavoriteCount(jobpostings[index].id)
                        .toString();
                  }
                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          child: Text(
                              index < jobpostings.length ? '${index + 1}' : ''),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
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
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(title),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(createdAt),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.centerLeft,
                          child: Text(deadline),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          child: Text(
                            favoriteCount,
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: const Color(0xFFAF52DE),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          alignment: Alignment.center,
                          child: index < jobpostings.length
                              ? UserActionButton(
                                  paddingLeft: 10,
                                  onViewDetailsPressed: () {
                                    context.go(
                                        '/jobposting/detail-info/${jobpostings[index].id}');
                                  },
                                  isLocked: false,
                                )
                              : SizedBox.shrink(),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          );
  }
}
