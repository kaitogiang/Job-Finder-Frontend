import 'package:flutter/material.dart';

class CombinedTextFormField extends StatefulWidget {
  const CombinedTextFormField({
    super.key,
    required this.title,
    this.controller,
    required this.hintText,
    required this.keyboardType,
    this.isRead = false,
    this.isPassword = false,
    this.onTap,
    this.validator,
    this.onSaved,
  });
  final String title;
  final TextEditingController? controller;
  final String hintText;
  final TextInputType keyboardType;
  final bool isRead;
  final bool isPassword;
  final void Function()? onTap;
  final String? Function(String?)? validator;
  final void Function(String?)? onSaved;


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
      onTap: widget.onTap,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        constraints: BoxConstraints.tight(Size.fromHeight(60)),
      ),
      keyboardType: widget.keyboardType,
      readOnly: widget.isRead,
      obscureText: widget.isPassword,
      validator: widget.validator,
      onSaved: widget.onSaved,
    );
  }
}
