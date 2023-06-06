import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

ThemeData appTheme() {
  return ThemeData(
    primarySwatch: Colors.blue,
    textTheme: appTextTheme(),
  );
}

TextTheme appTextTheme() {
  return TextTheme(
    bodyLarge: GoogleFonts.overpass(
      textStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.normal,
        color: Colors.black,
        height: 1.8,
      ),
    ),
    bodyMedium: GoogleFonts.overpass(
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.normal,
        color: Colors.black,
        height: 1.8,
      ),
    ),
    bodySmall: GoogleFonts.overpass(
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.normal,
        color: Colors.black,
        height: 1.8,
      ),
    ),
  );
}
