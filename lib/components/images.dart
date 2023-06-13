import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindverse/components/viewer.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';

class ImagesSegment extends StatelessWidget {
  final List<String> images;
  final double height;
  final Message? message;

  const ImagesSegment(
      {Key? key, required this.images, required this.height, this.message})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 1),
      child: StaggeredGrid.count(
        crossAxisCount: 2, // number of columns
        mainAxisSpacing: 1.0, // spacing between items in the main axis
        crossAxisSpacing: 1.0, // spacing between items in the cross axis
        axisDirection: AxisDirection.down,
        children: staggerGenerator,
      ),
    );
  }

  List<Widget> get staggerGenerator {
    // generate dynamic staggered layout
    if (images.length == 1) {
      return [
        StaggeredGridTile.extent(
            mainAxisExtent: height,
            crossAxisCellCount: 2,
            child: DisplayImage(
              images: images,
              index: 0,
              message: message,
            ))
      ];
    } else if (images.length == 2) {
      return [
        StaggeredGridTile.extent(
            mainAxisExtent: height,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 0,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 1,
              message: message,
            )),
      ];
    } else if (images.length == 3) {
      return [
        StaggeredGridTile.extent(
            mainAxisExtent: height,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 0,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height / 2,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 1,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height / 2,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 2,
              message: message,
            )),
      ];
    } else if (images.length == 4) {
      return [
        StaggeredGridTile.extent(
            mainAxisExtent: height,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 0,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height / 3,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 1,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height / 3,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 2,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height / 3,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 3,
              message: message,
            )),
      ];
    } else {
      return [
        StaggeredGridTile.extent(
            mainAxisExtent: height,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 0,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height / 3,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 1,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height / 3,
            crossAxisCellCount: 1,
            child: DisplayImage(
              images: images,
              index: 2,
              message: message,
            )),
        StaggeredGridTile.extent(
            mainAxisExtent: height / 3,
            crossAxisCellCount: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                DisplayImage(
                  images: images,
                  index: 3,
                  message: message,
                ),
                Positioned(
                  height: height / 3,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: const Color.fromARGB(171, 0, 0, 0),
                    child: Center(
                        child: Text(
                      '+${images.length - 4}',
                      style: GoogleFonts.overpass(
                          textStyle: const TextStyle(
                              fontSize: 45,
                              height: 1.5,
                              fontWeight: FontWeight.w100,
                              color: Colors.white70)),
                    )),
                  ),
                )
              ],
            )),
      ];
    }
  }
}

class DisplayImage extends StatefulWidget {
  const DisplayImage({
    super.key,
    required this.images,
    required this.message,
    required this.index,
  });

  final List<String> images;
  final int index;
  final Message? message;

  @override
  State<DisplayImage> createState() => _DisplayImageState();
}

class _DisplayImageState extends State<DisplayImage>
    with WidgetsBindingObserver {
  final SessionController sc = Get.find<SessionController>();
  List<ImageProvider> imageObjects = [];

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              settings: const RouteSettings(name: 'ImageViewer'),
              builder: (BuildContext context) {
                return StatusBarColorObserver(
                  child: ImagesViewer(
                    images: widget.images,
                    initialIndex: widget.index,
                    independent: true,
                  ),
                );
                //}
              },
            ),
          );
        },
        child: imageObjects.isEmpty
            ? const SizedBox()
            : Image(image: imageObjects[widget.index], fit: BoxFit.cover));
  }
}
