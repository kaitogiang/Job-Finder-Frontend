import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_tables/empty_jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/jobseeker.dart';

class RecentJobseekerListTable extends StatelessWidget {
  const RecentJobseekerListTable({super.key, required this.jobseekers});

  final List<Jobseeker> jobseekers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );

    final headers = ['Tên người dùng', 'Email', 'Số điện thoại', 'Hành động'];

    return jobseekers.isEmpty
        ? EmptyJobseekerListTable(headers: headers)
        : Table(
            border: TableBorder.all(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade400,
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: IntrinsicColumnWidth(),
              3: IntrinsicColumnWidth(),
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
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text('Tên người dùng', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text('Email', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text('Số điện thoại', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                      child: Text('Hành động', style: headerTextStyle),
                    ),
                  ),
                ],
              ),
              ...List<TableRow>.generate(
                5,
                (index) {
                  String fullName = '';
                  String email = '';
                  String phone = '';
                  if (index < jobseekers.length) {
                    fullName =
                        '${jobseekers[index].firstName} ${jobseekers[index].lastName}';
                    email = jobseekers[index].email;
                    phone = jobseekers[index].phone;
                  }

                  return TableRow(
                    children: <TableCell>[
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: 90,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(fullName),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: 90,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(email),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: 90,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(phone),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: 90,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          alignment: Alignment.centerLeft,
                          child: index < jobseekers.length
                              ? UserActionButton(
                                  paddingLeft: 15,
                                  onViewDetailsPressed: () {
                                    Utils.logMessage(
                                        'Xem chi tiết ứng viên $fullName');
                                  },
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
