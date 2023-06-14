import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/session.dart';
import 'package:mindverse/models.dart';
import 'package:mindverse/utils.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:google_fonts/google_fonts.dart';

class StaticAvatarSegment extends StatelessWidget {
  final double size;
  final String path;
  final bool isCircular;
  const StaticAvatarSegment({
    Key? key,
    required this.size,
    required this.path,
    this.isCircular = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
          color: htTrans2,
          shape: isCircular ? BoxShape.circle : BoxShape.rectangle),
      child: Image.asset(
        path,
        height: size,
        width: size,
      ),
    );
  }
}

class AvatarSegment extends StatelessWidget {
  final String? objectId;
  final DateTime? time;
  final bool expanded;
  final double size;
  final bool boxed;
  final bool isCircular;
  final String? extra;
  final UserProfile userProfile;
  final Icon? overlayIcon;
  final Color? userDetailsColor;
  final Color? usernameColor;

  AvatarSegment({
    Key? key,
    this.expanded = true,
    required this.userProfile,
    this.boxed = false,
    this.userDetailsColor = Colors.white,
    this.extra,
    this.overlayIcon,
    this.size = 70,
    this.objectId,
    this.isCircular = false,
    this.usernameColor = Colors.black54,
    this.time,
  }) : super(key: key);

  final SessionController sc = Get.find<SessionController>();

  @override
  Widget build(BuildContext context) {
    TextStyle titleStyle = GoogleFonts.overpass(
      textStyle: TextStyle(
          color: htSolid3,
          fontWeight: FontWeight.bold,
          fontSize: boxed ? 14 : 20,
          height: boxed ? 1.1 : 1.2),
    );
    return SizedBox(
      width: size,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
              color: htSolid1,
              border: Border.all(
                width: 1,
                color: htSolid4,
                strokeAlign: BorderSide.strokeAlignOutside,
              ),
            ),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            child: Stack(
              children: [
                userProfile.avatar.isNotEmpty
                    ? ImagePath(
                        bucket: 'profile_avatars',
                        imageId: userProfile.avatar,
                        size: size,
                        isCircular: isCircular,
                      )
                    : Image.asset(
                        'assets/images/user.png',
                        height: size,
                        width: size,
                        fit: BoxFit.contain,
                      ),
                Positioned(
                    bottom: 4,
                    left: 4,
                    child: Indicator(
                      username: userProfile.username,
                      isCircular: isCircular,
                      size: size,
                    )),
                Positioned(
                  child: overlayIcon != null
                      ? Container(
                          width: size,
                          height: size,
                          color: Colors.black26,
                          child: overlayIcon,
                        )
                      : const SizedBox(),
                ),
              ],
            ),
          ),
          expanded
              ? Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 150,
                    height: size,
                    child: Stack(
                      children: [
                        Positioned(
                          top: boxed ? 5 : 8,
                          child: Text(
                            "@${userProfile.username}",
                            style: GoogleFonts.overpass(
                                textStyle: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: boxed ? 10 : 12,
                                    color: usernameColor,
                                    height: boxed ? 0.6 : 0.4)),
                          ),
                        ),
                        Positioned(
                          top: boxed ? 12 : 14,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              userProfile.username == sc.username.value
                                  ? Obx(() =>
                                      Text(sc.name.value, style: titleStyle))
                                  : Text(userProfile.name, style: titleStyle),
                              extra != null
                                  ? Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5.0, top: 2),
                                      child: Text(
                                        extra!,
                                        style: GoogleFonts.overpass(
                                            textStyle: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: boxed ? 12 : 16,
                                                height: boxed ? 1.0 : 1.3)),
                                      ),
                                    )
                                  : const SizedBox(),
                            ],
                          ),
                        ),
                        if (time != null)
                          Positioned(
                            bottom: boxed ? 0 : 10,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.history,
                                  size: boxed ? 12 : 14,
                                  color: userDetailsColor,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  timeago
                                      .format(DateTime.parse(time.toString())),
                                  style: TextStyle(
                                    inherit: true,
                                    color: userDetailsColor,
                                    fontSize: boxed ? 10 : 13,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                )
              : const SizedBox(),
        ],
      ),
    );
  }
}

class Indicator extends StatefulWidget {
  const Indicator({
    super.key,
    required this.isCircular,
    required this.size,
    required this.username,
  });

  final bool isCircular;
  final double size;
  final String username;

  @override
  State<Indicator> createState() => _IndicatorState();
}

class _IndicatorState extends State<Indicator> {
  final SessionController sc = Get.find<SessionController>();
  late Timer _timerOnline;
  bool online = false;

  @override
  void initState() {
    super.initState();

    if (widget.username != unknownBastard && widget.size > 30) {
      // do online checks
      onlineStatus(null);

      // check online after period
      _timerOnline = Timer.periodic(const Duration(seconds: 60), onlineStatus);
    }
  }

  void onlineStatus(_) async =>
      // check if online
      await sc.checkOnline(uname: widget.username).then((isOnline) {
        if (isOnline && !online) {
          setState(() {
            online = true;
          });
        } else if (!isOnline && online) {
          setState(() {
            online = false;
          });
        }
      });

  @override
  Widget build(BuildContext context) {
    return online
        ? widget.isCircular
            ? Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10)),
                  color: htSolid4,
                ),
                height: widget.size / 4,
                width: widget.size / 4,
              )
            : OnlineIndicator(size: widget.size / 4)
        : const SizedBox();
  }

  @override
  void dispose() {
    if (widget.username != unknownBastard && widget.size > 30) {
      // dispose online timer
      if (_timerOnline.isActive) {
        _timerOnline.cancel();
      }
    }
    super.dispose();
  }
}

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = htSolid4 // Set the color of the triangle
      ..style = PaintingStyle.fill; // Set the painting style to fill

    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, 0);
    path.lineTo(size.width, size.height);
    path.close(); // Close the path to form a triangle

    canvas.drawPath(path, paint); // Draw the triangle on the canvas
  }

  @override
  bool shouldRepaint(TrianglePainter oldDelegate) => false;
}

class OnlineIndicator extends StatelessWidget {
  const OnlineIndicator({super.key, this.size = 50});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TrianglePainter(),
      child: SizedBox(
        width: size,
        height: size,
      ),
    );
  }
}
