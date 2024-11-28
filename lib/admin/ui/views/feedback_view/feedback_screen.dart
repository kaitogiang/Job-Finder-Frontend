import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/widgets/screen_header.dart';

class FeedbackScreen extends StatelessWidget {
  const FeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        //Hiển thị tiêu đề của navigation item
        ScreenHeader(title: 'Phản hồi'),
      ],
    );
  }
}