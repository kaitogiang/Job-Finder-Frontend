import 'dart:io';

import 'package:flutter/material.dart';

class ImageContainer extends StatelessWidget {
  const ImageContainer(
      {super.key,
      required this.url,
      this.width = 130,
      this.height = 130,
      this.borderRadius = 10,
      this.isFileType = false,
      this.file,
      this.onDelete});

  final String url;
  final double width;
  final double height;
  final double borderRadius;
  final bool isFileType;
  final File? file;
  final void Function()? onDelete;
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(borderRadius),
              image: DecorationImage(
                  image: !isFileType && file == null
                      ? NetworkImage(
                          url,
                        )
                      : FileImage(file!) as ImageProvider,
                  fit: BoxFit.cover)),
        ),
        if (onDelete != null)
          IconButton(
            onPressed: onDelete,
            icon: CircleAvatar(
                child: Icon(
                  Icons.clear_outlined,
                  color: Colors.grey.shade600,
                ),
                backgroundColor: Colors.white),
          )
      ],
    );
  }
}
