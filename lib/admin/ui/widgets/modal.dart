import 'package:flutter/material.dart';
import 'package:job_finder_app/admin/ui/base_layout_page.dart';

class Modal extends StatelessWidget {
  const Modal({
    super.key,
    required this.headerIcon,
    required this.title,
    required this.content,
  });

  final String headerIcon;
  final String title;
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      backgroundColor: const Color(0xFFF2F6FF),
      title: Row(
        children: [
          Image.asset(
            headerIcon,
            width: 30,
            height: 30,
          ),
          const SizedBox(width: 10),
          Text(
            title,
            style: textTheme.titleLarge!.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Align(
              alignment: Alignment.topRight,
              child: IconButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                },
                icon: const Icon(Icons.close),
              ),
            ),
          ),
        ],
      ),
      content: content,
    );
  }
}
