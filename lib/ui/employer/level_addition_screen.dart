import 'package:flutter/material.dart';

class LevelAdditionScreen extends StatelessWidget {
  const LevelAdditionScreen(
      {this.existingLevel, required this.onSaved, super.key});

  final List<String>? existingLevel;
  final void Function(List<String>) onSaved;

  @override
  Widget build(BuildContext context) {
    //todo Gợi ý sẽ hiển thị khi nhập vào ô kỹ năng
    //todo Biến dùng để quan sát những kỹ năng được thêm vào
    ValueNotifier<int> selectionListenable =
        ValueNotifier(existingLevel?.length ?? 0);

    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    Size deviceSize = MediaQuery.of(context).size;
    List<String> level = [
      'Intern',
      'Fresher',
      'Junior',
      'Middle',
      'Senior',
      'Leader',
      'Manager'
    ];
    Set<String> selection = existingLevel?.toSet() ?? {};
    ValueNotifier<List<String>> selectedLevel =
        ValueNotifier(existingLevel ?? []);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Công nghệ yêu cầu"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Chọn trình độ tương ứng với công việc cần tuyển dụng',
              style: textTheme.bodyLarge,
            ),
            const SizedBox(
              height: 6,
            ),
            Wrap(
              direction: Axis.horizontal,
              spacing: 10,
              children: List<Widget>.generate(level.length, (index) {
                return Transform.scale(
                  scale: 1.05,
                  child: StatefulBuilder(builder: (context, setState) {
                    bool isSelected = selection.contains(level[index]);
                    return InputChip(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 3,
                        vertical: 3,
                      ),
                      elevation: isSelected ? 4 : 0,
                      selected: isSelected,
                      label: Text(
                        level[index],
                        style: TextStyle(
                          color:
                              isSelected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                      color: WidgetStateColor.resolveWith((state) {
                        if (state.isNotEmpty) {
                          return Colors.blueAccent.shade200;
                        }
                        return Colors.transparent;
                      }),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                        side: BorderSide(
                          color: Colors.grey[400]!,
                        ),
                      ),
                      avatar: CircleAvatar(
                        radius: 20,
                        //Active sẽ là màu primary và Text là White
                        //Bình thường thì là màu  Colors.blue[300]
                        backgroundColor:
                            isSelected ? theme.primaryColor : Colors.blue[300],
                        child: Text(
                          level[index].characters.first,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      showCheckmark: false,
                      onPressed: () {
                        setState(() {
                          if (isSelected) {
                            selection.remove(level[index]);
                            selectionListenable.value--;
                            //todo tạo list mới và gán để cập nhật lại ValueNotifier
                            List<String> selected =
                                List<String>.from(selection);
                            selectedLevel.value = selected;
                          } else {
                            selection.add(level[index]);
                            selectionListenable.value++;
                            //todo tạo list mới và gán để cập nhật lại ValueNotifier
                            List<String> selected =
                                List<String>.from(selection);
                            selectedLevel.value = selected;
                          }
                        });
                      },
                    );
                  }),
                );
              }),
            ),
            //todo: Hiển thị những trình độ được thêm vào bởi người dùng
            const SizedBox(
              height: 6,
            ),
            const Divider(),
            const SizedBox(
              height: 6,
            ),
            Expanded(
              child: ValueListenableBuilder(
                  valueListenable: selectedLevel,
                  builder: (context, levelList, child) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Các trình độ đã chọn: ${levelList.length}',
                          style: textTheme.titleMedium!.copyWith(
                            fontSize: 17,
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: levelList.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: const Icon(
                                  Icons.check_circle_outline,
                                  color: Colors.green,
                                ),
                                contentPadding: EdgeInsets.zero,
                                title: Text(levelList[index]),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  }),
            ),
            const SizedBox(
              height: 10,
            ),
            //todo: Nút dùng để lưu những kỹ năng vào
            ValueListenableBuilder<int>(
                valueListenable: selectionListenable,
                builder: (context, selectionNumber, child) {
                  return ElevatedButton(
                    onPressed: selectionNumber == 0
                        ? null
                        : () {
                            onSaved.call(selectedLevel.value);
                            Navigator.of(context).pop();
                          },
                    child: Text("LƯU"),
                    style: ElevatedButton.styleFrom(
                        disabledBackgroundColor: Colors.grey.shade300,
                        fixedSize: Size(deviceSize.width, 60),
                        backgroundColor: theme.primaryColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        foregroundColor: theme.colorScheme.onPrimary,
                        textStyle: textTheme.titleMedium),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
