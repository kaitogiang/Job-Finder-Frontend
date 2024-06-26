import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../../../models/application.dart';
import '../../shared/enums.dart';
import '../../shared/modal_bottom_sheet.dart';
import 'status_card.dart';

//! Card dùng để hiển thị một hồ sơ đã nộp của một ứng viên
class ApplicantCard extends StatelessWidget {
  const ApplicantCard({
    super.key,
    this.status = ApplicationStatus.pending,
    required this.application,
    this.isRead = false,
  });

  final ApplicationStatus status;
  final Application application;
  final bool isRead;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = application.name;
    final email = application.email;
    final phone = application.phone;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: status == ApplicationStatus.pending
              ? Colors.grey
              : status == ApplicationStatus.accepted
                  ? Colors.green[700]!
                  : Colors.red,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.only(
          left: 10,
        ),
        visualDensity: VisualDensity.compact,
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //?Thẻ hiển thị trạng thái của hồ sơ
            Expanded(child: Text(name)),
          ],
        ),
        subtitle: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(children: [
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.email,
                    size: 17,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(
                    width: 6,
                  ),
                ),
                TextSpan(
                  text: email,
                  style: textTheme.bodyMedium,
                ),
              ]),
            ),
            const SizedBox(
              height: 5,
            ),
            RichText(
              text: TextSpan(children: [
                const WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Icon(
                    Icons.phone,
                    size: 17,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(
                    width: 6,
                  ),
                ),
                TextSpan(
                  text: phone,
                  style: textTheme.bodyMedium,
                ),
                const WidgetSpan(
                  child: SizedBox(
                    width: 6,
                  ),
                ),
              ]),
            ),
            const SizedBox(
              height: 5,
            ),
            //? Thẻ hiển thị trạng thái của hồ sơ
            StatusCard(
              status: status,
            ),
          ],
        ),
        trailing: TextButton(
          onPressed: () {
            showAdditionalScreen(
                context: context,
                title: 'Tùy chọn',
                child: Builder(builder: (context) {
                  return _buildActionButton(
                    context: context,
                    onPreview: () async {
                      log('Xem chi tiết profile');
                      context.pushNamed('jobseeker-detail',
                          extra: application.jobseekerId);
                      Navigator.pop(context);
                    },
                    onDownload: () async {
                      log('Tải xuống CV');
                      final path = await context
                          .read<ApplicationManager>()
                          .downloadFile(
                              'pdfs/jobseeker-1717601317184-737476261.pdf',
                              'MyCV.pdf');
                      if (path != null) {
                        QuickAlert.show(
                            context: context,
                            type: QuickAlertType.info,
                            title: 'Tải xuống thành công',
                            text: 'File được tải xuống tại $path',
                            confirmBtnText: 'Tôi biết rồi');
                      }
                    },
                    onUpdate: !isRead
                        ? () {
                            log('Cập nhật trạng thái cho ứng viên này');
                            _showMyDialog(context, 'Nguyễn Văn Tèo');
                          }
                        : null,
                  );
                }),
                heightFactor: !isRead ? 0.4 : 0.3);
          },
          child: Text('Tùy chọn'),
        ),
      ),
    );
  }

  Future<void> _showMyDialog(context, name) async {
    final textTheme = Theme.of(context).textTheme;
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Center(child: Text('Duyệt hồ sơ?')),
          alignment: Alignment.center,
          content: RichText(
            text: TextSpan(children: [
              TextSpan(text: 'Bạn muốn ', style: textTheme.bodyLarge),
              TextSpan(
                  text: 'NHẬN',
                  style: textTheme.bodyLarge!.copyWith(
                      color: Colors.green, fontWeight: FontWeight.bold)),
              TextSpan(text: ' hay ', style: textTheme.bodyLarge),
              TextSpan(
                text: 'TỪ CHỐI',
                style: textTheme.bodyLarge!
                    .copyWith(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              TextSpan(text: ' hồ sơ của $name?', style: textTheme.bodyLarge)
            ]),
          ),
          actions: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor: Colors.red[50],
                          foregroundColor: Colors.red,
                          fixedSize: Size.fromWidth(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      onPressed: () async {
                        log('Từ chối');
                        final isCancel = await QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          title: 'Xác nhận từ chối hồ sơ',
                          text: 'Bạn đã chắc chắn từ chối $name?',
                          cancelBtnText: 'Không',
                          confirmBtnText: 'Có',
                          onCancelBtnTap: () {
                            Navigator.pop(context, true);
                          },
                          onConfirmBtnTap: () {
                            Navigator.pop(context, false);
                          },
                        ) as bool;
                        if (context.mounted) {
                          if (isCancel) {
                            Navigator.popUntil(
                                context, (route) => route.isCurrent);
                          } else {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          }
                        }
                      },
                      child: Text('Từ chối',
                          style: textTheme.titleMedium!.copyWith(
                            color: Colors.red,
                          )),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          elevation: 3,
                          backgroundColor: Colors.green[50],
                          foregroundColor: Colors.green,
                          fixedSize: Size.fromWidth(120),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      onPressed: () async {
                        log('Nhận');
                        final isCancel = await QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          title: 'Xác nhận chấp nhận hồ sơ',
                          text: 'Bạn đã chắc chắn nhận $name?',
                          cancelBtnText: 'Không',
                          confirmBtnText: 'Có',
                          onCancelBtnTap: () {
                            Navigator.pop(context, true);
                          },
                          onConfirmBtnTap: () {
                            Navigator.pop(context, false);
                          },
                        ) as bool;

                        if (context.mounted) {
                          if (isCancel) {
                            Navigator.popUntil(
                                context, (route) => route.isCurrent);
                          } else {
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          }
                        }
                      },
                      child: Text(
                        'Nhận',
                        style: textTheme.titleMedium!.copyWith(
                          color: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Thoát',
                    style:
                        textTheme.bodyLarge!.copyWith(color: Colors.grey[600]),
                  ),
                )
              ],
            ),
          ],
        );
      },
    );
  }

  Container _buildActionButton({
    required BuildContext context,
    void Function()? onDownload,
    void Function()? onPreview,
    void Function()? onUpdate,
  }) {
    return Container(
      child: ListView(
        shrinkWrap: true,
        children: [
          ListTile(
            title: Text(
              'Xem chi tiết',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            leading: Icon(Icons.remove_red_eye),
            onTap: onPreview,
          ),
          Divider(),
          ListTile(
            title: Text(
              'Tải xuống CV',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            leading: Icon(Icons.download),
            onTap: onDownload,
          ),
          Divider(),
          if (onUpdate != null)
            ListTile(
              title: Text(
                'Cập nhật trạng thái',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              leading: Icon(Icons.update),
              onTap: onUpdate,
            ),
        ],
      ),
    );
  }
}
