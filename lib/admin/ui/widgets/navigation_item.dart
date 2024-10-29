import 'package:flutter/material.dart';

class NavigationItem extends StatelessWidget {
  const NavigationItem({
    super.key,
    required this.title,
    required this.icon,
    required this.onPressed,
    this.isActive = false,
  });

  final String title;
  final IconData icon;
  final Function() onPressed;
  final bool isActive;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final buttonStyle = TextButton.styleFrom(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      backgroundColor: isActive
          ? theme.colorScheme.primary.withOpacity(0.1)
          : Colors.transparent,
      fixedSize: Size(235, 50),
      alignment: Alignment.centerLeft,
    );
    return TextButton.icon(
      onPressed: onPressed,
      style: buttonStyle,
      icon: Icon(
        icon,
        color: isActive ? theme.colorScheme.primary : Colors.black54,
      ),
      label: Text(
        title,
        style: textTheme.titleMedium!.copyWith(
          fontWeight: FontWeight.bold,
          color: isActive ? theme.colorScheme.primary : Colors.black54,
        ),
      ),
    );
  }
}
