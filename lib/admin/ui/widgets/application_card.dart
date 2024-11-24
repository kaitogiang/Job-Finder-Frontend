import 'dart:math' as math;
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:job_finder_app/admin/ui/manager/application_list_manager.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';
import 'package:job_finder_app/admin/ui/utils/utils.dart';
import 'package:job_finder_app/admin/ui/widgets/status_card.dart';
import 'package:job_finder_app/ui/employer/application_manager.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../../../models/application.dart';

//! Card dùng để hiển thị một hồ sơ đã nộp của một ứng viên
class ApplicationCard extends StatefulWidget {
  const ApplicationCard({
    super.key,
    this.status = ApplicationState.pending,
    required this.application, //TODO chuyển về required
    this.isRead = false,
    this.jobpostingId,
  });

  final ApplicationState status;
  final Application application;
  final bool isRead;
  final String? jobpostingId;

  @override
  State<ApplicationCard> createState() => _ApplicationCardState();
}

class _ApplicationCardState extends State<ApplicationCard> {
  final GlobalKey _buttonKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final name = widget.application.name;
    final email = widget.application.email;
    final phone = widget.application.phone;
    final buttonTextStyle = switch (widget.status) {
      ApplicationState.pending =>
        TextStyle(color: Theme.of(context).colorScheme.primary),
      ApplicationState.accepted => TextStyle(color: Colors.green),
      ApplicationState.rejected => TextStyle(color: Colors.red)
    };
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: widget.status == ApplicationState.pending
              ? Colors.grey
              : widget.status == ApplicationState.accepted
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
              status: widget.status,
            ),
          ],
        ),
        trailing: TextButton(
          key: _buttonKey,
          onPressed: () {
            //Nút hành động, hiển thị một menu anchor mới để cho phép
            //thao tác tải cv hoặc làm gì khác
            _showMenuAction(context, widget.application);
          },
          child: Text(
            'Tùy chọn',
            style: buttonTextStyle,
          ),
        ),
      ),
    );
  }

  void _showMenuAction(BuildContext context, Application application) {
    final cvLink = application.resume;
    //lấy khung hình vẽ của button được nhấn
    final RenderBox button =
        _buttonKey.currentContext!.findRenderObject() as RenderBox;
    //Lấy khung hình vẽ của menu được hiển thị overlay
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    //Định vị trí của khung hình vẽ của overlay so với khung hình vẽ của button
    final RelativeRect position = RelativeRect.fromRect(
        Rect.fromPoints(
          button.localToGlobal(Offset(-80, 0), ancestor: overlay),
          button.localToGlobal(button.size.bottomRight(Offset(-80, 0)),
              ancestor: overlay),
        ),
        Offset.zero & overlay.size);
    showMenu(context: context, position: position, items: [
      PopupMenuItem(
        value: 'view-cv',
        child: Text('Xem CV'),
        onTap: () async {
          await context.read<ApplicationListManager>().viewJobseekerCV(cvLink);
        },
      ),
      PopupMenuItem(
        value: 'download-cv',
        child: Text('Tải xuống CV'),
        onTap: () async {
          final filename = '${application.name}_${application.jobseekerId}.pdf';
          await context
              .read<ApplicationListManager>()
              .downloadJobseekerCV(cvLink, filename);
        },
      ),
      PopupMenuItem(
        value: 'view-info',
        child: Text('Xem hồ sơ ứng viên'),
        onTap: () {
          GoRouter.of(context)
              .push('/jobseeker/profile/${application.jobseekerId}');
        },
      ),
    ]);
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
                          fixedSize: const Size.fromWidth(120),
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
                                .rejectApplication(
                                    widget.jobpostingId!, application);
                            if (context.mounted) {
                              Navigator.popUntil(
                                  context,
                                  (route) =>
                                      route.settings.name ==
                                      'application-detail');
                            }
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
                          fixedSize: const Size.fromWidth(120),
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
                                .approveApplication(
                                    application, widget.jobpostingId!);
                            if (context.mounted) {
                              Navigator.popUntil(
                                  context,
                                  (route) =>
                                      route.settings.name ==
                                      'application-detail');
                            }
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

  ListView _buildActionButton({
    required BuildContext context,
    void Function()? onDownload,
    void Function()? onPreview,
    void Function()? onUpdate,
  }) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text(
            'Xem chi tiết',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: const Icon(Icons.remove_red_eye),
          onTap: onPreview,
        ),
        const Divider(),
        ListTile(
          title: Text(
            'Tải xuống CV',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: const Icon(Icons.download),
          onTap: onDownload,
        ),
        const Divider(),
        if (onUpdate != null)
          ListTile(
            title: Text(
              'Cập nhật trạng thái',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            leading: const Icon(Icons.update),
            onTap: onUpdate,
          ),
      ],
    );
  }
}
