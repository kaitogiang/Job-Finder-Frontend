import 'package:flutter/material.dart';

class EmptyJobpostingTable extends StatelessWidget {
  const EmptyJobpostingTable({
    super.key,
    required this.headers,
  });

  final List<String> headers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final headerTextStyle = theme.textTheme.bodyMedium!.copyWith(
      color: theme.colorScheme.onSurface.withOpacity(0.6),
      fontWeight: FontWeight.w600,
    );

    final titleList = headers.isEmpty
        ? ['Tên công ty', 'Tiêu đề', 'Ngày đăng', 'Ngày hết hạn', 'Hành động']
        : headers;

    return Column(
      children: [
        _buildHeader(headerTextStyle, titleList),
        _buildEmptyState(theme),
      ],
    );
  }

  Widget _buildHeader(TextStyle headerTextStyle, List<String> titleList) {
    BorderSide borderSide = BorderSide(color: Colors.grey.shade400);
    BorderSide lastBorderSide = BorderSide(color: Colors.transparent);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(10),
        ),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Row(
        children: List<Widget>.generate(titleList.length, (index) {
          return index == titleList.length - 1
              ? _buildCell(titleList[index], headerTextStyle, lastBorderSide)
              : _buildCell(titleList[index], headerTextStyle, borderSide);
        }),
      ),
    );
  }

  Widget _buildCell(String text, TextStyle style, BorderSide borderSide) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
        decoration: BoxDecoration(
          border: Border(
            right: borderSide,
          ),
        ),
        child: Text(text, style: style),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Container(
      height: 100,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(color: Colors.grey.shade400),
          right: BorderSide(color: Colors.grey.shade400),
          bottom: BorderSide(color: Colors.grey.shade400),
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(10)),
      ),
      child: Text(
        'Chưa có bài đăng tuyển dụng nào',
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}