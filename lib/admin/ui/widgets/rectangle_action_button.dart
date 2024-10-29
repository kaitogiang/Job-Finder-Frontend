import 'package:flutter/material.dart';

class RectangleActionButton extends StatelessWidget {
  const RectangleActionButton({
    super.key,
    required this.title,
    required this.onPressed,
  });

  final String title;
  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = Theme.of(context).textTheme;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        minimumSize: Size(double.infinity, 50), // Full-width button
        backgroundColor: theme.colorScheme.primary,
      ),
      child: Text(
        title,
        style: textStyle.titleMedium!.copyWith(
          color: theme.colorScheme.onPrimary,
          fontSize: 18,
        ),
      ),
    );
  }
}
