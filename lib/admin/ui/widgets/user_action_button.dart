import 'package:flutter/material.dart';

class UserActionButton extends StatelessWidget {
  const UserActionButton({
    super.key,
    required this.onViewDetailsPressed,
    this.onLockAccountPressed,
    this.onDeleteAccountPressed,
    this.onUnlockAccountPressed,
    this.isLocked = false,
    this.paddingLeft = 0,
  });

  final void Function()? onViewDetailsPressed;
  final void Function()? onLockAccountPressed;
  final void Function()? onDeleteAccountPressed;
  final void Function()? onUnlockAccountPressed;
  final bool isLocked;
  final double paddingLeft;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: paddingLeft),
      child: Row(
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
          if (onLockAccountPressed != null && !isLocked)
            IconButton(
              onPressed: onLockAccountPressed,
              icon: Icon(Icons.lock_rounded),
              tooltip: 'Khóa tài khoản',
              style: IconButton.styleFrom(
                foregroundColor: Colors.yellow.shade800,
              ),
            ),
          if (onUnlockAccountPressed != null && isLocked)
            IconButton(
              onPressed: onUnlockAccountPressed,
              icon: Icon(Icons.lock_open_rounded),
              tooltip: 'Mở khóa tài khoản',
              style: IconButton.styleFrom(
                foregroundColor: Colors.green.shade800,
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
      ),
    );
  }
}
