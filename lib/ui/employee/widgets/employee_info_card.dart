import 'dart:developer';

import 'package:flutter/material.dart';

class EmployeeInfoCard extends StatelessWidget {
  const EmployeeInfoCard({this.iconButton, required this.children, super.key});

  final List<Widget> children;
  final IconButton? iconButton;
  
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      width: deviceSize.width - 30,
      height: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.background,
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
          //Dòng đầu tiên tiêu đề và nút chỉnh sửa thông tin cá nhân
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Tiêu đề thông tin cá nhân
              Text(
                'Thông tin cá nhân',
                style:
                    textTheme.titleLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
              //Nút hành động
              if(iconButton!=null) 
              iconButton!
            ],
          ),
          Divider(
            thickness: 1,
          ),
          //Các con được thêm vào
          ...children
        ],
      ),
    );
  }
}
