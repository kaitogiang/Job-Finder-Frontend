import 'package:flutter/material.dart';

class JobseekerInfoCard extends StatelessWidget {
  const JobseekerInfoCard({
    Key? key,
    required this.title,
    this.iconButton,
    required this.children,
  }) : super(key: key);

  final List<Widget> children;
  final IconButton? iconButton;
  final String title;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: deviceSize.width - 30,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          if (iconButton == null)
            const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              if (iconButton != null) iconButton!,
            ],
          ),
          if (iconButton == null)
            const SizedBox(height: 10),
          const Divider(thickness: 1),
          ...children,
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
