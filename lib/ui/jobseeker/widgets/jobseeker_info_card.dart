import 'package:flutter/material.dart';

class JobseekerInfoCard extends StatelessWidget {
  const JobseekerInfoCard(
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
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          // BoxShadow(
          //   color: Colors.grey.shade200,
          //   spreadRadius: 4,
          //   blurRadius: 2,
          //   offset: const Offset(0, 0),
          // )
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 4,
            blurRadius: 1,
            offset: const Offset(0, 0), // changes position of shadow
          ),
        ],
      ),
      child: Column(
        children: [
          if (iconButton == null)
            const SizedBox(
              height: 10,
            ),
          //Dòng đầu tiên tiêu đề và nút chỉnh sửa thông tin cá nhân
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Tiêu đề thông tin cá nhân
              Text(
                title,
                style:
                    textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              //Nút hành động
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
          //Các con được thêm vào
          ...children,
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
