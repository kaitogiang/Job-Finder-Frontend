import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({super.key, required this.gallaryItems, this.index = 0});

  final List<String> gallaryItems;
  final int index;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  PageController? pageController;

  int currentPage = 0;

  @override
  void initState() {
    super.initState();
    log('Nhận vào ${widget.index}');
    currentPage = widget.index;
    pageController = PageController(initialPage: currentPage);
  }

  @override
  void dispose() {
    pageController!.dispose();
    super.dispose();
  }

  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.black,
        title: Text(
          'Hình ${currentPage + 1}',
          style: TextStyle(
            color: Colors.grey,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close),
        ),
      ),
      body: PhotoViewGallery.builder(
        itemCount: widget.gallaryItems.length,
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (contex, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(widget.gallaryItems[index]),
            initialScale: PhotoViewComputedScale.contained * 0.8,
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 2.1,
            heroAttributes: PhotoViewHeroAttributes(tag: '$index'),
          );
        },
        loadingBuilder: (context, progress) => Center(
          child: SizedBox(
            width: 20.0,
            height: 20.0,
            child: CircularProgressIndicator(
              value: progress == null
                  ? null
                  : progress.cumulativeBytesLoaded /
                      progress.expectedTotalBytes!,
            ),
          ),
        ),
        backgroundDecoration: BoxDecoration(color: Colors.black),
        pageController: pageController,
        onPageChanged: onPageChanged,
      ),
    );
  }
}
