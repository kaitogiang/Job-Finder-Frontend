import 'package:flutter/material.dart';

class UserInfoCard extends StatelessWidget {
  const UserInfoCard(
      {required this.title,
      this.iconButton,
      required this.children,
      super.key});

  final List<Widget> children;
  final IconButton? iconButton;
  final String title;

  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: deviceSize.width - 30,
      // height: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border.all(color: theme.colorScheme.secondary),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            spreadRadius: 4,
            blurRadius: 2,
            offset: const Offset(0, 0),
          )
        ],
      ),
      child: Column(
        children: [
          if (iconButton == null)
            const SizedBox(
              height: 10,
            ),
          //First row containing title and edit personal info button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Personal info title
              Text(
                title,
                style:
                    textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              //Action button
              if (iconButton != null) iconButton!
            ],
          ),
          if (iconButton == null)
            const SizedBox(
              height: 10,
            ),
          Divider(
            thickness: 1,
          ),
          //Added children
          ...children,
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
