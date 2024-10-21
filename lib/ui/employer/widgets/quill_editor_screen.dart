import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class QuillEditorScreen extends StatefulWidget {
  const QuillEditorScreen({
    super.key,
    required this.title,
    required this.document,
    required this.subtitle,
    this.onSaved,
  });
  final String title;
  final Document document;
  final String subtitle;
  final void Function(Document)? onSaved;

  @override
  State<QuillEditorScreen> createState() => _QuillEditorScreenState();
}

class _QuillEditorScreenState extends State<QuillEditorScreen> {
  final QuillController _controller = QuillController.basic();
  final ValueNotifier<bool> _isShowToolBar = ValueNotifier(false);
  @override
  void initState() {
    //!Thay bằng code này sẽ fix được lỗi, không thể sử dụng chung Document bởi vì nó sẽ gây ra lỗi nếu một trong hai controller bị dispose
    _controller.document = Document.fromDelta(widget.document.toDelta());
    super.initState();
  }

  @override
  void dispose() {
    // implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceSize = MediaQuery.of(context).size;
    //Tính toán giá trị chiều cao cho
    int subLength = widget.subtitle.length;
    double size = 0.0;
    if (subLength <= 43) {
      size = 20;
    } else if (subLength <= 2 * 43) {
      size = 20 * 2 + 10;
    } else if (subLength <= 3 * 43) {
      size = 20 * 3 + 10;
    } else if (subLength <= 4 * 43) {
      size = 20 * 4 + 10;
    } else if (subLength <= 5 * 43) {
      size = 20 * 5 + 10;
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () {
              final data = _controller.document;
              log(data.toDelta().toJson().toString());
              log('IsEmpty: ${data.isEmpty()}');
              widget.onSaved?.call(data);
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.save,
              color: Color(0xFFEEEEEE),
            ),
            label: Text(
              'Lưu',
              style: theme.textTheme.titleMedium!.copyWith(
                color: const Color(0xFFEEEEEE),
              ),
            ),
          ),
        ],
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          width: deviceSize.width,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.blueAccent.shade700,
                Colors.blueAccent.shade400,
                theme.primaryColor,
              ],
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(size),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 10,
              vertical: 5,
            ),
            child: Center(
              child: Text(
                widget.subtitle,
                style: theme.textTheme.bodyLarge!.copyWith(
                  color: theme.indicatorColor,
                ),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ValueListenableBuilder(
                valueListenable: _isShowToolBar,
                builder: (context, isShowToolBar, child) {
                  return AnimatedCrossFade(
                    crossFadeState: !isShowToolBar
                        ? CrossFadeState.showFirst
                        : CrossFadeState.showSecond,
                    duration: Duration(milliseconds: 400),
                    firstChild: ElevatedButton(
                      child: Text('Hiện toolbar'),
                      onPressed: () {
                        _isShowToolBar.value = true;
                      },
                    ),
                    secondChild: Column(
                      children: [
                        QuillToolbar.simple(
                          configurations: QuillSimpleToolbarConfigurations(
                            controller: _controller,
                            showDirection: false,
                            showDividers: false,
                            showCodeBlock: false,
                            showSearchButton: false,
                            sharedConfigurations:
                                const QuillSharedConfigurations(
                              locale: Locale('en'),
                            ),
                          ),
                        ),
                        TextButton(
                          child: Text('Ẩn'),
                          onPressed: () {
                            _isShowToolBar.value = false;
                          },
                        )
                      ],
                    ),
                  );
                }),
            const Divider(),
            Container(
              padding: const EdgeInsets.all(10),
              height: 300,
              child: QuillEditor.basic(
                configurations: QuillEditorConfigurations(
                  controller: _controller,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('de'),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
