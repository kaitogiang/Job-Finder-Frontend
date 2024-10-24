import 'package:flutter/material.dart';
import 'package:number_pagination/number_pagination.dart';

class TableNumberPagination extends StatelessWidget {
  const TableNumberPagination({
    super.key,
    required this.onPageChanged,
    this.buttonSize = 40,
    this.visiblePagesCount = 5,
    required this.totalPages,
  });

  final void Function(int) onPageChanged;
  final double buttonSize;
  final int visiblePagesCount;
  final int totalPages;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(5),
        ),
        child: NumberPagination(
          onPageChanged: onPageChanged,
          betweenNumberButtonSpacing: 0,
          buttonRadius: 5,
          buttonElevation: 2,
          fontSize: 15,
          navigationButtonSpacing: 5,
          numberButtonSize: Size.square(buttonSize),
          controlButtonSize: Size.square(buttonSize),
          visiblePagesCount: visiblePagesCount,
          totalPages: totalPages,
          currentPage: 1,
        ),
      ),
    );
  }
}
