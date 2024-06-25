import 'package:flutter/material.dart';

import '../../../models/experience.dart';

class JobseekerExperienceCard extends StatelessWidget {
  const JobseekerExperienceCard(
      {super.key, required this.exp, this.onCustomize});

  final Experience exp;
  final void Function()? onCustomize;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

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
          //Cột để hiển thị tên vị trí, công ty và thời gian làm
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                exp.role,
                style: textTheme.titleMedium!.copyWith(fontSize: 20),
              ),
              RichText(
                text: TextSpan(
                    children: [
                      WidgetSpan(
                          child: Icon(Icons.business,
                              color: Colors.grey.shade700)),
                      WidgetSpan(
                          child: const SizedBox(
                        width: 10,
                      )),
                      TextSpan(text: exp.company)
                    ],
                    style: textTheme.bodyLarge!.copyWith(
                        color: Colors.grey.shade700,
                        fontFamily: 'Lato',
                        fontSize: 18)),
              ),
              RichText(
                text: TextSpan(
                    children: [
                      WidgetSpan(
                          child: Icon(Icons.work_history,
                              color: Colors.grey.shade700)),
                      WidgetSpan(
                          child: const SizedBox(
                        width: 10,
                      )),
                      TextSpan(text: exp.duration)
                    ],
                    style: textTheme.bodyLarge!.copyWith(
                        color: Colors.grey.shade700,
                        fontFamily: 'Lato',
                        fontSize: 18)),
              ),
            ],
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
