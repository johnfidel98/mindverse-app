import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers/session.dart';

class MVButton extends StatefulWidget {
  final Function()? onClick;
  final String label;
  final Color? bGcolor;
  final Color? txtColor;
  final double paddingH;
  final bool monitorState;
  final bool alt;

  const MVButton({
    Key? key,
    required this.onClick,
    required this.label,
    this.bGcolor,
    this.txtColor,
    this.alt = false,
    this.monitorState = true,
    this.paddingH = 30,
  }) : super(key: key);

  @override
  State<MVButton> createState() => _MVButtonState();
}

class _MVButtonState extends State<MVButton> {
  final SessionController _session = Get.find<SessionController>();
  late StreamSubscription _listener;
  bool _loading = false;

  @override
  void initState() {
    super.initState();

    if (widget.monitorState) {
      _listener = _session.actionStatus.listen((statusComplete) {
        if (statusComplete) {
          setState(() {
            _loading = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    if (widget.monitorState) {
      _listener.cancel();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: AlignmentDirectional.center,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: widget.paddingH),
          child: TextButton(
            onPressed: () {
              if (widget.monitorState) {
                _session.setActionStatus(false);
              }

              setState(() {
                _loading = true;
              });
              widget.onClick!();
            },
            style: ButtonStyle(
              textStyle: MaterialStatePropertyAll(
                GoogleFonts.overpass(
                  textStyle: TextStyle(
                    color:
                        widget.alt ? htSolid5 : widget.txtColor ?? Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              backgroundColor: MaterialStatePropertyAll(
                  widget.alt ? null : widget.bGcolor ?? Colors.black87),
              padding: const MaterialStatePropertyAll(
                  EdgeInsets.symmetric(vertical: 15)),
              shape: MaterialStatePropertyAll(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(defaultBorderRadius),
                ),
              ),
              elevation: const MaterialStatePropertyAll(3),
            ),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: Text(
                widget.label,
                style: TextStyle(color: widget.txtColor, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 5,
          child: SizedBox(
            width: MediaQuery.of(context).size.width - 140,
            child: _loading
                ? const LinearProgressIndicator(
                    minHeight: 1,
                    color: htSolid4,
                    backgroundColor: htTrans1,
                  )
                : const SizedBox(),
          ),
        ),
      ],
    );
  }
}

class InterfaceButton extends StatelessWidget {
  final String label;
  final Function()? onPressed;
  final Color? bgColor;
  final IconData? icon;
  final bool? alt;
  final double size;

  const InterfaceButton({
    super.key,
    required this.label,
    this.onPressed,
    this.alt = false,
    this.bgColor,
    this.icon,
    this.size = 0,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: TextButton(
          style: ButtonStyle(
            elevation: MaterialStatePropertyAll(alt! ? null : 2),
            overlayColor: const MaterialStatePropertyAll(htTrans1),
            backgroundColor:
                MaterialStatePropertyAll(alt! ? null : bgColor ?? htSolid3),
            padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            ),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                  side: alt!
                      ? const BorderSide(color: htSolid3)
                      : BorderSide.none),
            ),
          ),
          onPressed: onPressed,
          child: Padding(
            padding: EdgeInsets.all(size),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null)
                  Icon(
                    icon,
                    color: alt! ? htSolid5 : Colors.white,
                    size: 20,
                  ),
                const SizedBox(width: 5),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.overpass(
                    textStyle: defaultTextStyle.copyWith(
                        color: alt! ? htSolid5 : Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 16 + size,
                        height: 1.5),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
