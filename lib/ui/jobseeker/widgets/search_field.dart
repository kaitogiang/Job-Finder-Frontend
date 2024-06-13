import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SearchField extends StatelessWidget {
  const SearchField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: () {
        context.goNamed('searching');
      },
      readOnly: true,
      decoration: InputDecoration(
        constraints: BoxConstraints.tightFor(height: 60),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        hintText: 'Tìm kiếm lĩnh vực của bạn',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
