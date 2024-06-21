import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/shared/addition_data.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:quickalert/quickalert.dart';

class TechAdditionScreen extends StatefulWidget {
  const TechAdditionScreen({super.key, required this.onSaved, this.techList});

  final void Function(List<String>) onSaved;
  final List<String>? techList;
  @override
  State<TechAdditionScreen> createState() => _TechAdditionScreenState();
}

class _TechAdditionScreenState extends State<TechAdditionScreen> {
  //TODO: Gợi ý sẽ hiển thị khi nhập vào ô kỹ năng
  final List<String> _options = List<String>.from(getTechnologyList);
  //TODO: Biến dùng để quan sát những kỹ năng được thêm vào
  ValueNotifier<List<String>> _skillsListenable = ValueNotifier([]);

  late TextEditingController? _skillController = TextEditingController();

  @override
  void initState() {
    _skillsListenable.value = widget.techList ?? [];
    super.initState();
  }

  @override
  void dispose() {
    log('dispose');
    // _skillController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: Text("Công nghệ yêu cầu"),
      ),
      body: Container(
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            //TODO: Hiển thị trường nhập và nút bấm để thêm kỹ năng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Expanded(
                  child: Autocomplete<String>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<String>.empty();
                      }
                      return _options.where((option) {
                        return option
                            .toLowerCase()
                            .contains(textEditingValue.text.toLowerCase());
                      });
                    },
                    onSelected: (option) {
                      log('Bạn đã chọn ${option}');
                    },
                    fieldViewBuilder: ((context, textEditingController,
                        focusNode, onFieldSubmitted) {
                      _skillController = textEditingController;
                      return TextFormField(
                        controller: textEditingController,
                        focusNode: focusNode,
                        onFieldSubmitted: (String value) {
                          onFieldSubmitted();
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          constraints:
                              BoxConstraints.tight(Size.fromHeight(60)),
                          labelText: 'Thêm công nghệ yêu cầu',
                          prefixIcon: Icon(Icons.code),
                        ),
                        textInputAction: TextInputAction.search,
                      );
                    }),
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            child: ListView.builder(
                              padding: EdgeInsets.all(8.0),
                              itemCount: options.length,
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return GestureDetector(
                                  onTap: () {
                                    onSelected(option);
                                  },
                                  child: ListTile(
                                    title: Text(option),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                //TODO: Nút để thêm kỹ năng
                ElevatedButton(
                  onPressed: () {
                    // log('Thêm kỹ năng: ${_skillController?.text}');
                    //Nếu trùng thì sẽ trả về giá trị của skill đó, nếu không trùng thì trả về ''
                    String? isExistSkill = _skillsListenable.value.firstWhere(
                      (element) {
                        String editedElement =
                            Utils.removeVietnameseAccent(element).toLowerCase();
                        String editedInput =
                            Utils.removeVietnameseAccent(_skillController!.text)
                                .toLowerCase();
                        return editedElement == editedInput;
                      },
                      orElse: () => '',
                    );
                    if (!_skillController!.text.isEmpty &&
                        isExistSkill.isEmpty) {
                      final updatedList =
                          List<String>.from(_skillsListenable.value)
                            ..add(_skillController!.text);
                      _skillsListenable.value = updatedList;
                      _skillController!.clear();
                    } else {
                      log('Emplty text form field');
                      QuickAlert.show(
                          context: context,
                          type: QuickAlertType.error,
                          title: 'Kỹ năng trùng',
                          text: 'Không thể thêm kỹ năng trùng',
                          autoCloseDuration: Duration(seconds: 5),
                          confirmBtnText: 'Tôi đã biết');
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size.fromHeight(56),
                      side: BorderSide(color: theme.colorScheme.primary),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      foregroundColor: theme.colorScheme.primary,
                      textStyle: textTheme.titleMedium),
                  child: const Text("Thêm"),
                ),
              ],
            ),
            //TODO: Hiển thị những kỹ năng được thêm vào bởi người dùng
            const SizedBox(
              height: 6,
            ),
            const Divider(),
            const SizedBox(
              height: 6,
            ),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: _skillsListenable,
                builder: (context, skillsList, child) {
                  return skillsList.isNotEmpty
                      ? Wrap(
                          alignment: WrapAlignment.start,
                          direction: Axis.horizontal,
                          spacing: 10,
                          children:
                              List<Widget>.generate(skillsList.length, (index) {
                            return InputChip(
                              label: Text(
                                skillsList[index],
                                style: TextStyle(color: Colors.grey.shade700),
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
                              backgroundColor: Colors.grey[200],
                              deleteIconColor: Colors.grey,
                              deleteIcon: Icon(
                                Icons.cancel,
                                size: 20,
                              ),
                              onDeleted: () {
                                log('Xóa kỹ năng: ${skillsList[index]}');
                                final updatedList =
                                    List<String>.from(_skillsListenable.value)
                                      ..remove(_skillsListenable.value[index]);
                                _skillsListenable.value = updatedList;
                              },
                            );
                          }),
                        )
                      : Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            'Hãy thêm công nghệ mà công việc yêu cầu để tăng chất lượng ứng viên',
                            style: textTheme.bodyLarge,
                          ),
                        );
                },
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            //TODO: Nút dùng để lưu những kỹ năng vào
            ValueListenableBuilder(
                valueListenable: _skillsListenable,
                builder: (context, skillsList, child) {
                  return ElevatedButton(
                    onPressed: skillsList.isEmpty
                        ? null
                        : () async {
                            widget.onSaved.call(skillsList);
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
