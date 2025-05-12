import 'package:flutter/material.dart';
import '../../../models/education.dart';

class JobseekerEducationCard extends StatelessWidget {
  const JobseekerEducationCard({Key? key, required this.edu, this.onCustomize}) : super(key: key);

  final Education edu;
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
          _buildEducationDetails(textTheme),
          if (onCustomize != null)
            IconButton(
              onPressed: onCustomize,
              icon: Icon(Icons.more_vert),
            )
        ],
      ),
    );
  }

  Widget _buildEducationDetails(TextTheme textTheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildSchoolName(textTheme),
          _buildSpecialization(textTheme),
          _buildDegree(textTheme),
          _buildStudyPeriod(textTheme),
        ],
      ),
    );
  }

  Widget _buildSchoolName(TextTheme textTheme) {
    return Text(
      edu.school,
      style: textTheme.titleMedium!.copyWith(fontSize: 20),
    );
  }

  Widget _buildSpecialization(TextTheme textTheme) {
    return Tooltip(
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
    );
  }

  Widget _buildDegree(TextTheme textTheme) {
    return RichText(
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
    );
  }

  Widget _buildStudyPeriod(TextTheme textTheme) {
    return RichText(
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
    );
  }
}
