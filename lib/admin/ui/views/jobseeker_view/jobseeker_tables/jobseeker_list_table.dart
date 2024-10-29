import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/manager/jobseeker_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/jobseeker_view/jobseeker_tables/empty_jobseeker_list_table.dart';
import 'package:job_finder_app/admin/ui/widgets/custom_alert.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/jobseeker.dart';
import 'package:job_finder_app/models/locked_users.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

class JobseekerListTable extends StatelessWidget {
  const JobseekerListTable({super.key, required this.jobseekers});

  final List<Jobseeker> jobseekers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );
    //Danh sách tiêu đề của các cột trong bảng trong trường hợp bảng rỗng
    final headers = [
      'Tên người dùng',
      'Email',
      'Tỉnh/thành phố',
      'Số điện thoại',
      'Hành động'
    ];
    final cellHeight = 80.0;
    final jobseekerListManager = context.read<JobseekerListManager>();
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
                      child: Text('Tỉnh/thành phố', style: headerTextStyle),
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
                  if (index < jobseekers.length) {
                    fullName =
                        '${jobseekers[index].firstName} ${jobseekers[index].lastName}';
                    email = jobseekers[index].email;
                    province = jobseekers[index].address;
                    phone = jobseekers[index].phone;
                  }
                  return TableRow(
                    children: [
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Container(
                          height: cellHeight,
                          padding: EdgeInsets.symmetric(horizontal: 10.0),
                          alignment: Alignment.centerLeft,
                          child: Text(
                            fullName,
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
                          alignment: Alignment.centerLeft,
                          child: index < jobseekers.length
                              ? Builder(builder: (context) {
                                  return UserActionButton(
                                    onViewDetailsPressed: () {
                                      Utils.logMessage(
                                          'Xem chi tiết ứng viên ${jobseekers[index].firstName} ${jobseekers[index].lastName}');
                                      // showAdditionalInfoDialog(
                                      //   context: context,
                                      //   title: 'Thông tin ứng viên',
                                      //   headerIcon: 'assets/images/info.png',
                                      //   content: JobseekerDetailScreen(),
                                      // );
                                      context.go('/jobseeker/detail');
                                      // Router.neglect(
                                      //   context,
                                      //   () => context.go('/jobseeker/detail'),
                                      // );
                                    },
                                    onLockAccountPressed: () async {
                                      final choice = await confirmActionDialog(
                                          context,
                                          'Khóa tài khoản ứng viên',
                                          'Bạn có chắc chắn muốn khóa tài khoản ứng viên ${jobseekers[index].firstName} ${jobseekers[index].lastName} không?',
                                          'Sau khi khóa, người này sẽ không thể đăng nhập vào hệ thống\ntrừ khi bạn mở khóa',
                                          CustomAlertType.lock);
                                      if (choice == true) {
                                        final lockedUser = LockedUser(
                                          lockedId: '',
                                          userId: jobseekers[index].id,
                                          reason: 'Khóa bởi admin',
                                          userType: UserType.jobseeker,
                                          lockedAt: DateTime.now(),
                                        );
                                        if (context.mounted) {
                                          await context
                                              .read<JobseekerListManager>()
                                              .lockAccount(lockedUser);

                                          if (context.mounted) {
                                            Utils.showNotification(
                                              context: context,
                                              title:
                                                  'Khóa tài khoản thành công',
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
                                          'Bạn có chắc chắn muốn mở khóa tài khoản ứng viên ${jobseekers[index].firstName} ${jobseekers[index].lastName} không?',
                                          'Sau khi mở khóa, người này sẽ có thể đăng nhập vào hệ thống',
                                          CustomAlertType.unlock);
                                      if (choice == true) {
                                        if (context.mounted) {
                                          await context
                                              .read<JobseekerListManager>()
                                              .unlockAccount(
                                                  jobseekers[index].id);
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
                                        Utils.logMessage(
                                            'Hủy mở khóa tài khoản');
                                      }
                                    },
                                    // onDeleteAccountPressed: () async {
                                    //   final choice = await confirmActionDialog(
                                    //       context,
                                    //       'Xóa tài khoản ứng viên',
                                    //       'Bạn có chắc chắn muốn xóa tài khoản ứng viên ${jobseekers[index].firstName} ${jobseekers[index].lastName} không?',
                                    //       'Sau khi xóa, bạn không thể hoàn tác hành động',
                                    //       CustomAlertType.delete);
                                    //   Utils.logMessage(choice.toString());
                                    //   Utils.logMessage(
                                    //     'Xóa tài khoản ứng viên ${jobseekers[index].firstName} ${jobseekers[index].lastName}',
                                    //   );
                                    // },
                                    isLocked: jobseekerListManager
                                        .isLocked(jobseekers[index].id),
                                  );
                                })
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
