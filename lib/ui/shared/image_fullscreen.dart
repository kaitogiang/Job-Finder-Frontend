import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class ImageFullcreen extends StatefulWidget {
  const ImageFullcreen({super.key});
  @override
  State<ImageFullcreen> createState() => _ImageFullcreenState();
}

class _ImageFullcreenState extends State<ImageFullcreen> {
  final PageController pageController = PageController();
  int currentPage = 0;

  void onPageChanged(int index) {
    setState(() {
      currentPage = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PhotoView Gallery Example'),
      ),
      body: PhotoViewGallery(
        pageOptions: <PhotoViewGalleryPageOptions>[
          PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
                "https://images.fpt.shop/unsafe/filters:quality(5)/fptshop.com.vn/uploads/images/tin-tuc/166539/Originals/anime-ai-la-gi-bat-mi-cach-tao-anime-bang-ai-cuc-don-gian.png"),
            heroAttributes: const PhotoViewHeroAttributes(tag: "tag1"),
          ),
          PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
                "https://tiki.vn/blog/wp-content/uploads/2023/08/thumb-22.jpg"),
            heroAttributes: const PhotoViewHeroAttributes(tag: "tag2"),
            maxScale: PhotoViewComputedScale.covered * 0.3,
          ),
          PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(
                "https://toquoc.mediacdn.vn/280518851207290880/2022/5/27/avatar1653666679855-1653666680336805904329.jpg"),
            minScale: PhotoViewComputedScale.contained * 0.8,
            maxScale: PhotoViewComputedScale.covered * 1.1,
            heroAttributes: const PhotoViewHeroAttributes(tag: "tag3"),
          ),
        ],
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
