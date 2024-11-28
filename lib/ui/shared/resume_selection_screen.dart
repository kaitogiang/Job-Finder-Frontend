import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:job_finder_app/ui/jobseeker/jobseeker_manager.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:provider/provider.dart';

class ResumeSelectionScreen extends StatelessWidget {
  const ResumeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = Theme.of(context).textTheme;
    final selectedIndex = ValueNotifier(-1);
    return Consumer<JobseekerManager>(
        builder: (context, jobseekerManager, child) {
      final resume = jobseekerManager.resumes;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RichText(
            textAlign: TextAlign.left,
            text: TextSpan(children: [
              WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Icon(
                  Icons.add_circle,
                  color: Colors.blue,
                ),
              ),
              const WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              TextSpan(
                text: 'CV đã tạo:',
                style: textTheme.bodyLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const WidgetSpan(
                  child: SizedBox(
                width: 5,
              )),
              TextSpan(
                text: '${resume.length}',
                style: textTheme.bodyLarge,
              )
            ]),
          ),
          Expanded(
            child: ValueListenableBuilder(
                valueListenable: selectedIndex,
                builder: (context, choosedIndex, child) {
                  return ListView.separated(
                    separatorBuilder: (context, index) => const Divider(),
                    itemCount: resume.length,
                    itemBuilder: (context, index) {
                      final date = resume[index].uploadedDate;
                      final formattedDate =
                          DateFormat('dd/MM/yyyy h:mm a').format(date);
                      bool isSelected = choosedIndex == index;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 0),
                        child: ListTile(
                          title: Text(
                            resume[index].fileName,
                            style: textTheme.bodyLarge!
                                .copyWith(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(formattedDate),
                          leading: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.blue,
                                )
                              : Icon(Icons.circle_outlined),
                          onTap: () => selectedIndex.value = index,
                        ),
                      );
                    },
                  );
                }),
          ),
          //Nút để xác nhận tùy chọn
          ValueListenableBuilder(
              valueListenable: selectedIndex,
              builder: (context, choosedIndex, child) {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      elevation: 3,
                      fixedSize: const Size.fromHeight(50),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: theme.colorScheme.onPrimary,
                      backgroundColor: theme.primaryColor,
                      textStyle: textTheme.titleMedium),
                  onPressed: choosedIndex == -1
                      ? null
                      : () {
                          Navigator.of(context, rootNavigator: true)
                              .pop(selectedIndex.value);
                        },
                  child: Text(
                    'CHỌN CV',
                  ),
                );
              }),
        ],
      );
    });
  }
}
