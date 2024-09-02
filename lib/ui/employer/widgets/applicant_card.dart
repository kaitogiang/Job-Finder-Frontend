import 'dart:developer';
import 'dart:math' as math;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../../../models/application.dart';
import '../../shared/enums.dart';
import '../../shared/modal_bottom_sheet.dart';
import 'status_card.dart';
import '../../shared/utils.dart';

//! Card dùng để hiển thị một hồ sơ đã nộp của một ứng viên
class ApplicantCard extends StatelessWidget {
  const ApplicantCard({
    super.key,
    this.status = ApplicationStatus.pending,
    required this.application,
    this.isRead = false,
    this.jobpostingId,
  });

  final ApplicationStatus status;
  final Application application;
  final bool isRead;
  final String? jobpostingId;
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
                      Utils.logMessage('Xem chi tiết profile');
                      context.pushNamed('jobseeker-detail',
                          extra: application.jobseekerId);
                      Navigator.pop(context);
                    },
                    onDownload: () async {
                      Utils.logMessage('Tải xuống CV');
                      bool isAllowedToSendNotification =
                          await AwesomeNotifications().isNotificationAllowed();
                      if (!isAllowedToSendNotification) {
                        AwesomeNotifications()
                            .requestPermissionToSendNotifications();
                      }
                      Utils.logMessage('Path la: ${application.resume}');
                      final path = await context
                          .read<ApplicationManager>()
                          .downloadFile(application.resume,
                              'CV_${name}_${DateTime.now().millisecond}${DateTime.now().minute}.pdf');
                      if (path != null) {
                        QuickAlert.show(
                            context: context,
                            type: QuickAlertType.info,
                            title: 'Tải xuống thành công',
                            text: 'File được tải xuống tại $path',
                            confirmBtnText: 'Tôi biết rồi');
                      }

                      int random = math.Random(10).nextInt(1000);
                      AwesomeNotifications().createNotification(
                        content: NotificationContent(
                          id: random,
                          channelKey: 'basic_channel',
                          actionType: ActionType.Default,
                          title: 'Tải xuống thành công',
                          body:
                              'Tại xuống tại thư mục /storage/emulated/0/Download/, nhấn vào để mở',
                        ),
                      );
                    },
                    onUpdate: !isRead
                        ? () {
                            Utils.logMessage(
                                'Cập nhật trạng thái cho ứng viên này');
                            _showMyDialog(context, application);
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

  Future<void> _showMyDialog(
      BuildContext context, Application application) async {
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
              TextSpan(
                  text: ' hồ sơ của ${application.name}?',
                  style: textTheme.bodyLarge)
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
                        Utils.logMessage('Từ chối');
                        final isCancel = await QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          title: 'Xác nhận từ chối hồ sơ',
                          text: 'Bạn đã chắc chắn từ chối ${application.name}?',
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
                            await context
                                .read<ApplicationManager>()
                                .rejectApplication(jobpostingId!, application);
                            Navigator.popUntil(
                                context,
                                (route) =>
                                    route.settings.name ==
                                    'application-detail');
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
                        Utils.logMessage('Nhận');
                        final isCancel = await QuickAlert.show(
                          context: context,
                          type: QuickAlertType.confirm,
                          title: 'Xác nhận chấp nhận hồ sơ',
                          text: 'Bạn đã chắc chắn nhận ${application.name}?',
                          cancelBtnText: 'Không',
                          confirmBtnText: 'Có',
                          onCancelBtnTap: () {
                            Navigator.pop(context, true);
                          },
                          onConfirmBtnTap: () async {
                            Navigator.pop(context, false);
                          },
                        ) as bool;

                        if (context.mounted) {
                          if (isCancel) {
                            Navigator.popUntil(
                                context, (route) => route.isCurrent);
                          } else {
                            await context
                                .read<ApplicationManager>()
                                .approveApplication(application, jobpostingId!);
                            Navigator.popUntil(
                                context,
                                (route) =>
                                    route.settings.name ==
                                    'application-detail');
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
