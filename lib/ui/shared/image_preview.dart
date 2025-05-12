import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    super.key,
    required this.gallaryItems,
    this.index = 0,
  });

  final List<String> gallaryItems;
  final int index;

  @override
  State<ImagePreview> createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  late PageController _pageController;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = widget.index;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildPhotoGallery(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.black,
      title: Text(
        'Hình ${_currentPage + 1}',
        style: const TextStyle(
          color: Colors.grey,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.close),
      ),
    );
  }

  Widget _buildPhotoGallery() {
    return PhotoViewGallery.builder(
      itemCount: widget.gallaryItems.length,
      scrollPhysics: const BouncingScrollPhysics(),
      builder: _buildGalleryItem,
      loadingBuilder: _buildLoadingIndicator,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      pageController: _pageController,
      onPageChanged: _onPageChanged,
    );
  }

  PhotoViewGalleryPageOptions _buildGalleryItem(BuildContext context, int index) {
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(widget.gallaryItems[index]),
      initialScale: PhotoViewComputedScale.contained * 0.8,
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 2.1,
      heroAttributes: PhotoViewHeroAttributes(tag: '$index'),
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, ImageChunkEvent? progress) {
    return Center(
      child: SizedBox(
        width: 20.0,
        height: 20.0,
        child: CircularProgressIndicator(
          value: progress == null
              ? null 
              : progress.cumulativeBytesLoaded / progress.expectedTotalBytes!,
        ),
      ),
    );
  }
}
