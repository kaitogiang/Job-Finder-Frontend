import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/utils/admin_enum.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    this.status = ApplicationState.pending,
  });

  final ApplicationState status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: status == ApplicationState.pending
            ? Colors.grey[100]
            : status == ApplicationState.accepted
                ? Colors.green[50]
                : Colors.red[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status == ApplicationState.pending
            ? 'Chưa duyệt'
            : status == ApplicationState.accepted
                ? 'Chấp nhận'
                : 'Từ chối',
        style: textTheme.bodySmall!.copyWith(
            fontSize: 11,
            color: status == ApplicationState.pending
                ? Colors.black87
                : status == ApplicationState.accepted
                    ? Colors.green[700]
                    : Colors.red),
      ),
    );
  }
}
