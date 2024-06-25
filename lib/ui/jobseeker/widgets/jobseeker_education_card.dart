import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../models/education.dart';

class JobseekerEducationCard extends StatelessWidget {
  const JobseekerEducationCard(
      {super.key, required this.edu, this.onCustomize});

  final Education edu;
  final void Function()? onCustomize;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    log('Gia tri bool');
    return Container(
      margin: EdgeInsets.only(top: 10),
      width: double.maxFinite,
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
          border: Border.all(color: theme.dividerColor),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //Cột để hiển thị tên trường, bằng cách và thời gian học
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                //Hiển thị tên trường
                Text(
                  edu.school,
                  style: textTheme.titleMedium!.copyWith(fontSize: 20),
                ),
                //Hiển thị tên chuyên ngành đã học
                Tooltip(
                  message: edu.specialization,
                  preferBelow: false,
                  child: RichText(
                    text: TextSpan(
                        children: [
                          WidgetSpan(
                              child: Icon(Icons.computer,
                                  color: Colors.grey.shade700)),
                          WidgetSpan(
                              child: const SizedBox(
                            width: 10,
                          )),
                          TextSpan(text: edu.specialization)
                        ],
                        style: textTheme.bodyLarge!.copyWith(
                          color: Colors.grey.shade700,
                          fontFamily: 'Lato',
                          fontSize: 18,
                        )),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                //Hiển thị loại bằng cấp
                RichText(
                  text: TextSpan(
                      children: [
                        WidgetSpan(
                            child: Icon(Icons.school,
                                color: Colors.grey.shade700)),
                        WidgetSpan(
                            child: const SizedBox(
                          width: 10,
                        )),
                        TextSpan(text: edu.degree)
                      ],
                      style: textTheme.bodyLarge!.copyWith(
                          color: Colors.grey.shade700,
                          fontFamily: 'Lato',
                          fontSize: 18)),
                ),
                //Hiển thị thời gian bắt đầu và kết thúc học
                RichText(
                  text: TextSpan(
                      children: [
                        WidgetSpan(
                            child: Icon(
                          Icons.access_time_filled,
                          color: Colors.grey.shade700,
                        )),
                        WidgetSpan(
                            child: const SizedBox(
                          width: 10,
                        )),
                        TextSpan(text: '${edu.startDate} - ${edu.endDate}')
                      ],
                      style: textTheme.bodyLarge!.copyWith(
                          color: Colors.grey.shade700,
                          fontFamily: 'Lato',
                          fontSize: 18)),
                ),
              ],
            ),
          ),
          //Nút tùy chỉnh kinh nghiệm gồm chỉnh sửa, xóa
          if (onCustomize != null)
            IconButton(
              onPressed: onCustomize,
              icon: Icon(Icons.more_vert),
            )
        ],
      ),
    );
  }
}
