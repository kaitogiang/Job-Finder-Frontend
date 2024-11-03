import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/ui/shared/jobposting_manager.dart';
import 'package:provider/provider.dart';
import 'package:quickalert/quickalert.dart';

import '../../models/jobposting.dart';
import 'modal_bottom_sheet.dart';

class JobCard extends StatelessWidget {
  const JobCard(
    this.jobposting, {
    super.key,
    this.isEmployer = false,
    this.isAdmin = false,
  });

  final Jobposting jobposting;
  final bool isEmployer;
  final bool isAdmin;

  @override
  Widget build(BuildContext context) {
    List<String> chipData = [];
    chipData.addAll(jobposting.level);
    chipData.add(jobposting.jobType);
    //todo Chuyển đổi chuỗi ngày sang đối tượng DateTime và sau đó chuyển định
    //todo dạng sang dd-MM-yyyy
    DateTime dateTime = DateTime.parse(jobposting.deadline);
    String formatedDate = DateFormat('dd-MM-yyyy').format(dateTime);

    return GestureDetector(
      onTap: !isEmployer && !isAdmin
          ? () => context.pushNamed('job-detail', extra: jobposting)
          : null,
      child: Card(
        borderOnForeground: true,
        surfaceTintColor: Colors.blue[100],
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  height: 60,
                  width: 60,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                          image: NetworkImage(jobposting.company!.avatarLink),
                          fit: BoxFit.cover)),
                ),
                title: Text(
                  jobposting.title,
                  softWrap: true,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                subtitle: Text(jobposting.company!.companyName,
                    maxLines: 2, overflow: TextOverflow.ellipsis),
                trailing: ValueListenableBuilder(
                    valueListenable: jobposting.favorite,
                    builder: (context, isFavorite, child) {
                      return !isEmployer && !isAdmin
                          ? IconButton(
                              icon: Icon(
                                !isFavorite
                                    ? Icons.favorite_border
                                    : Icons.favorite,
                                color: Colors.blue[400],
                              ),
                              onPressed: () async {
                                await context
                                    .read<JobpostingManager>()
                                    .changeFavoriteStatus(jobposting);
                              },
                            )
                          : isEmployer
                              ? IconButton(
                                  onPressed: () {
                                    log('Menu cho employer');
                                    showAdditionalScreen(
                                        context: context,
                                        title: 'Tùy chọn',
                                        child: Builder(builder: (context) {
                                          return _buildActionButton(
                                            context: context,
                                            onDelete: () async {
                                              log('Xóa bỏ kinh nghiệm');
                                              final isAgreed =
                                                  await QuickAlert.show(
                                                      context: context,
                                                      type: QuickAlertType
                                                          .confirm,
                                                      title: 'Xác nhận xóa?',
                                                      text:
                                                          'Bạn chắc chắn muốn xóa bài đăng này?',
                                                      cancelBtnText: 'Không',
                                                      confirmBtnText: 'Có',
                                                      onCancelBtnTap: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop(false);
                                                      },
                                                      onConfirmBtnTap: () {
                                                        Navigator.of(context,
                                                                rootNavigator:
                                                                    true)
                                                            .pop(true);
                                                      }) as bool;
                                              if (isAgreed) {
                                                log('Xóa nhe bồ');
                                                if (!context.mounted) return;
                                                await context
                                                    .read<JobpostingManager>()
                                                    .deleteJobposting(
                                                        jobposting.id);
                                                if (!context.mounted) return;
                                                await QuickAlert.show(
                                                    context: context,
                                                    type:
                                                        QuickAlertType.success,
                                                    title: 'Thành công',
                                                    text:
                                                        'Xóa bài đăng thành công',
                                                    autoCloseDuration:
                                                        const Duration(
                                                            seconds: 2),
                                                    confirmBtnText:
                                                        'Tôi đã biết');
                                              } else {
                                                log('Thôi đừng mà');
                                              }

                                              if (context.mounted) {
                                                Navigator.pop(context);
                                              }
                                            },
                                            onEdit: () {
                                              log('Xem trước file');
                                              Navigator.pop(context);
                                              context.pushNamed(
                                                  'jobposting-creation',
                                                  extra: jobposting);
                                            },
                                          );
                                        }),
                                        heightFactor: 0.3);
                                  },
                                  icon: const Icon(Icons.more_vert),
                                )
                              : IconButton(
                                  onPressed: () {
                                    log('Menu cho admin');
                                    final RenderBox button =
                                        context.findRenderObject() as RenderBox;
                                    final RenderBox overlay =
                                        Overlay.of(context)
                                            .context
                                            .findRenderObject() as RenderBox;
                                    final RelativeRect position =
                                        RelativeRect.fromRect(
                                            Rect.fromPoints(
                                              button.localToGlobal(
                                                  Offset(-40, 0),
                                                  ancestor: overlay),
                                              button.localToGlobal(
                                                  button.size.bottomRight(
                                                      Offset(-40, 0)),
                                                  ancestor: overlay),
                                            ),
                                            Offset.zero & overlay.size);
                                    showMenu(
                                        context: context,
                                        position: position,
                                        items: [
                                          PopupMenuItem(
                                            value: 'detail',
                                            child: Text('Xem chi tiết'),
                                          ),
                                          PopupMenuItem(
                                            value: 'require',
                                            child: Text('Yêu cầu chỉnh sửa'),
                                          ),
                                        ]);
                                  },
                                  icon: const Icon(Icons.more_vert),
                                );
                    }),
              ),
              ExtraLabel(
                icon: Icons.location_on,
                label: jobposting.workLocation,
              ),
              ExtraLabel(
                icon: Icons.attach_money_outlined,
                label: jobposting.salary,
              ),
              Wrap(
                spacing: 8,
                direction: Axis.horizontal,
                runSpacing: 0,
                children: List<Widget>.generate(
                  chipData.length,
                  (index) => ExtraInfoChip(label: chipData[index]),
                ),
              ),
              ExtraLabel(
                icon: Icons.timer,
                label: 'Hạn chót: $formatedDate',
              )
            ],
          ),
        ),
      ),
    );
  }

  ListView _buildActionButton({
    required BuildContext context,
    void Function()? onDelete,
    void Function()? onEdit,
  }) {
    return ListView(
      shrinkWrap: true,
      children: [
        ListTile(
          title: Text(
            'Xóa bỏ',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: Icon(Icons.delete),
          onTap: onDelete,
        ),
        Divider(),
        ListTile(
          title: Text(
            'Chỉnh sửa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: Icon(Icons.preview),
          onTap: onEdit,
        ),
      ],
    );
  }
}

class ExtraInfoChip extends StatelessWidget {
  const ExtraInfoChip({super.key, required this.label});
  final String label;
  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.blueAccent),
        overflow: TextOverflow.ellipsis,
      ),
      backgroundColor: Colors.lightBlueAccent[50],
      padding: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue[200]!),
          borderRadius: BorderRadius.circular(10)),
    );
  }
}

class ExtraLabel extends StatelessWidget {
  const ExtraLabel({
    super.key,
    required this.icon,
    required this.label,
  });
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(
          icon,
          color: Colors.grey.shade700,
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(label,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                  color: Colors.grey.shade700,
                  overflow: TextOverflow.ellipsis)),
        )
      ],
    );
  }
}
