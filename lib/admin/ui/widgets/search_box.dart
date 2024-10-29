import 'package:flutter/material.dart';

class SearchBox extends StatelessWidget {
  const SearchBox({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    this.onChanged,
    required this.controller,
  });

  final String hintText;
  final IconData prefixIcon;
  final void Function(String)? onChanged;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: textTheme.bodyMedium,
        prefixIcon: Icon(prefixIcon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(6),
        ),
        constraints: BoxConstraints.tight(Size(300, 40)),
      ),
      onChanged: onChanged,
    );
  }
}
