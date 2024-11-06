import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_tables/empty_employer_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/employer.dart';

class RecentEmployerListTable extends StatelessWidget {
  const RecentEmployerListTable({super.key, required this.employers});

  final List<Employer> employers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );

    final cellHeight = 90.0;

    final headers = ['Tên người dùng', 'Email', 'Số điện thoại', 'Hành động'];

    return employers.isEmpty
        ? EmptyEmployerListTable(headers: headers)
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
                      padding: EdgeInsets.all(10),
                      child: Text('Tên người dùng', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text('Email', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      child: Text('Số điện thoại', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      padding: EdgeInsets.all(10),
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
                  if (index < employers.length) {
                    fullName =
                        '${employers[index].firstName} ${employers[index].lastName}';
                    email = employers[index].email;
                    phone = employers[index].phone;
                  }

                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(fullName),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(email),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          alignment: Alignment.centerLeft,
                          child: Text(phone),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 20),
                          alignment: Alignment.centerLeft,
                          child: index < employers.length
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
