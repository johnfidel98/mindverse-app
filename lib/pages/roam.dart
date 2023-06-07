import 'package:flutter/material.dart';
import 'package:mindverse/constants.dart';
import 'package:mindverse/utils.dart';

class RoamPage extends StatelessWidget {
  const RoamPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        leading: const LeadingBack(),
        titleSpacing: 0,
        title: Text(
          '#RoamAbout',
          style: defaultTextStyle.copyWith(
            color: Colors.black87,
            fontSize: 23,
          ),
        ),
        backgroundColor: Colors.white,
      ),
    );
  }
}
