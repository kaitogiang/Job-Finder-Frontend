import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';

class JobseekerInfoScreen extends StatelessWidget {
  const JobseekerInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Hiển thị tiêu đề của navigation item
        ScreenHeader(title: 'Ứng viên - detail'),
        //Hiển thị thông tin chi tiết của ứng viên
        Text('Ứng viên detail đây')
      ],
    );
  }
}
