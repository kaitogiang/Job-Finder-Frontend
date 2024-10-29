import 'package:flutter/material.dart';

class ScreenHeader extends StatelessWidget {
  const ScreenHeader({
    super.key,
    required this.title,
  });

  final String title;

  @override
  Widget build(BuildContext context) {
    final titleStyle = Theme.of(context).textTheme;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          Icons.square_outlined,
          color: theme.colorScheme.primary,
        ),
        const SizedBox(width: 5),
        Text(
          title,
          style: titleStyle.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ],
    );
  }
}
