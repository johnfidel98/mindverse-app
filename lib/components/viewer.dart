import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:mindverse/utils.dart';
import 'package:photo_view/photo_view_gallery.dart';

const Map defaultOptions = {'initialIndex': 0};

class ImagesViewer extends StatefulWidget {
  const ImagesViewer({
    super.key,
    required this.images,
    this.initialIndex = 0,
    this.independent = false,
  });

  final List<dynamic> images;
  final int? initialIndex;
  final bool? independent;

  @override
  State<ImagesViewer> createState() => _ImagesViewerState();
}

class _ImagesViewerState extends State<ImagesViewer> {
  late final PageController pController;
  late List<ImageProvider> imageObjects;

  @override
  void initState() {
    imageObjects =
        widget.images.map((img) => CachedNetworkImageProvider(img)).toList();
    pController =
        PageController(viewportFraction: 1, initialPage: widget.initialIndex!);

    super.initState();
  }

  @override
  void dispose() {
    pController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoViewGallery.builder(
          enableRotation: true,
          scrollPhysics: const BouncingScrollPhysics(),
          builder: (BuildContext context, int index) {
            return PhotoViewGalleryPageOptions(
              imageProvider: imageObjects[index],
            );
          },
          itemCount: imageObjects.length,
          loadingBuilder: (context, event) => Center(
            child: SizedBox(
              width: 160.0,
              height: 160.0,
              child: CircularProgressIndicator(
                strokeWidth: 1,
                value: event == null
                    ? 0
                    : event.cumulativeBytesLoaded / event.expectedTotalBytes!,
              ),
            ),
          ),
          pageController: pController,
        ),
        if (widget.independent!)
          const Positioned(
            right: 20,
            top: 50,
            child: CloseCircleButton(),
          ),
      ],
    );
  }
}
