import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

class JobpostingCreationForm extends StatefulWidget {
  const JobpostingCreationForm({super.key});

  @override
  State<JobpostingCreationForm> createState() => _JobpostingCreationFormState();
}

class _JobpostingCreationFormState extends State<JobpostingCreationForm> {
  QuillController _controller = QuillController.basic();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          QuillToolbar.simple(
              configurations: QuillSimpleToolbarConfigurations(
                  controller: _controller,
                  sharedConfigurations: const QuillSharedConfigurations(
                    locale: Locale('de'),
                  ))),
          Expanded(
            child: Container(
                padding: const EdgeInsets.all(10),
                child: QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                      controller: _controller,
                      sharedConfigurations: const QuillSharedConfigurations(
                          locale: Locale('de'))),
                )),
          ),
          ElevatedButton(
            onPressed: () {
              final result = _controller.document.toDelta().toJson();
              log(result.toString());
            },
            child: Text('Gửi'),
          ),
        ],
      ),
    );
  }
}
