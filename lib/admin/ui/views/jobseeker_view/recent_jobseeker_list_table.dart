import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/empty_jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';

class RecentJobseekerListTable extends StatelessWidget {
  const RecentJobseekerListTable({super.key, required this.jobseekers});

  final List<Map<String, dynamic>> jobseekers;

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
              2: FlexColumnWidth(),
              3: FlexColumnWidth(),
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
                      child: Text('Tên người dùng', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Email', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Số điện thoại', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
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
                        '${jobseekers[index]['firstName']} ${jobseekers[index]['lastName']}';
                    email = jobseekers[index]['email'] ?? '';
                    phone = jobseekers[index]['phone'] ?? '';
                  }

                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(fullName),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(email),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(phone),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: index < jobseekers.length
                              ? UserActionButton(
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
