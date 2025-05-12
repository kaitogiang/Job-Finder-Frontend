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

  ImageProvider _getImageProvider() {
    if (!isFileType && file == null) {
      return NetworkImage(url);
    }
    return FileImage(file!) as ImageProvider;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.topRight,
      children: [
        _buildImageContainer(),
        if (onDelete != null) _buildDeleteButton(),
      ],
    );
  }

  Widget _buildImageContainer() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        image: DecorationImage(
          image: _getImageProvider(),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      onPressed: onDelete,
      icon: CircleAvatar(
        backgroundColor: Colors.white,
        child: Icon(
          Icons.clear_outlined,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }
}
