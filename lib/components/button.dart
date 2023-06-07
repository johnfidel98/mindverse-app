import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/controllers.dart';

class MVButton extends StatefulWidget {
  final Function()? onClick;
  final String label;
  final Color? bGcolor;
  final Color? txtColor;
  final double paddingH;

  const MVButton({
    Key? key,
    required this.onClick,
    required this.label,
    this.bGcolor,
    this.txtColor,
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

    _listener = _session.actionStatus.listen((statusComplete) {
      if (statusComplete) {
        setState(() {
          _loading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _listener.cancel();
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
              _session.setActionStatus(false);
              setState(() {
                _loading = true;
              });
              widget.onClick!();
            },
            style: ButtonStyle(
              textStyle: MaterialStatePropertyAll(
                GoogleFonts.overpass(
                  textStyle: TextStyle(
                    color: widget.txtColor ?? Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              backgroundColor:
                  MaterialStatePropertyAll(widget.bGcolor ?? Colors.black87),
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
            width: MediaQuery.of(context).size.width - 70,
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
  final IconData icon;
  final bool? alt;
  const InterfaceButton({
    super.key,
    required this.label,
    this.onPressed,
    this.alt = false,
    this.bgColor = htSolid5,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: TextButton(
          style: ButtonStyle(
            elevation: const MaterialStatePropertyAll(2),
            overlayColor: const MaterialStatePropertyAll(htTrans1),
            backgroundColor:
                MaterialStatePropertyAll(alt! ? htSolid2 : htSolid3),
            padding: const MaterialStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 10.0, vertical: 2.0),
            ),
            shape: MaterialStatePropertyAll(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            ),
          ),
          onPressed: onPressed,
          child: Row(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: GoogleFonts.overpass(
                  textStyle: defaultTextStyle.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      height: 1.5),
                ),
              ),
            ],
          )),
    );
  }
}
