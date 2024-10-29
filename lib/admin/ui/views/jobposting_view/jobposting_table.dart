import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/views/jobposting_view/empty_jobposting_table.dart';
import 'package:job_finder_app/models/jobposting.dart';

class JobpostingTable extends StatelessWidget {
  final List<Jobposting> jobpostings;

  const JobpostingTable({Key? key, required this.jobpostings})
      : super(key: key);

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
      'Số lượng ứng tuyển',
      'Số lượt yêu thích',
      'Hành động'
    ];

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
              5: FlexColumnWidth(),
              6: FlexColumnWidth(),
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
              ...jobpostings.map((jobposting) {
                return TableRow(
                  children: [
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(jobposting.company?.companyName ?? 'N/A'),
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
                        child: Text(jobposting.createdAt),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: Text(jobposting.deadline),
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
                        child: Text('0'),
                      ),
                    ),
                    TableCell(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: ElevatedButton(
                          onPressed: () {
                            // Implement your action here
                            print('View details for ${jobposting.title}');
                          },
                          child: Text('View'),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ],
          );
  }
}
