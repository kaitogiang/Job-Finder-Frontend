import 'package:flutter/material.dart';

class JobseekerSkillsScreen extends StatelessWidget {
  const JobseekerSkillsScreen({
    super.key,
    required this.techList,
  });

  final List<String> techList;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return techList.isEmpty
        ? const Center(child: Text('Ứng viên chưa thiết lập kỹ năng'))
        : Padding(
            padding:
                const EdgeInsets.only(left: 20, right: 20, top: 15, bottom: 10),
            child: ListView(
              children: [
                Wrap(
                  direction: Axis.horizontal,
                  spacing: 10,
                  runSpacing: 10,
                  children: List<Widget>.generate(techList.length, (index) {
                    return InputChip(
                      label: Text(
                        techList[index],
                        style: TextStyle(
                          color: theme.primaryColor,
                        ),
                      ),
                      elevation: 2,
                      padding: const EdgeInsets.symmetric(
                          vertical: 6, horizontal: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: BorderSide(
                          color: Colors.grey[400]!,
                        ),
                      ),
                      backgroundColor: Colors.blue[200],
                      color: WidgetStateColor.resolveWith((state) {
                        return Colors.blue[50]!;
                      }),
                      onSelected: (value) {},
                    );
                  }),
                ),
              ],
            ),
          );
  }
}
