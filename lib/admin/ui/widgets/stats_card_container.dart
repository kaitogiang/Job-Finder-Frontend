import 'package:flutter/material.dart';

class StatsCardContainer extends StatelessWidget {
  const StatsCardContainer({
    super.key,
    required this.child,
    required this.header,
  });

  final Widget header;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              spreadRadius: 1,
            )
          ]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          SizedBox(
            width: 300,
            child: const Divider(),
          ),
          child,
        ],
      ),
    );
  }
}
