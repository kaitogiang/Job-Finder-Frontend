import 'package:flutter/material.dart';
import 'package:job_finder_app/models/experience.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_experience_card.dart';

class JobseekerExperiencesScreen extends StatelessWidget {
  const JobseekerExperiencesScreen({super.key, required this.expList});

  final List<Experience> expList;

  @override
  Widget build(BuildContext context) {
    return expList.isEmpty
        ? const Center(child: Text('Ứng viên chưa thiết lập kinh nghiệm'))
        : Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
            child: ListView(
              children: [
                ...List<Widget>.generate(expList.length, (index) {
                  return Transform.scale(
                    scale: 0.9,
                    child: JobseekerExperienceCard(exp: expList[index]),
                  );
                }),
              ],
            ),
          );
  }
}
