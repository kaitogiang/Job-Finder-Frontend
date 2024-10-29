import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/manager/employer_list_manager.dart';
import 'package:job_finder_app/admin/ui/manager/jobseeker_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/empty_employer_list_table.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_tables/empty_jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/custom_alert.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/employer.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/locked_users.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class EmployerListTable extends StatelessWidget {
  const EmployerListTable({super.key, required this.employers});

  final List<Employer> employers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );
    //Danh sách tiêu đề của các cột trong bảng trong trường hợp bảng rỗng
    final headers = [
      'Tên công ty',
      'Email',
      'Tỉnh/thành phố',
      'Số điện thoại',
      'Hành động'
    ];
    final employerListManager = context.read<EmployerListManager>();
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
                      child: Text('Email', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Địa chỉ', style: headerTextStyle),
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
                  //Quá trình trích xuất dữ liệu từng ổ của mỗi cột
                  String fullName = '';
                  String email = '';
                  String province = '';
                  String phone = '';
                  //Kiểm tra xem index hợp lệ thì mới gán lại các giá trị đó
                  if (index < employers.length) {
                    //TODO: thay đổi cho phù hợp
                    fullName = employers[index].firstName;
                    email = employers[index].email;
                    province = employers[index].address;
                    phone = employers[index].phone;
                  }
                  return TableRow(
                    children: [
                      TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              fullName,
                            )),
                      ),
                      TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              email,
                            )),
                      ),
                      TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              province,
                            )),
                      ),
                      TableCell(
                        child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Text(
                              phone,
                            )),
                      ),
                      TableCell(
                        child: Padding(
                          padding: EdgeInsets.all(20.0),
                          child: index < employers.length
                              ? UserActionButton(
                                  onViewDetailsPressed: () {
                                    Utils.logMessage(
                                        'Xem chi tiết công ty ${employers[index].firstName} ${employers[index].lastName}');
                                  },
                                  onLockAccountPressed: () async {
                                    final choice = await confirmActionDialog(
                                        context,
                                        'Khóa tài khoản công ty',
                                        'Bạn có chắc chắn muốn khóa tài khoản công ty ${employers[index].firstName} ${employers[index].lastName} không?',
                                        'Sau khi khóa, người này sẽ không thể đăng nhập vào hệ thống\ntrừ khi bạn mở khóa',
                                        CustomAlertType.lock);
                                    if (choice == true) {
                                      final lockedUser = LockedUser(
                                        lockedId: '',
                                        userId: employers[index].id,
                                        reason: 'Khóa bởi admin',
                                        userType: UserType.employer,
                                        lockedAt: DateTime.now(),
                                      );
                                      if (context.mounted) {
                                        await context
                                            .read<JobseekerListManager>()
                                            .lockAccount(lockedUser);

                                        if (context.mounted) {
                                          Utils.showNotification(
                                            context: context,
                                            title: 'Khóa tài khoản thành công',
                                            type: ToastificationType.success,
                                          );
                                        }
                                      }
                                    } else {
                                      Utils.logMessage('Hủy khóa tài khoản');
                                    }
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
                                            .read<JobseekerListManager>()
                                            .unlockAccount(
                                                employers[index].id);
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
                                  onDeleteAccountPressed: () async {
                                    final choice = await confirmActionDialog(
                                        context,
                                        'Xóa tài khoản công ty',
                                        'Bạn có chắc chắn muốn xóa tài khoản công ty ${employers[index].firstName} ${employers[index].lastName} không?',
                                        'Sau khi xóa, bạn không thể hoàn tác hành động',
                                        CustomAlertType.delete);
                                    Utils.logMessage(choice.toString());
                                    Utils.logMessage(
                                      'Xóa tài khoản công ty ${employers[index].firstName} ${employers[index].lastName}',
                                    );
                                  },
                                  isLocked: employerListManager
                                      .isLocked(employers[index].id),
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
