import 'package:flutter/material.dart';
import 'package:job_finder_app/ui/shared/addition_data.dart';
import 'package:job_finder_app/ui/shared/utils.dart';
import 'package:quickalert/quickalert.dart';

class TechAdditionScreen extends StatefulWidget {
  const TechAdditionScreen({
    Key? key,
    required this.onSaved,
    this.techList,
  }) : super(key: key);

  final void Function(List<String>) onSaved;
  final List<String>? techList;

  @override
  _TechAdditionScreenState createState() => _TechAdditionScreenState();
}

class _TechAdditionScreenState extends State<TechAdditionScreen> {
  final List<String> _options = List<String>.from(getTechnologyList);
  final ValueNotifier<List<String>> _selectedSkills = ValueNotifier([]);
  final TextEditingController _skillController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedSkills.value = widget.techList ?? [];
  }

  @override
  void dispose() {
    _skillController.dispose();
    _selectedSkills.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillController.text.trim();
    if (skill.isEmpty) {
      _showError('Vui lòng nhập kỹ năng');
      return;
    }

    final isDuplicate = _selectedSkills.value.any((existingSkill) {
      final normalizedExisting =
          Utils.removeVietnameseAccent(existingSkill).toLowerCase();
      final normalizedNew = Utils.removeVietnameseAccent(skill).toLowerCase();
      return normalizedExisting == normalizedNew;
    });

    if (isDuplicate) {
      _showError('Kỹ năng này đã tồn tại');
      return;
    }

    _selectedSkills.value = [..._selectedSkills.value, skill];
    _skillController.clear();
  }

  void _removeSkill(int index) {
    final updatedSkills = List<String>.from(_selectedSkills.value);
    updatedSkills.removeAt(index);
    _selectedSkills.value = updatedSkills;
  }

  void _showError(String message) {
    QuickAlert.show(
      context: context,
      type: QuickAlertType.error,
      title: 'Lỗi',
      text: message,
      autoCloseDuration: const Duration(seconds: 3),
      confirmBtnText: 'Đã hiểu',
    );
  }

  void _saveSkills() {
    widget.onSaved(_selectedSkills.value);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Công nghệ yêu cầu"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSkillInput(theme, textTheme),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<List<String>>(
                valueListenable: _selectedSkills,
                builder: (context, skills, _) {
                  return skills.isEmpty
                      ? _buildEmptyState(textTheme)
                      : _buildSkillChips(skills);
                },
              ),
            ),
            const SizedBox(height: 16),
            _buildSaveButton(deviceSize, theme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillInput(ThemeData theme, TextTheme textTheme) {
    return Row(
      children: [
        Expanded(
          child: Autocomplete<String>(
            optionsBuilder: (TextEditingValue value) {
              if (value.text.isEmpty) return const Iterable<String>.empty();
              return _options.where((option) =>
                  option.toLowerCase().contains(value.text.toLowerCase()));
            },
            onSelected: (String selection) {
              _skillController.text = selection;
              _addSkill();
            },
            fieldViewBuilder:
                (context, controller, focusNode, onFieldSubmitted) {
              return TextFormField(
                controller: controller,
                focusNode: focusNode,
                onFieldSubmitted: (_) => _addSkill(),
                decoration: InputDecoration(
                  labelText: 'Thêm công nghệ yêu cầu',
                  prefixIcon: const Icon(Icons.code),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: options.length,
                      itemBuilder: (context, index) {
                        final option = options.elementAt(index);
                        return ListTile(
                          title: Text(option),
                          onTap: () => onSelected(option),
                        );
                      },
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _addSkill,
          style: ElevatedButton.styleFrom(
            fixedSize: const Size.fromHeight(56),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("Thêm"),
        ),
      ],
    );
  }

  Widget _buildSkillChips(List<String> skills) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: skills.asMap().entries.map((entry) {
        return InputChip(
          label: Text(entry.value),
          onDeleted: () => _removeSkill(entry.key),
          deleteIcon: const Icon(Icons.cancel, size: 20),
          backgroundColor: Colors.grey[200],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.grey[400]!),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState(TextTheme textTheme) {
    return Center(
      child: Text(
        'Hãy thêm công nghệ mà công việc yêu cầu để tăng chất lượng ứng viên',
        style: textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSaveButton(
      Size deviceSize, ThemeData theme, TextTheme textTheme) {
    return ValueListenableBuilder<List<String>>(
      valueListenable: _selectedSkills,
      builder: (context, skills, _) {
        return ElevatedButton(
          onPressed: skills.isEmpty ? null : _saveSkills,
          style: ElevatedButton.styleFrom(
            fixedSize: Size(deviceSize.width, 60),
            backgroundColor: theme.primaryColor,
            disabledBackgroundColor: Colors.grey[300],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: const Text("LƯU"),
        );
      },
    );
  }
}
