import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageFullcreen extends StatefulWidget {
  const ImageFullcreen({super.key});

  @override
  State<ImageFullcreen> createState() => _ImageFullcreenState();
}

class _ImageFullcreenState extends State<ImageFullcreen> {
  final _pageController = PageController();
  int _currentPage = 0;

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
      title: Text('Image ${_currentPage + 1}'),
      elevation: 0,
      backgroundColor: Colors.black,
    );
  }

  Widget _buildPhotoGallery() {
    return PhotoViewGallery.builder(
      itemCount: _galleryItems.length,
      builder: _buildGalleryItem,
      loadingBuilder: _buildLoadingIndicator,
      backgroundDecoration: const BoxDecoration(color: Colors.black),
      pageController: _pageController,
      onPageChanged: _onPageChanged,
    );
  }

  PhotoViewGalleryPageOptions _buildGalleryItem(BuildContext context, int index) {
    return PhotoViewGalleryPageOptions(
      imageProvider: NetworkImage(_galleryItems[index]),
      initialScale: PhotoViewComputedScale.contained * 0.8,
      minScale: PhotoViewComputedScale.contained * 0.8,
      maxScale: PhotoViewComputedScale.covered * 2,
      heroAttributes: PhotoViewHeroAttributes(tag: 'image_$index'),
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

  final List<String> _galleryItems = [
    "https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/uploads/images/tin-tuc/166539/Originals/anime-ai-la-gi-bat-mi-cach-tao-anime-bang-ai-cuc-don-gian.png",
    "https://tiki.vn/blog/wp-content/uploads/2023/08/thumb-22.jpg",
    "https://toquoc.mediacdn.vn/280518851207290880/2022/5/27/avatar1653666679855-1653666680336805904329.jpg"
  ];
}
