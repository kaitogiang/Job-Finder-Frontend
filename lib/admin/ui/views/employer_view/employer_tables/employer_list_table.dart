import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/employer_view/employer_tables/empty_employer_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/company.dart';

class EmployerListTable extends StatelessWidget {
  const EmployerListTable({super.key, required this.companies});

  final List<Company> companies;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );
    //Danh sách tiêu đề của các cột trong bảng trong trường hợp bảng rỗng
    final headers = [
      'Logo',
      'Tên công ty',
      'Email',
      'Địa chỉ',
      'Số điện thoại',
      'Hành động'
    ];
    final cellHeight = 80.0;
    return companies.isEmpty
        ? EmptyEmployerListTable(headers: headers)
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
                      child: Text('Logo', style: headerTextStyle),
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
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20, top: 10.0, bottom: 10.0),
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
                  String imageLink = '';
                  //Kiểm tra xem index hợp lệ thì mới gán lại các giá trị đó
                  if (index < companies.length) {
                    fullName = companies[index].companyName;
                    email = companies[index].companyEmail;
                    province = companies[index].companyAddress;
                    phone = companies[index].companyPhone;
                    imageLink = companies[index].imageLink;
                  }
                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.center,
                          child: imageLink.isEmpty
                              ? SizedBox.shrink()
                              : Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    image: DecorationImage(
                                      image: NetworkImage(imageLink),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  width: 60,
                                  height: 60,
                                ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            fullName,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            email,
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            province,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            phone,
                          ),
                        ),
                      ),
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.center,
                          child: index < companies.length
                              ? UserActionButton(
                                  paddingLeft: 22,
                                  onViewDetailsPressed: () {
                                    context.go(
                                        '/employer/company-info/${companies[index].id}');
                                    Utils.logMessage(
                                        'Xem chi tiết công ty ${companies[index].companyName}');
                                  },
                                  // onLockAccountPressed: () async {
                                  //   final choice = await confirmActionDialog(
                                  //       context,
                                  //       'Khóa tài khoản công ty',
                                  //       'Bạn có chắc chắn muốn khóa tài khoản công ty ${companies[index].companyName} không?',
                                  //       'Sau khi khóa, người này sẽ không thể đăng nhập vào hệ thống\ntrừ khi bạn mở khóa',
                                  //       CustomAlertType.lock);
                                  //   if (choice == true) {
                                  //     final lockedUser = LockedUser(
                                  //       lockedId: '',
                                  //       userId: companies[index].id,
                                  //       reason: 'Khóa bởi admin',
                                  //       userType: UserType.employer,
                                  //       lockedAt: DateTime.now(),
                                  //     );
                                  //     if (context.mounted) {
                                  //       await context
                                  //           .read<JobseekerListManager>()
                                  //           .lockAccount(lockedUser);

                                  //       if (context.mounted) {
                                  //         Utils.showNotification(
                                  //           context: context,
                                  //           title: 'Khóa tài khoản thành công',
                                  //           type: ToastificationType.success,
                                  //         );
                                  //       }
                                  //     }
                                  //   } else {
                                  //     Utils.logMessage('Hủy khóa tài khoản');
                                  //   }
                                  // },
                                  // onUnlockAccountPressed: () async {
                                  //   final choice = await confirmActionDialog(
                                  //       context,
                                  //       'Mở khóa tài khoản',
                                  //       'Bạn có chắc chắn muốn mở khóa tài khoản công ty ${companies[index].companyName} không?',
                                  //       'Sau khi mở khóa, người này sẽ có thể đăng nhập vào hệ thống',
                                  //       CustomAlertType.unlock);
                                  //   if (choice == true) {
                                  //     if (context.mounted) {
                                  //       await context
                                  //           .read<JobseekerListManager>()
                                  //           .unlockAccount(companies[index].id);
                                  //       if (context.mounted) {
                                  //         Utils.showNotification(
                                  //           context: context,
                                  //           title:
                                  //               'Mở khóa tài khoản thành công',
                                  //           type: ToastificationType.success,
                                  //         );
                                  //       }
                                  //     }
                                  //   } else {
                                  //     Utils.logMessage('Hủy mở khóa tài khoản');
                                  //   }
                                  // },
                                  // isLocked: employerListManager
                                  //     .isLocked(companies[index].id),
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
