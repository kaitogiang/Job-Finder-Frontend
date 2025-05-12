import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/shared/addition_data.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:quickalert/quickalert.dart';

class TechAdditionScreen extends StatefulWidget {
  const TechAdditionScreen({Key? key, required this.onSaved, this.techList})
      : super(key: key);

  final void Function(List<String>) onSaved;
  final List<String>? techList;

  @override
  _TechAdditionScreenState createState() => _TechAdditionScreenState();
}

class _TechAdditionScreenState extends State<TechAdditionScreen> {
  final List<String> _options = List<String>.from(getTechnologyList);
  final ValueNotifier<List<String>> _skillsListenable = ValueNotifier([]);

  late TextEditingController _skillController;
  @override
  void initState() {
    super.initState();
    _skillsListenable.value = widget.techList ?? [];
    _skillController = TextEditingController();
  }

  @override
  void dispose() {
    Utils.logMessage('dispose');
    _skillController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;
    Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Công nghệ yêu cầu"),
      ),
      body: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildSkillInputField(theme, textTheme),
            const SizedBox(height: 6),
            const Divider(),
            const SizedBox(height: 6),
            _buildSkillList(textTheme),
            const SizedBox(height: 10),
            _buildSaveButton(deviceSize, theme, textTheme),
          ],
        ),
      ),
    );
  }

  Row _buildSkillInputField(ThemeData theme, TextTheme textTheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(child: _buildAutoCompleteField()),
        const SizedBox(width: 10),
        _buildAddSkillButton(theme, textTheme),
      ],
    );
  }

  Autocomplete<String> _buildAutoCompleteField() {
    return Autocomplete<String>(
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
        Utils.logMessage('Bạn đã chọn $option');
      },
      fieldViewBuilder:
          ((context, textEditingController, focusNode, onFieldSubmitted) {
        // _skillController = textEditingController;
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
            _skillController.text = textEditingController.text;
          },
          onChanged: (value) {
            _skillController.text = textEditingController.text;
          },
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            constraints: BoxConstraints.tight(const Size.fromHeight(60)),
            labelText: 'Thêm công nghệ yêu cầu',
            prefixIcon: const Icon(Icons.code),
          ),
          textInputAction: TextInputAction.search,
        );
      }),
      optionsViewBuilder: (context, onSelected, options) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: ListView.builder(
                padding: const EdgeInsets.all(8.0),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final option = options.elementAt(index);
                  return GestureDetector(
                    onTap: () {
                      onSelected(option);
                      _skillController.text = option;
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
    );
  }

  ElevatedButton _buildAddSkillButton(ThemeData theme, TextTheme textTheme) {
    return ElevatedButton(
      onPressed: _addSkill,
      style: ElevatedButton.styleFrom(
        fixedSize: const Size.fromHeight(56),
        side: BorderSide(color: theme.colorScheme.primary),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        foregroundColor: theme.colorScheme.primary,
        textStyle: textTheme.titleMedium,
      ),
      child: const Text("Thêm"),
    );
  }

  void _addSkill() {
    String? isExistSkill = _skillsListenable.value.firstWhere(
      (element) {
        String editedElement =
            Utils.removeVietnameseAccent(element).toLowerCase();
        String editedInput =
            Utils.removeVietnameseAccent(_skillController.text).toLowerCase();
        return editedElement == editedInput;
      },
      orElse: () => '',
    );
    if (_skillController.text.isNotEmpty && isExistSkill.isEmpty) {
      final updatedList = List<String>.from(_skillsListenable.value)
        ..add(_skillController.text);
      _skillsListenable.value = updatedList;
      _skillController.clear();
    } else {
      Utils.logMessage('Empty text form field');
      QuickAlert.show(
        context: context,
        type: QuickAlertType.error,
        title: 'Kỹ năng trùng',
        text: 'Không thể thêm kỹ năng trùng',
        autoCloseDuration: const Duration(seconds: 5),
        confirmBtnText: 'Tôi đã biết',
      );
      _skillController.clear();
    }
  }

  Expanded _buildSkillList(TextTheme textTheme) {
    return Expanded(
      child: ValueListenableBuilder<List<String>>(
        valueListenable: _skillsListenable,
        builder: (context, skillsList, child) {
          return skillsList.isNotEmpty
              ? _buildSkillChips(skillsList)
              : _buildEmptySkillListMessage(textTheme);
        },
      ),
    );
  }

  Wrap _buildSkillChips(List<String> skillsList) {
    return Wrap(
      alignment: WrapAlignment.start,
      direction: Axis.horizontal,
      spacing: 10,
      children: List<Widget>.generate(skillsList.length, (index) {
        return InputChip(
          label: Text(
            skillsList[index],
            style: TextStyle(color: Colors.grey.shade700),
          ),
          elevation: 2,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(
              color: Colors.grey[400]!,
            ),
          ),
          backgroundColor: Colors.grey[200],
          deleteIconColor: Colors.grey,
          deleteIcon: const Icon(
            Icons.cancel,
            size: 20,
          ),
          onDeleted: () {
            _deleteSkill(index);
          },
        );
      }),
    );
  }

  void _deleteSkill(int index) {
    Utils.logMessage('Xóa kỹ năng: ${_skillsListenable.value[index]}');
    final updatedList = List<String>.from(_skillsListenable.value)
      ..removeAt(index);
    _skillsListenable.value = updatedList;
  }

  Align _buildEmptySkillListMessage(TextTheme textTheme) {
    return Align(
      alignment: Alignment.topCenter,
      child: Text(
        'Hãy thêm công nghệ mà công việc yêu cầu để tăng chất lượng ứng viên',
        style: textTheme.bodyLarge,
      ),
    );
  }

  ValueListenableBuilder _buildSaveButton(
      Size deviceSize, ThemeData theme, TextTheme textTheme) {
    return ValueListenableBuilder(
      valueListenable: _skillsListenable,
      builder: (context, skillsList, child) {
        return ElevatedButton(
          onPressed: skillsList.isEmpty ? null : _saveSkills,
          style: ElevatedButton.styleFrom(
            disabledBackgroundColor: Colors.grey.shade300,
            fixedSize: Size(deviceSize.width, 60),
            backgroundColor: theme.primaryColor,
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            foregroundColor: theme.colorScheme.onPrimary,
            textStyle: textTheme.titleMedium,
          ),
          child: const Text("LƯU"),
        );
      },
    );
  }

  void _saveSkills() async {
    widget.onSaved.call(_skillsListenable.value);
    Navigator.of(context).pop();
  }
}
