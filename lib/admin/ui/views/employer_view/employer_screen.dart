import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';

class EmployerListScreen extends StatelessWidget {
  EmployerListScreen({super.key});
  final List<String> employers = [
    'Employer 1',
    'Employer 2',
    'Employer 3',
    'Employer 4',
    'Employer 5',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Hiển thị tiêu đề của navigation item
        ScreenHeader(title: 'Nhà tuyển dụng'),
      ],
    );
  }
}
