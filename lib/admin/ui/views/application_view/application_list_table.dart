import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/views/application_view/empty_application_table.dart';
import 'package:job_finder_app/admin/ui/widgets/user_action_button.dart';
import 'package:job_finder_app/models/application_storage.dart';
import 'package:job_finder_app/models/jobposting.dart';

class ApplicationListTable extends StatelessWidget {
  const ApplicationListTable({
    super.key,
    required this.storages,
  });

  final List<ApplicationStorage> storages;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );
    final headers = [
      'Công ty',
      'Bài đăng',
      'Trạng thái',
      'Đã nhận',
      'Chấp nhận',
      'Từ chối',
      'Đang xử lý',
      'Hành động',
    ];

    final cellHeight = 80.0;

    final receivedQuantityColor = Color(0xFF007BFF);
    final approvedQuantityColor = Color(0xFF28A745);
    final rejectedQuantityColor = Color(0xFFDC3545);
    final progressingQuantityColor = Color(0xFFFD7E14);
    final numberFontSize = 16.0;
    return storages.isEmpty
        ? EmptyApplicationTable(headers: headers)
        : Table(
            border: TableBorder.all(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey.shade400,
            ),
            columnWidths: const <int, TableColumnWidth>{
              0: FlexColumnWidth(),
              1: FlexColumnWidth(),
              2: FlexColumnWidth(),
              3: IntrinsicColumnWidth(),
              4: IntrinsicColumnWidth(),
              5: IntrinsicColumnWidth(),
              6: IntrinsicColumnWidth(),
              7: IntrinsicColumnWidth(),
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
                  // ...List<TableCell>.generate(headers.length, (index) {
                  //   return TableCell(
                  //     child: Padding(
                  //       padding: EdgeInsets.only(
                  //           left: 20.0, top: 10.0, bottom: 10.0),
                  //       child: Text(headers[index], style: headerTextStyle),
                  //     ),
                  //   );
                  // }),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Công ty', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Bài đăng', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding:
                          EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
                      child: Text('Trạng thái', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, top: 10.0, bottom: 10.0, right: 20),
                      child: Text('Đã nhận', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, top: 10.0, bottom: 10.0, right: 20),
                      child: Text('Chấp nhận', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, top: 10.0, bottom: 10.0, right: 20),
                      child: Text('Từ chối', style: headerTextStyle),
                    ),
                  ),
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 20.0, right: 20, top: 10.0, bottom: 10.0),
                      child: Text('Đang xử lý', style: headerTextStyle),
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
              ...List<TableRow>.generate(5, (index) {
                //Trích xuấ dữ liệu từng ô của mỗi cột
                String companyName = '';
                String title = '';
                String status = '';
                String receivedApplication = '';
                String approvedApplicaton = '';
                String rejectedApplication = '';
                String proccessedApplication = '';
                bool isActive = true;
                //Kiểm tra xem index hợp lệ thì mới gán lại các giá trị đó
                if (index < storages.length) {
                  //truy xuất một storage tại index, một storage tương đương với một
                  //jobposting
                  final storage = storages[index];
                  //Gọi hàm truy xuất thông tin jobposting cụ thể dựa vào jobpostingId
                  //trong modal Application
                  //gọi hàm truy xuất công ty và jobposting
                  companyName =
                      storage.jobposting.company?.companyName ?? 'N/A';
                  title = storage.jobposting.title;
                  //Xác định trạng thái của bài đăng còn hạn hay không
                  //bằng cách so sánh thời gian hiện tại và deadline của Jobpostig
                  //format thời gian và so sánh => lấy trạng thái
                  final jobpostingDeadline =
                      DateTime.parse(storage.jobposting.deadline);
                  // final formattedDeadline =
                  //     DateFormat('dd/MM/yyyy\nh:mm a').format(jobpostingDeadline);
                  final now = DateTime.now();
                  //Xác định trạng thái của bài đăng, còn hạn hay hết hạn
                  if (jobpostingDeadline.isBefore(now)) {
                    status = 'Hết hạn';
                    isActive = false;
                  } else {
                    status = 'Còn hoạt động';
                    isActive = true;
                  }
                  //Dếm số lượng tất cả hồ sơ đã nhận
                  receivedApplication = storage.applications
                      .where((application) {
                        return application.status == 0;
                      })
                      .toList()
                      .length
                      .toString();
                  //đếm số lượng hồ sơ đã chấp nhận
                  approvedApplicaton = storage.applications
                      .where((application) {
                        return application.status == 1;
                      })
                      .toList()
                      .length
                      .toString();
                  //đếm số lượng hồ sơ đã từ chối
                  rejectedApplication = storage.applications
                      .where((application) {
                        return application.status == 2;
                      })
                      .toList()
                      .length
                      .toString();
                  //đếm số lượng hồ sơ đang xử lý
                  proccessedApplication = storage.applications
                      .where((application) {
                        return application.status == 0;
                      })
                      .toList()
                      .length
                      .toString();
                }

                return TableRow(children: [
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
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
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.centerLeft,
                      child: Text(
                        status,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: isActive
                              ? Colors.green.shade400
                              : Colors.red.shade400,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        receivedApplication,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: receivedQuantityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: numberFontSize,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        approvedApplicaton,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: approvedQuantityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: numberFontSize,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        rejectedApplication,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: rejectedQuantityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: numberFontSize,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: Text(
                        proccessedApplication,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodyMedium!.copyWith(
                          color: progressingQuantityColor,
                          fontWeight: FontWeight.bold,
                          fontSize: numberFontSize,
                        ),
                      ),
                    ),
                  ),
                  TableCell(
                    verticalAlignment: TableCellVerticalAlignment.middle,
                    child: Container(
                      height: cellHeight,
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      child: index < storages.length
                          ? UserActionButton(
                              paddingLeft: 22,
                              onViewDetailsPressed: () {
                                Utils.logMessage('Xem chi tiet bai dang');
                                context.go(
                                    '/application/application-info/${storages[index].id}');
                              },
                            )
                          : SizedBox.shrink(),
                    ),
                  ),
                ]);
              })
            ],
          );
  }
}
