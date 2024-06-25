import 'package:flutter/material.dart';

import '../../shared/enums.dart';

class StatusCard extends StatelessWidget {
  const StatusCard({
    super.key,
    this.status = ApplicationStatus.pending,
  });

  final ApplicationStatus status;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 5,
      ),
      decoration: BoxDecoration(
        color: status == ApplicationStatus.pending
            ? Colors.grey[100]
            : status == ApplicationStatus.accepted
                ? Colors.green[50]
                : Colors.red[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        status == ApplicationStatus.pending
            ? 'Chưa duyệt'
            : status == ApplicationStatus.accepted
                ? 'Chấp nhận'
                : 'Từ chối',
        style: textTheme.bodySmall!.copyWith(
            fontSize: 11,
            color: status == ApplicationStatus.pending
                ? Colors.black87
                : status == ApplicationStatus.accepted
                    ? Colors.green[700]
                    : Colors.red),
      ),
    );
  }
}
