import 'package:flutter/material.dart';
import '../../../models/experience.dart';

class JobseekerExperienceCard extends StatelessWidget {
  const JobseekerExperienceCard({
    Key? key, 
    required this.exp, 
    this.onCustomize
  }) : super(key: key);

  final Experience exp;
  final void Function()? onCustomize;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(top: 10),
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: theme.dividerColor),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildExperienceDetails(textTheme),
          if (onCustomize != null)
            IconButton(
              onPressed: onCustomize,
              icon: const Icon(Icons.more_vert),
            ),
        ],
      ),
    );
  }

  Widget _buildExperienceDetails(TextTheme textTheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildRole(textTheme),
          _buildCompany(textTheme),
          _buildDuration(textTheme),
        ],
      ),
    );
  }

  Widget _buildRole(TextTheme textTheme) {
    return Text(
      exp.role,
      style: textTheme.titleMedium!.copyWith(fontSize: 20),
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildCompany(TextTheme textTheme) {
    return _buildRichText(
      icon: Icons.business,
      text: exp.company,
      textTheme: textTheme,
    );
  }

  Widget _buildDuration(TextTheme textTheme) {
    return _buildRichText(
      icon: Icons.work_history,
      text: exp.duration,
      textTheme: textTheme,
    );
  }

  Widget _buildRichText({
    required IconData icon,
    required String text,
    required TextTheme textTheme,
  }) {
    return RichText(
      overflow: TextOverflow.ellipsis,
      text: TextSpan(
        children: [
          WidgetSpan(
            child: Icon(icon, color: Colors.grey.shade700),
          ),
          const WidgetSpan(
            child: SizedBox(width: 10),
          ),
          TextSpan(text: text),
        ],
        style: textTheme.bodyLarge!.copyWith(
          color: Colors.grey.shade700,
          fontFamily: 'Lato',
          fontSize: 18,
        ),
      ),
    );
  }
}
