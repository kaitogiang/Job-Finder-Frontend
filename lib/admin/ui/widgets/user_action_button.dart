import 'package:flutter/material.dart';

class UserActionButton extends StatelessWidget {
  const UserActionButton({
    super.key,
    required this.onViewDetailsPressed,
    this.onLockAccountPressed,
    this.onDeleteAccountPressed,
  });

  final void Function()? onViewDetailsPressed;
  final void Function()? onLockAccountPressed;
  final void Function()? onDeleteAccountPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        IconButton(
          onPressed: onViewDetailsPressed,
          icon: Icon(Icons.remove_red_eye_rounded),
          tooltip: 'Xem chi tiết',
          style: IconButton.styleFrom(
            foregroundColor: Colors.blue,
          ),
        ),
        if (onLockAccountPressed != null)
          IconButton(
            onPressed: onLockAccountPressed,
            icon: Icon(Icons.lock_rounded),
            tooltip: 'Khóa tài khoản',
            style: IconButton.styleFrom(
              foregroundColor: Colors.yellow.shade800,
            ),
          ),
        if (onDeleteAccountPressed != null)
          IconButton(
            onPressed: onDeleteAccountPressed,
            icon: Icon(Icons.delete_rounded),
            tooltip: 'Xóa tài khoản',
            style: IconButton.styleFrom(
              foregroundColor: Colors.red.shade800,
            ),
          ),
      ],
    );
  }
}
