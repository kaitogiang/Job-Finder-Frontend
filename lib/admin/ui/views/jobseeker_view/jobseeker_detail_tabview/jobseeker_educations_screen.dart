import 'package:flutter/material.dart';
import 'package:job_finder_app/models/education.dart';
import 'package:job_finder_app/ui/jobseeker/widgets/jobseeker_education_card.dart';

class JobseekerEducationsScreen extends StatelessWidget {
  const JobseekerEducationsScreen({super.key, required this.eduList});

  final List<Education> eduList;

  @override
  Widget build(BuildContext context) {
    return eduList.isEmpty
        ? const Center(child: Text('Ứng viên chưa thiết lập học vấn'))
        : Padding(
            padding:
                const EdgeInsets.only(left: 10, right: 10, top: 15, bottom: 15),
            child: ListView(
              children: [
                ...List<Widget>.generate(eduList.length, (index) {
                  return Transform.scale(
                    scale: 0.9,
                    child: JobseekerEducationCard(
                      edu: eduList[index],
                    ),
                  );
                }),
              ],
            ),
          );
  }
}
