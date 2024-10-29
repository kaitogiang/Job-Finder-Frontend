import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/jobposting_list_manager.dart';
import 'package:job_finder_app/admin/ui/manager/jobseeker_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/empty_jobposting_table.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_tables/empty_jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/custom_alert.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/jobposting.dart';
import 'package:job_finder_app/models/locked_users.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

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
      'Số lượng yêu thích',
      'Ngày đăng',
      'Hành động'
    ];
    final jobpostingListManager = context.read<JobpostingListManager>();
    // Use the sort method from JobpostingListManager
    final sortedJobpostings =
        jobpostingListManager.sortJobpostingsByFavoriteCount(jobpostings);
    return sortedJobpostings.isEmpty
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
                children: headers.map((header) {
                  return TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text(header, style: headerTextStyle),
                    ),
                  );
                }).toList(),
              ),
              ...List<TableRow>.generate(
                sortedJobpostings.length,
                (index) {
                  // Extract data for each job posting
                  final jobposting = sortedJobpostings[index];
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(jobposting.company!.companyName),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(jobposting.title),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text('0'),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: Text(jobposting.createdAt),
                        ),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: UserActionButton(
                            onViewDetailsPressed: () {},
                            isLocked: false,
                          ),
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
