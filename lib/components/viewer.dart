import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mindverse/controllers/session.dart';
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

class _ImagesViewerState extends State<ImagesViewer>
    with WidgetsBindingObserver {
  final SessionController sc = Get.find<SessionController>();
  late final PageController pController;
  List<ImageProvider> imageObjects = [];

  @override
  void initState() {
    super.initState();
    pController =
        PageController(viewportFraction: 1, initialPage: widget.initialIndex!);
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => postInit());
  }

  void postInit() async {
    // get images
    List<ImageProvider> imp = [];
    for (String img in widget.images) {
      Uint8List imageBytes =
          await sc.getFile(bucket: 'chat_images', fileId: img);
      ImageProvider imageProvider = MemoryImage(imageBytes);
      imp.add(imageProvider);
    }

    // update state
    setState(() {
      imageObjects = imp;
    });
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
