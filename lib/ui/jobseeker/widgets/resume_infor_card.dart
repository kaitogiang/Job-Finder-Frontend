import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/models/resume.dart';

class ResumeInforCard extends StatelessWidget {
  const ResumeInforCard({
    Key? key,
    required this.resume,
    this.onAction,
  }) : super(key: key);

  final Resume resume;
  final void Function()? onAction;

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    return Container(
        margin: EdgeInsets.only(top: 10),
        width: double.infinity,
        padding: EdgeInsets.all(10),
        height: 80,
        decoration: BoxDecoration(
            border: Border.all(color: theme.dividerColor),
            borderRadius: BorderRadius.circular(15)),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildResumeDetails(textTheme, formatter),
            _buildActionColumn()
          ],
        ));
  }

  Widget _buildResumeDetails(TextTheme textTheme, DateFormat formatter) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            resume.fileName,
            style: textTheme.titleMedium!.copyWith(fontSize: 20),
            overflow: TextOverflow.ellipsis,
          ),
          RichText(
            text: TextSpan(
                children: [
                  WidgetSpan(child: Icon(Icons.attach_file)),
                  WidgetSpan(
                      child: const SizedBox(
                    width: 10,
                  )),
                  TextSpan(
                      text:
                          'Đã tải lên: ${formatter.format(resume.uploadedDate)}')
                ],
                style: textTheme.bodyLarge!.copyWith(
                    color: Colors.grey.shade700,
                    fontFamily: 'Lato',
                    fontSize: 15)),
          )
        ],
      ),
    );
  }

  Widget _buildActionColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        IconButton(
          onPressed: onAction,
          icon: Icon(Icons.more_vert),
        )
      ],
    );
  }
}
