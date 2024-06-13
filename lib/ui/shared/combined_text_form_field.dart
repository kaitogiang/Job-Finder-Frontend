import 'package:flutter/material.dart';

class CombinedTextFormField extends StatefulWidget {
  const CombinedTextFormField(
      {super.key,
      required this.title,
      this.controller,
      required this.hintText,
      required this.keyboardType,
      this.isRead = false,
      this.isPassword = false,
      this.onTap,
      this.validator,
      this.onSaved,
      this.isEnable = true,
      this.maxLines = 1,
      this.minLines = 1});
  final String title;
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool isRead;
  final bool isPassword;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;
  final bool? isEnable;
  final int? maxLines;
  final int? minLines;

  @override
  State<CombinedTextFormField> createState() => _CombinedTextFormFieldState();
}

class _CombinedTextFormFieldState extends State<CombinedTextFormField> {
  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    TextTheme textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          widget.title,
          style: textTheme.titleMedium!.copyWith(
            fontSize: 17,
          ),
        ),
        const SizedBox(
          height: 5,
        ),
        _buildFirstNameField(),
      ],
    );
  }

  TextFormField _buildFirstNameField() {
    return TextFormField(
      controller: widget.controller,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onTap: widget.onTap,
      decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          constraints: widget.keyboardType != TextInputType.multiline
              ? BoxConstraints.tight(Size.fromHeight(60))
              : null,
          enabled: widget.isEnable!),
      keyboardType: widget.keyboardType,
      readOnly: widget.isRead,
      obscureText: widget.isPassword,
      validator: widget.validator,
      onSaved: widget.onSaved,
    );
  }
}
