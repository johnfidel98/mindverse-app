import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// define default constants

const Color htTrans1 = Color.fromRGBO(33, 150, 243, 0.235);
const Color htTrans2 = Color.fromRGBO(33, 150, 243, 0.353);
const Color htTrans3 = Color.fromRGBO(33, 150, 243, 0.588);
const Color htSolid1 = Color.fromRGBO(200, 221, 230, 1);
const Color htSolid2 = Color.fromRGBO(102, 167, 187, 1);
const Color htSolid3 = Color.fromRGBO(56, 129, 142, 1);
const Color htSolid4 = Color.fromRGBO(33, 150, 243, 1);
const Color htSolid5 = Color.fromRGBO(27, 54, 94, 1);

const double defaultBorderRadius = 10;

const String unknownBastard = '64841ab6cb5e2624dd7b';

enum MVMenuItem { profile, logout }

TextStyle defaultTextStyle = GoogleFonts.overpass(
  textStyle: const TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.normal,
    color: htSolid5,
    height: 1.5,
  ),
);
