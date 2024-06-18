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
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          QuillToolbar.basic(controller: _controller),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(10),
              child: QuillEditor.basic(
                controller: _controller,
                readOnly: false, //true for view only mode
              ),
            ),
          )
        ],
      ),
    );
  }
}
