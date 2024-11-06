import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/employer_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_tables/empty_employer_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/custom_alert.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/employer.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class LockedEmployerListTable extends StatelessWidget {
  const LockedEmployerListTable({super.key, required this.employers});

  final List<Employer> employers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );

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
                  if (index < employers.length) {
                    fullName =
                        '${employers[index].firstName} ${employers[index].lastName}';
                    email = employers[index].email;
                    phone = employers[index].phone;
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
                          child: index < employers.length
                              ? UserActionButton(
                                  onViewDetailsPressed: () {
                                    Utils.logMessage(
                                        'Xem chi tiết ứng viên $fullName');
                                  },
                                  onUnlockAccountPressed: () async {
                                    final choice = await confirmActionDialog(
                                        context,
                                        'Mở khóa tài khoản',
                                        'Bạn có chắc chắn muốn mở khóa tài khoản công ty ${employers[index].firstName} ${employers[index].lastName} không?',
                                        'Sau khi mở khóa, người này sẽ có thể đăng nhập vào hệ thống',
                                        CustomAlertType.unlock);
                                    if (choice == true) {
                                      if (context.mounted) {
                                        await context
                                            .read<EmployerListManager>()
                                            .unlockAccount(employers[index].id);
                                        if (context.mounted) {
                                          Utils.showNotification(
                                            context: context,
                                            title:
                                                'Mở khóa tài khoản thành công',
                                            type: ToastificationType.success,
                                          );
                                        }
                                      }
                                    } else {
                                      Utils.logMessage('Hủy mở khóa tài khoản');
                                    }
                                  },
                                  isLocked: true,
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
