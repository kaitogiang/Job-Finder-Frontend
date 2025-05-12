import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
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
    final chipData = [...jobposting.level, jobposting.jobType];
    final formattedDate = DateFormat('dd-MM-yyyy').format(DateTime.parse(jobposting.deadline));

    return GestureDetector(
      onTap: _buildOnTap(context),
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
              _buildJobHeader(context),
              _buildJobDetails(formattedDate, chipData),
            ],
          ),
        ),
      ),
    );
  }

  VoidCallback? _buildOnTap(BuildContext context) {
    if (isEmployer || isAdmin) return null;

    return () {
      final jobseekerId = context.read<JobseekerManager>().jobseeker.id;
      context.read<JobseekerManager>().observeViewJobPostAction(jobseekerId, jobposting.id);
      context.pushNamed('job-detail', extra: jobposting);
    };
  }

  Widget _buildJobHeader(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: _buildCompanyAvatar(),
      title: Text(
        jobposting.title,
        softWrap: true,
        overflow: TextOverflow.ellipsis,
        maxLines: 2,
      ),
      subtitle: Text(
        jobposting.company!.companyName,
        maxLines: 2,
        overflow: TextOverflow.ellipsis
      ),
      trailing: _buildTrailingIcon(context),
    );
  }

  Widget _buildCompanyAvatar() {
    return Container(
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        image: DecorationImage(
          image: NetworkImage(jobposting.company!.avatarLink),
          fit: BoxFit.cover
        )
      ),
    );
  }

  Widget _buildTrailingIcon(BuildContext context) {
    if (isEmployer) {
      return _buildEmployerMenu(context);
    } else if (isAdmin) {
      return _buildAdminMenu(context);
    } else {
      return _buildFavoriteButton(context);
    }
  }

  Widget _buildFavoriteButton(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: jobposting.favorite,
      builder: (context, isFavorite, _) {
        return IconButton(
          icon: Icon(
            isFavorite ? Icons.favorite : Icons.favorite_border,
            color: Colors.blue[400],
          ),
          onPressed: () => _handleFavoritePress(context),
        );
      }
    );
  }

  Future<void> _handleFavoritePress(BuildContext context) async {
    if (!jobposting.isFavorite) {
      final jobseekerId = context.read<JobseekerManager>().jobseeker.id;
      context.read<JobseekerManager>().observeSaveJobPostAction(jobseekerId, jobposting.id);
    }
    await context.read<JobpostingManager>().changeFavoriteStatus(jobposting);
  }

  Widget _buildEmployerMenu(BuildContext context) {
    return IconButton(
      onPressed: () => _showEmployerOptions(context),
      icon: const Icon(Icons.more_vert),
    );
  }

  void _showEmployerOptions(BuildContext context) {
    showAdditionalScreen(
      context: context,
      title: 'Tùy chọn',
      child: Builder(
        builder: (context) => _buildActionButton(
          context: context,
          onDelete: () => _handleDelete(context),
          onEdit: () => _handleEdit(context),
        )
      ),
      heightFactor: 0.3
    );
  }

  Widget _buildAdminMenu(BuildContext context) {
    return IconButton(
      onPressed: () => _showAdminOptions(context),
      icon: const Icon(Icons.more_vert),
    );
  }

  void _showAdminOptions(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    
    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(-40, 0), ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(const Offset(-40, 0)), ancestor: overlay),
      ),
      Offset.zero & overlay.size
    );

    showMenu(
      context: context,
      position: position,
      items: const [
        PopupMenuItem(value: 'detail', child: Text('Xem chi tiết')),
        PopupMenuItem(value: 'require', child: Text('Yêu cầu chỉnh sửa')),
      ]
    );
  }

  Widget _buildJobDetails(String formattedDate, List<String> chipData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          children: chipData.map((label) => ExtraInfoChip(label: label)).toList(),
        ),
        ExtraLabel(
          icon: Icons.timer,
          label: 'Hạn chót: $formattedDate',
        )
      ],
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
          leading: const Icon(Icons.delete),
          onTap: onDelete,
        ),
        const Divider(),
        ListTile(
          title: Text(
            'Chỉnh sửa',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          leading: const Icon(Icons.preview),
          onTap: onEdit,
        ),
      ],
    );
  }

  Future<void> _handleDelete(BuildContext context) async {
    final isAgreed = await QuickAlert.show(
      context: context,
      type: QuickAlertType.confirm,
      title: 'Xác nhận xóa?',
      text: 'Bạn chắc chắn muốn xóa bài đăng này?',
      cancelBtnText: 'Không',
      confirmBtnText: 'Có',
      onCancelBtnTap: () => Navigator.of(context, rootNavigator: true).pop(false),
      onConfirmBtnTap: () => Navigator.of(context, rootNavigator: true).pop(true),
    ) as bool;

    if (!isAgreed) {
      log('Thôi đừng mà');
      return;
    }

    if (!context.mounted) return;
    await context.read<JobpostingManager>().deleteJobposting(jobposting.id);

    if (!context.mounted) return;
    await QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Thành công',
      text: 'Xóa bài đăng thành công',
      autoCloseDuration: const Duration(seconds: 2),
      confirmBtnText: 'Tôi đã biết'
    );

    if (context.mounted) {
      Navigator.pop(context);
    }
  }

  void _handleEdit(BuildContext context) {
    Navigator.pop(context);
    context.pushNamed('jobposting-creation', extra: jobposting);
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
        borderRadius: BorderRadius.circular(10)
      ),
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
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Colors.grey.shade700,
              overflow: TextOverflow.ellipsis
            )
          ),
        )
      ],
    );
  }
}
